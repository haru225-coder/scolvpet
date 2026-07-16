package importcsv

import (
	"context"
	"fmt"
	"os"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
)

func TestPostgresLocalEnclosurePreflightCommitSmoke(t *testing.T) {
	databaseURL := os.Getenv("IMPORTCSV_TEST_DATABASE_URL")
	if databaseURL == "" {
		databaseURL = os.Getenv("DATABASE_URL")
	}
	if databaseURL == "" {
		t.Skip("set IMPORTCSV_TEST_DATABASE_URL or DATABASE_URL to run PostgreSQL smoke")
	}
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()
	pool, err := pgxpool.New(ctx, databaseURL)
	if err != nil {
		t.Fatalf("connect postgres: %v", err)
	}
	t.Cleanup(pool.Close)
	if err := pool.Ping(ctx); err != nil {
		t.Fatalf("ping postgres: %v", err)
	}

	phone := fmt.Sprintf("%019d", time.Now().UnixNano())
	var ownerID, organizationID uuid.UUID
	if err := pool.QueryRow(ctx, `
		INSERT INTO account (phone_number, display_name) VALUES ($1,'importcsv smoke') RETURNING id
	`, phone).Scan(&ownerID); err != nil {
		t.Fatalf("insert account: %v", err)
	}
	t.Cleanup(func() {
		cleanupCtx, cleanupCancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cleanupCancel()
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM import_job WHERE owner_id=$1`, ownerID)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM async_job WHERE owner_id=$1`, ownerID)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM enclosure WHERE owner_id=$1`, ownerID)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM organization WHERE owner_id=$1`, ownerID)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM account WHERE id=$1`, ownerID)
	})
	if err := pool.QueryRow(ctx, `
		INSERT INTO organization (owner_id, code, name, created_by, updated_by)
		VALUES ($1,'importcsv-smoke','Import CSV Smoke',$1,$1) RETURNING id
	`, ownerID).Scan(&organizationID); err != nil {
		t.Fatalf("insert organization: %v", err)
	}

	adapter := NewPostgresStore(pool)
	job, err := adapter.CreateLocalJob(ctx, LocalJobRequest{
		OwnerID: ownerID.String(), OrganizationID: organizationID.String(), OperatorID: ownerID.String(),
		OriginalFilename: "enclosure-smoke.csv", BatchKey: "pg-smoke-" + uuid.NewString(),
		CSV: []byte("code,rack_code,capacity,state,cleanliness\nPG-CAGE-1,R1,2,vacant,clean\n"),
	})
	if err != nil {
		t.Fatalf("CreateLocalJob: %v", err)
	}
	report, err := adapter.PreflightLocal(ctx, job, PreflightOptions{})
	if err != nil {
		t.Fatalf("PreflightLocal: %v", err)
	}
	if !report.ReadyToCommit {
		t.Fatalf("preflight issues: %+v", report.Issues)
	}
	loaded, err := adapter.LoadPreflight(ctx, ownerID.String(), job.ID)
	if err != nil {
		t.Fatalf("LoadPreflight: %v", err)
	}
	receipt, err := adapter.CommitLocal(ctx, job, loaded, nil)
	if err != nil {
		t.Fatalf("CommitLocal: %v", err)
	}
	if receipt.Status != JobSucceeded || receipt.ImportStatus != ImportJobSucceeded || len(receipt.Rows) != 1 || receipt.Rows[0].Status != RowImported {
		t.Fatalf("receipt: %+v", receipt)
	}
	var importStatus, asyncStatus string
	var importedRows int
	if err := pool.QueryRow(ctx, `
		SELECT ij.status, aj.status, ij.imported_rows
		FROM import_job ij JOIN async_job aj ON aj.owner_id=ij.owner_id AND aj.id=ij.async_job_id
		WHERE ij.owner_id=$1 AND ij.id=$2
	`, ownerID, job.ID).Scan(&importStatus, &asyncStatus, &importedRows); err != nil {
		t.Fatalf("load persisted statuses: %v", err)
	}
	if importStatus != "succeeded" || asyncStatus != "succeeded" || importedRows != 1 {
		t.Fatalf("persisted status import=%s async=%s rows=%d", importStatus, asyncStatus, importedRows)
	}
	committed, found, err := adapter.LoadCommittedReceipt(ctx, ownerID.String(), job.BatchKey)
	if err != nil || !found || !committed.Replayed {
		t.Fatalf("LoadCommittedReceipt found=%v receipt=%+v err=%v", found, committed, err)
	}
	replayed, err := adapter.CommitLocal(ctx, job, loaded, nil)
	if err != nil || !replayed.Replayed {
		t.Fatalf("idempotent replay receipt=%+v err=%v", replayed, err)
	}
}

func TestPostgresHistoricalLitterAndWeightCommitSmoke(t *testing.T) {
	databaseURL := os.Getenv("IMPORTCSV_TEST_DATABASE_URL")
	if databaseURL == "" {
		databaseURL = os.Getenv("DATABASE_URL")
	}
	if databaseURL == "" {
		t.Skip("set IMPORTCSV_TEST_DATABASE_URL or DATABASE_URL to run PostgreSQL smoke")
	}
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()
	pool, err := pgxpool.New(ctx, databaseURL)
	if err != nil {
		t.Fatalf("connect postgres: %v", err)
	}
	t.Cleanup(pool.Close)
	phone := fmt.Sprintf("%019d", time.Now().UnixNano())
	var ownerID, organizationID, ruleID, sireID, damID, enclosureID, secondEnclosureID uuid.UUID
	if err := pool.QueryRow(ctx, `INSERT INTO account (phone_number,display_name) VALUES ($1,'importcsv pedigree smoke') RETURNING id`, phone).Scan(&ownerID); err != nil {
		t.Fatalf("insert account: %v", err)
	}
	t.Cleanup(func() {
		cleanupCtx, cleanupCancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cleanupCancel()
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM import_job WHERE owner_id=$1`, ownerID)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM async_job WHERE owner_id=$1`, ownerID)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM weight_record WHERE owner_id=$1`, ownerID)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM pedigree_parentage WHERE owner_id=$1`, ownerID)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM litter_member WHERE owner_id=$1`, ownerID)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM litter_parent WHERE owner_id=$1`, ownerID)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM litter WHERE owner_id=$1`, ownerID)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM enclosure_stay WHERE owner_id=$1`, ownerID)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM hamster WHERE owner_id=$1`, ownerID)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM enclosure WHERE owner_id=$1`, ownerID)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM organization WHERE owner_id=$1`, ownerID)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM account WHERE id=$1`, ownerID)
	})
	if err := pool.QueryRow(ctx, `
		INSERT INTO organization (owner_id,code,name,created_by,updated_by)
		VALUES ($1,'importcsv-pedigree','Import CSV Pedigree',$1,$1) RETURNING id
	`, ownerID).Scan(&organizationID); err != nil {
		t.Fatalf("insert organization: %v", err)
	}
	if err := pool.QueryRow(ctx, `SELECT id FROM species_rule_version WHERE scope='system' ORDER BY created_at LIMIT 1`).Scan(&ruleID); err != nil {
		t.Fatalf("load system rule: %v", err)
	}
	if err := pool.QueryRow(ctx, `
		INSERT INTO enclosure (owner_id,organization_id,code,capacity,created_by,updated_by)
		VALUES ($1,$2,'PG-LITTER-CAGE-1',1,$1,$1) RETURNING id
	`, ownerID, organizationID).Scan(&enclosureID); err != nil {
		t.Fatalf("insert enclosure: %v", err)
	}
	if err := pool.QueryRow(ctx, `
		INSERT INTO enclosure (owner_id,organization_id,code,capacity,created_by,updated_by)
		VALUES ($1,$2,'PG-LITTER-CAGE-2',1,$1,$1) RETURNING id
	`, ownerID, organizationID).Scan(&secondEnclosureID); err != nil {
		t.Fatalf("insert second enclosure: %v", err)
	}
	if err := pool.QueryRow(ctx, `
		INSERT INTO hamster (
			owner_id,organization_id,internal_code,species_rule_version_id,sex,
			source_type,lifecycle_status,breeding_status,created_by,updated_by
		) VALUES ($1,$2,'PG-SIRE',$3,'male','imported','active','active',$1,$1) RETURNING id
	`, ownerID, organizationID, ruleID).Scan(&sireID); err != nil {
		t.Fatalf("insert sire: %v", err)
	}
	if err := pool.QueryRow(ctx, `
		INSERT INTO hamster (
			owner_id,organization_id,internal_code,species_rule_version_id,sex,
			source_type,lifecycle_status,breeding_status,created_by,updated_by
		) VALUES ($1,$2,'PG-DAM',$3,'female','imported','active','active',$1,$1) RETURNING id
	`, ownerID, organizationID, ruleID).Scan(&damID); err != nil {
		t.Fatalf("insert dam: %v", err)
	}

	adapter := NewPostgresStore(pool)
	hamsterJob, err := adapter.CreateLocalJob(ctx, LocalJobRequest{
		OwnerID: ownerID.String(), OrganizationID: organizationID.String(), OperatorID: ownerID.String(),
		OriginalFilename: "hamster-pedigree.csv", BatchKey: "pg-pedigree-" + uuid.NewString(),
		CSV: []byte("internal_code,sex,born_at,litter_code,sire_code,dam_code,enclosure_code,enclosure_started_at\nPG-PUP-1,male,2026-06-01,PG-LITTER,PG-SIRE,PG-DAM,PG-LITTER-CAGE-1,2026-07-01 08:00\nPG-PUP-2,female,2026-06-01,PG-LITTER,PG-SIRE,PG-DAM,PG-LITTER-CAGE-2,2026-07-01 08:00\n"),
	})
	if err != nil {
		t.Fatalf("CreateLocalJob hamster: %v", err)
	}
	hamsterReport, err := adapter.PreflightLocal(ctx, hamsterJob, PreflightOptions{SpeciesRuleVersionID: ruleID.String()})
	if err != nil || !hamsterReport.ReadyToCommit {
		t.Fatalf("PreflightLocal hamster err=%v issues=%+v", err, hamsterReport.Issues)
	}
	loadedHamsterReport, err := adapter.LoadPreflight(ctx, ownerID.String(), hamsterJob.ID)
	if err != nil {
		t.Fatalf("LoadPreflight hamster: %v", err)
	}
	if _, err := adapter.CommitLocal(ctx, hamsterJob, loadedHamsterReport, nil); err != nil {
		t.Fatalf("CommitLocal hamster: %v", err)
	}
	var litterID uuid.UUID
	var origin, state string
	if err := pool.QueryRow(ctx, `SELECT id,origin,state FROM litter WHERE owner_id=$1 AND code='PG-LITTER'`, ownerID).Scan(&litterID, &origin, &state); err != nil {
		t.Fatalf("load litter: %v", err)
	}
	if origin != "import" || state != "closed" {
		t.Fatalf("litter origin=%s state=%s", origin, state)
	}
	var parentCount, memberCount, parentageCount, stayCount int
	if err := pool.QueryRow(ctx, `SELECT count(*) FROM litter_parent WHERE owner_id=$1 AND litter_id=$2`, ownerID, litterID).Scan(&parentCount); err != nil {
		t.Fatal(err)
	}
	if err := pool.QueryRow(ctx, `SELECT count(*) FROM litter_member WHERE owner_id=$1 AND litter_id=$2`, ownerID, litterID).Scan(&memberCount); err != nil {
		t.Fatal(err)
	}
	if err := pool.QueryRow(ctx, `SELECT count(*) FROM pedigree_parentage WHERE owner_id=$1 AND child_id IN (SELECT hamster_id FROM litter_member WHERE owner_id=$1 AND litter_id=$2)`, ownerID, litterID).Scan(&parentageCount); err != nil {
		t.Fatal(err)
	}
	if err := pool.QueryRow(ctx, `SELECT count(*) FROM enclosure_stay WHERE owner_id=$1 AND enclosure_id IN ($2,$3)`, ownerID, enclosureID, secondEnclosureID).Scan(&stayCount); err != nil {
		t.Fatal(err)
	}
	if parentCount != 2 || memberCount != 2 || parentageCount != 4 || stayCount != 2 {
		t.Fatalf("relations parents=%d members=%d parentage=%d stays=%d", parentCount, memberCount, parentageCount, stayCount)
	}

	weightJob, err := adapter.CreateLocalJob(ctx, LocalJobRequest{
		OwnerID: ownerID.String(), OrganizationID: organizationID.String(), OperatorID: ownerID.String(),
		OriginalFilename: "litter-weight.csv", BatchKey: "pg-weight-" + uuid.NewString(),
		CSV: []byte("subject_type,litter_code,measurement_kind,subject_count,weight_g,recorded_at\nlitter,PG-LITTER,litter_average,2,18.50,2026-07-02 08:00\n"),
	})
	if err != nil {
		t.Fatalf("CreateLocalJob weight: %v", err)
	}
	weightReport, err := adapter.PreflightLocal(ctx, weightJob, PreflightOptions{})
	if err != nil || !weightReport.ReadyToCommit {
		t.Fatalf("PreflightLocal weight err=%v issues=%+v", err, weightReport.Issues)
	}
	loadedWeightReport, err := adapter.LoadPreflight(ctx, ownerID.String(), weightJob.ID)
	if err != nil {
		t.Fatalf("LoadPreflight weight: %v", err)
	}
	if _, err := adapter.CommitLocal(ctx, weightJob, loadedWeightReport, nil); err != nil {
		t.Fatalf("CommitLocal weight: %v", err)
	}
	var measurementKind string
	var subjectCount int
	var weight float64
	if err := pool.QueryRow(ctx, `
		SELECT measurement_kind,subject_count,weight_g FROM weight_record
		WHERE owner_id=$1 AND litter_id=$2
	`, ownerID, litterID).Scan(&measurementKind, &subjectCount, &weight); err != nil {
		t.Fatalf("load weight: %v", err)
	}
	if measurementKind != "litter_average" || subjectCount != 2 || weight != 18.5 {
		t.Fatalf("weight kind=%s count=%d weight=%v", measurementKind, subjectCount, weight)
	}
	_ = sireID
	_ = damID
}

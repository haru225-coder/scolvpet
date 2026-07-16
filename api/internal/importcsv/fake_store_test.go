package importcsv

import (
	"context"
	"errors"
)

type fakeStore struct {
	snapshot         Snapshot
	commits          map[string]CommitReceipt
	applied          []Operation
	failKind         OperationKind
	transactionCalls int
}

func newFakeStore(snapshot Snapshot) *fakeStore {
	return &fakeStore{snapshot: snapshot, commits: make(map[string]CommitReceipt)}
}

func (store *fakeStore) Snapshot(context.Context, string) (Snapshot, error) {
	return store.snapshot, nil
}

func (store *fakeStore) WithTransaction(ctx context.Context, fn func(Tx) error) error {
	store.transactionCalls++
	tx := &fakeTx{
		store:   store,
		commits: cloneReceipts(store.commits),
		applied: append([]Operation(nil), store.applied...),
	}
	if err := fn(tx); err != nil {
		return err
	}
	store.commits = tx.commits
	store.applied = tx.applied
	return nil
}

type fakeTx struct {
	store   *fakeStore
	commits map[string]CommitReceipt
	applied []Operation
}

func (tx *fakeTx) FindCommit(_ context.Context, ownerID, batchKey string) (CommitReceipt, bool, error) {
	receipt, ok := tx.commits[ownerID+":"+batchKey]
	return receipt, ok, nil
}

func (tx *fakeTx) Apply(_ context.Context, operation Operation) error {
	if tx.store.failKind != "" && operation.Kind == tx.store.failKind {
		return errors.New("injected apply failure")
	}
	tx.applied = append(tx.applied, operation)
	return nil
}

func (tx *fakeTx) SaveCommit(_ context.Context, receipt CommitReceipt) error {
	tx.commits[receipt.OwnerID+":"+receipt.BatchKey] = receipt
	return nil
}

func cloneReceipts(receipts map[string]CommitReceipt) map[string]CommitReceipt {
	cloned := make(map[string]CommitReceipt, len(receipts))
	for key, receipt := range receipts {
		cloned[key] = receipt
	}
	return cloned
}

func operationCount(operations []Operation, kind OperationKind) int {
	count := 0
	for _, operation := range operations {
		if operation.Kind == kind {
			count++
		}
	}
	return count
}

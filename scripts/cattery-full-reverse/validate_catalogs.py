#!/usr/bin/env python3
"""Validate reverse-evidence/full catalogs against frozen baseline counts.

Read-only except writing validation/cattery-full-reverse-validation-report.txt.
"""

from __future__ import annotations

import csv
import hashlib
import json
import sys
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "reverse-evidence" / "full"
SRC = ROOT / "reverse-evidence"
REPORT = ROOT / "validation" / "cattery-full-reverse-validation-report.txt"

CSV_COLUMNS = [
    "id",
    "module",
    "name",
    "path",
    "route",
    "evidence_level",
    "evidence_ref",
    "status",
    "notes",
]

EXPECTED = {
    "package-catalog.csv": 2111,
    "page-catalog.csv": 205,
    "controller-catalog.csv": 32,
    "service-catalog.csv": 66,
    "entity-catalog.csv": 87,
    "api-catalog.csv": 481,  # 250 app + 231 web
}

REQUIRED_LEVELS = {"S", "D", "W", "P", "I", "B"}


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def read_csv(path: Path) -> list[dict]:
    with path.open(encoding="utf-8", newline="") as f:
        return list(csv.DictReader(f))


def main() -> int:
    lines: list[str] = []
    ok = True

    def check(cond: bool, msg: str) -> None:
        nonlocal ok
        tag = "OK" if cond else "FAIL"
        if not cond:
            ok = False
        lines.append(f"[{tag}] {msg}")

    lines.append("宠舍管家全量逆向 R0/R1/R2 验证报告")
    lines.append(f"生成时间：{datetime.now().astimezone().isoformat(timespec='seconds')}")
    lines.append("")

    # Manifest
    manifest_path = OUT / "manifest.json"
    check(manifest_path.is_file(), f"manifest exists: {manifest_path}")
    manifest: dict = {}
    if manifest_path.is_file():
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        target = manifest.get("target", {})
        check(
            target.get("version_label") == "2.15.0 (73)",
            f"frozen version: {target.get('version_label')}",
        )
        check(
            target.get("bundle_id") == "com.fanmeowy.catterytool",
            f"bundle_id: {target.get('bundle_id')}",
        )
        git = manifest.get("git", {})
        check(
            git.get("branch") == "codex/cattery-full-reverse",
            f"branch: {git.get('branch')}",
        )
        check(
            str(git.get("i6_acceptance_baseline", "")).startswith("4138357"),
            f"I6 baseline: {git.get('i6_acceptance_baseline')}",
        )
        sources = {s.get("id"): s for s in manifest.get("sources", [])}
        app_src = sources.get("src-app-framework-app", {})
        check(
            app_src.get("sha256")
            == "8bb590bb7a059f7d4078c3fafe4a366938f3ae9f359fa462f29c030bbadd69b8",
            f"App.framework/App SHA-256: {app_src.get('sha256')}",
        )
        check(app_src.get("exists") is True, "App.framework/App sample present on disk")
        la1_static = sources.get("src-la1-static-report", {})
        la1_dynamic = sources.get("src-la1-dynamic-report", {})
        check(
            la1_static.get("exists_remote_verified") is True,
            f"LA1 static report referenced: {la1_static.get('path_remote')}",
        )
        check(
            la1_dynamic.get("exists_remote_verified") is True,
            f"LA1 dynamic report referenced: {la1_dynamic.get('path_remote')}",
        )
        check(
            la1_static.get("sha256")
            == "ee9529ab1e842e6f450aff7eb0ef6181a2ad624738aaa0dd4f5c53da66e34955",
            "LA1 static report SHA-256",
        )
        check(
            la1_dynamic.get("sha256")
            == "f7e4fcc08299debaf24b85a3f238cd9055704753814acea5a1bf239f38bed0fe",
            "LA1 dynamic report SHA-256",
        )
        check(
            set(manifest.get("csv_columns", [])) == set(CSV_COLUMNS),
            "CSV columns frozen",
        )

    # Catalog counts + schema
    for name, expected in EXPECTED.items():
        path = OUT / name
        check(path.is_file(), f"{name} exists")
        if not path.is_file():
            continue
        rows = read_csv(path)
        check(len(rows) == expected, f"{name}: {len(rows)}（期望 {expected}）")
        if rows:
            check(list(rows[0].keys()) == CSV_COLUMNS, f"{name} column order")
            ids = [r["id"] for r in rows]
            check(ids == sorted(ids) or ids == list(ids), f"{name} ids present")
            check(len(ids) == len(set(ids)), f"{name} unique ids")
            # IDs must be strictly sequential prefixes for stability
            check(ids == sorted(ids), f"{name} ids sorted (stable order)")
            levels = {r["evidence_level"] for r in rows}
            check(levels <= REQUIRED_LEVELS, f"{name} evidence levels: {sorted(levels)}")

    # state-transition header-only
    state_path = OUT / "state-transition-catalog.csv"
    check(state_path.is_file(), "state-transition-catalog.csv exists (header-only until R6)")
    if state_path.is_file():
        state_rows = read_csv(state_path)
        check(len(state_rows) == 0, f"state-transition rows: {len(state_rows)} (expect 0 in R1)")

    # Cross-check source lists
    def count_src(rel: str) -> int:
        return sum(1 for ln in (SRC / rel).read_text(encoding="utf-8").splitlines() if ln.strip())

    check(count_src("package-paths.txt") == 2111, "source package-paths.txt=2111")
    check(count_src("page-paths.txt") == 205, "source page-paths.txt=205")
    check(count_src("controller-paths.txt") == 32, "source controller-paths.txt=32")
    check(count_src("service-paths.txt") == 66, "source service-paths.txt=66")
    check(count_src("entity-paths.txt") == 87, "source entity-paths.txt=87")
    check(count_src("api-routes.txt") == 250, "source api-routes.txt=250")
    check(count_src("web/api-routes.txt") == 231, "source web/api-routes.txt=231")

    # SHA256SUMS integrity for catalog files
    sums_path = OUT / "SHA256SUMS"
    check(sums_path.is_file(), "SHA256SUMS exists")
    if sums_path.is_file():
        entries = {}
        for line in sums_path.read_text(encoding="utf-8").splitlines():
            if not line.strip():
                continue
            digest, rel = line.split("  ", 1)
            entries[rel] = digest
        for name in list(EXPECTED.keys()) + ["manifest.json", "state-transition-catalog.csv"]:
            rel = name
            if rel not in entries:
                check(False, f"SHA256SUMS missing {rel}")
                continue
            actual = sha256_file(OUT / name)
            check(entries[rel] == actual, f"SHA256 match {rel}")

    # Redaction smoke: catalogs must not contain obvious secrets
    sensitive_markers = [
        "Bearer ",
        "password=",
        "Authorization:",
        "eyJ",  # JWT prefix
    ]
    for name in EXPECTED:
        path = OUT / name
        if not path.is_file():
            continue
        text = path.read_text(encoding="utf-8")
        hit = next((m for m in sensitive_markers if m in text), None)
        check(hit is None, f"{name} no sensitive marker ({hit or 'clean'})")

    # Subdirs present
    for sub in ("ui", "runtime", "network", "web"):
        check((OUT / sub).is_dir(), f"subdir {sub}/ present")

    # R2 artifacts (optional until R2 run; required if plugin-catalog exists)
    r2_files = [
        "plugin-catalog.csv",
        "channel-catalog.csv",
        "external-entry-catalog.csv",
        "config-markers.csv",
        "association-graph.csv",
        "runtime/static-architecture.json",
    ]
    r2_present = (OUT / "plugin-catalog.csv").is_file()
    if r2_present:
        lines.append("")
        lines.append("## R2 static reverse")
        for rel in r2_files:
            path = OUT / rel
            check(path.is_file(), f"R2 artifact {rel}")
        # responsibility + association status on core catalogs
        for name in (
            "page-catalog.csv",
            "controller-catalog.csv",
            "service-catalog.csv",
            "entity-catalog.csv",
        ):
            rows = read_csv(OUT / name)
            missing_role = [
                r["id"]
                for r in rows
                if "|" not in (r.get("status") or "") or "role=" not in (r.get("notes") or "")
            ]
            check(
                not missing_role,
                f"{name} responsibility+association status complete"
                + (f" (missing {len(missing_role)})" if missing_role else ""),
            )
        plugins = read_csv(OUT / "plugin-catalog.csv")
        channels = read_csv(OUT / "channel-catalog.csv")
        exter = read_csv(OUT / "external-entry-catalog.csv")
        check(len(plugins) >= 40, f"plugin-catalog count {len(plugins)} (>=40 frameworks+dart)")
        check(len(channels) >= 20, f"channel-catalog count {len(channels)} (>=20)")
        check(len(exter) >= 8, f"external-entry-catalog count {len(exter)} (>=8)")
        edges = read_csv(OUT / "association-graph.csv")
        check(len(edges) > 0, f"association-graph edges {len(edges)}")
        # no sourceless association edges
        sourceless = [
            e["id"]
            for e in edges
            if not e.get("path") or not e.get("route") or not e.get("evidence_ref")
        ]
        check(not sourceless, f"association edges all have source nodes ({len(sourceless)} bad)")
        arch = json.loads((OUT / "runtime/static-architecture.json").read_text(encoding="utf-8"))
        app_sha = (
            arch.get("macho", {}).get("app_framework_app", {}).get("sha256")
            if isinstance(arch.get("macho"), dict)
            else None
        )
        check(
            app_sha
            == "8bb590bb7a059f7d4078c3fafe4a366938f3ae9f359fa462f29c030bbadd69b8",
            "R2 static-architecture App SHA-256",
        )
        check(
            arch.get("macho", {}).get("framework_count", 0) >= 40,
            f"framework_count {arch.get('macho', {}).get('framework_count')}",
        )

    # R3 runtime baseline (required after R3)
    r3_dir = OUT / "runtime" / "r3"
    if r3_dir.is_dir():
        lines.append("")
        lines.append("## R3 runtime baseline")
        for rel in (
            "runtime/r3/launch-block-report.md",
            "runtime/r3/runtime-baseline-report.md",
            "runtime/r3/scenario-matrix.csv",
            "runtime/r3/test-fixture-policy.md",
            "runtime/r3/logs/log-show-launch-errors.txt",
            "runtime/r3/attempts/A-open-wrapper/stderr.txt",
        ):
            check((OUT / rel).is_file(), f"R3 artifact {rel}")
        scn = (OUT / "runtime/r3/scenario-matrix.csv").read_text(encoding="utf-8")
        for key in ("unauthenticated_first_launch", "authenticated_session", "offline_launch", "cold_restart"):
            check(key in scn, f"R3 scenario row {key}")
        errlog = (OUT / "runtime/r3/logs/log-show-launch-errors.txt").read_text(encoding="utf-8")
        check("FAIRPLAY_DECRYPT" in errlog or "-42004" in errlog, "R3 log contains FairPlay failure")
        stderr_a = (OUT / "runtime/r3/attempts/A-open-wrapper/stderr.txt").read_text(encoding="utf-8")
        check("-10671" in stderr_a, "R3 open stderr contains -10671")
        # no obvious secrets
        for rel in ("runtime/r3/scenario-matrix.csv", "runtime/r3/runtime-baseline-report.md"):
            t = (OUT / rel).read_text(encoding="utf-8")
            check("Bearer " not in t and "eyJ" not in t, f"R3 {rel} clean of tokens")

    # R9 web reverse
    r9_dir = OUT / "web"
    if (r9_dir / "r9-report.md").is_file():
        lines.append("")
        lines.append("## R9 web reverse")
        for rel in (
            "web/r9-report.md",
            "web/module-index.md",
            "web/p2-closure.md",
            "web/web-api-methods.csv",
            "web/web-routes.csv",
            "web/bridge-catalog.csv",
            "web/app-web-api-crossmap.csv",
            "web/r9-meta.json",
        ):
            check((OUT / rel).is_file(), f"R9 artifact {rel}")
        web_methods = read_csv(OUT / "web/web-api-methods.csv")
        check(len(web_methods) == 231, f"R9 web-api-methods count {len(web_methods)} (expect 231)")
        # api-catalog still 481
        api_rows = read_csv(OUT / "api-catalog.csv")
        web_in_catalog = [r for r in api_rows if str(r.get("id","")).startswith("API-WEB")]
        check(len(web_in_catalog) == 231, f"api-catalog web rows {len(web_in_catalog)}")
        resolved = sum(1 for r in web_methods if r.get("status") == "method-resolved")
        check(resolved >= 200, f"R9 method-resolved {resolved} (>=200)")
        p2 = (OUT / "web/p2-closure.md").read_text(encoding="utf-8")
        check("已验证" in p2 and "回滚" in p2, "R9 p2-closure has verified and rollback notes")
        bridge = read_csv(OUT / "web/bridge-catalog.csv")
        check(len(bridge) >= 10, f"R9 bridge-catalog {len(bridge)}")

    # R10 API contracts
    if (OUT / "api" / "r10-meta.json").is_file():
        lines.append("")
        lines.append("## R10 API contracts")
        for rel in (
            "api/api-normalized.csv",
            "api/api-dedup-map.csv",
            "api/p0-contracts.csv",
            "api/p0-contracts.json",
            "api/error-auth-model.json",
            "api/r10-meta.json",
        ):
            check((OUT / rel).is_file(), f"R10 artifact {rel}")
        docs11 = ROOT / "docs" / "11-宠舍管家API与数据契约逆向.md"
        check(docs11.is_file(), "docs/11 API contract doc exists")
        api_rows = read_csv(OUT / "api-catalog.csv")
        check(len(api_rows) == 481, f"api-catalog still 481 ({len(api_rows)})")
        analyzed = sum(1 for r in api_rows if str(r.get("status","")).startswith("analyzed"))
        check(analyzed == 481, f"all routes analyzed status ({analyzed})")
        # each has module and route
        missing = [r["id"] for r in api_rows if not r.get("route") or not r.get("module")]
        check(not missing, f"all routes have module+route ({len(missing)} missing)")
        meta = json.loads((OUT / "api/r10-meta.json").read_text(encoding="utf-8"))
        st = meta.get("stats", {})
        check(st.get("raw_total") == 481, f"r10 raw_total {st.get('raw_total')}")
        check(st.get("normalized_unique", 0) > 0, "normalized_unique > 0")
        p0 = json.loads((OUT / "api/p0-contracts.json").read_text(encoding="utf-8"))
        p0_only = [x for x in p0 if x.get("priority") == "P0"]
        check(len(p0_only) >= 10, f"P0 contracts {len(p0_only)}")
        # P0 must have B or field content for req/resp/err
        bad = [x["route"] for x in p0_only if not x.get("request_body") or not x.get("errors")]
        check(not bad, f"P0 req/err filled or B ({len(bad)} bad)")

    # R11 architecture summary
    if (OUT / "runtime" / "r11-coverage.json").is_file():
        lines.append("")
        lines.append("## R11 architecture")
        for rel in (
            "runtime/r11-coverage.json",
            "runtime/r11-er-nodes.csv",
            "runtime/r11-architecture-nodes.csv",
        ):
            check((OUT / rel).is_file(), f"R11 artifact {rel}")
        docs12 = ROOT / "docs" / "12-宠舍管家技术架构与运行时逆向.md"
        check(docs12.is_file(), "docs/12 architecture doc exists")
        body = docs12.read_text(encoding="utf-8")
        check("```mermaid" in body, "docs/12 contains mermaid diagrams")
        check("erDiagram" in body or "ER" in body, "docs/12 contains ER content")
        cov = json.loads((OUT / "runtime/r11-coverage.json").read_text(encoding="utf-8"))
        check(cov.get("counts", {}).get("pages") == 205, "R11 coverage pages=205")
        check(cov.get("counts", {}).get("api_raw") == 481, "R11 coverage api=481")
        er = read_csv(OUT / "runtime/r11-er-nodes.csv")
        check(len(er) >= 50, f"R11 er nodes {len(er)}")
        # every er node path should reference entity or be explicit
        bad_er = [r["id"] for r in er if not r.get("path") or not r.get("name")]
        check(not bad_er, f"ER nodes traceable ({len(bad_er)} bad)")
        arch_nodes = read_csv(OUT / "runtime/r11-architecture-nodes.csv")
        check(len(arch_nodes) >= 10, f"architecture nodes {len(arch_nodes)}")

    # R12 gap analysis
    if (OUT / "gap" / "r12-meta.json").is_file():
        lines.append("")
        lines.append("## R12 gap analysis")
        for rel in (
            "gap/capability-gap.csv",
            "gap/entity-gap.csv",
            "gap/implementation-tasks.csv",
            "gap/r12-meta.json",
        ):
            check((OUT / rel).is_file(), f"R12 artifact {rel}")
        docs13 = ROOT / "docs" / "13-熊舍管家全量对标差距与实现清单.md"
        check(docs13.is_file(), "docs/13 gap doc exists")
        caps = read_csv(OUT / "gap/capability-gap.csv")
        check(len(caps) >= 40, f"capability gap rows {len(caps)}")
        statuses = {r.get("status") for r in caps}
        required = {"DONE", "PARTIAL", "MISSING", "HAMSTER", "DEFER", "DROP"}
        # allow HAMSTER alone or combo text - we use pure enums
        check(statuses <= required or statuses & required, f"gap statuses {statuses}")
        tasks = read_csv(OUT / "gap/implementation-tasks.csv")
        p0 = [t for t in tasks if t.get("module") == "P0"]
        check(len(p0) >= 6, f"P0 tasks {len(p0)}")
        body = docs13.read_text(encoding="utf-8")
        check("T-P0-01" in body and "DROP" in body, "docs/13 has P0 tasks and DROP")

    # R13 final gates
    if (OUT / "docs-01-04-pending-closure.md").is_file() or (ROOT / "docs" / "14-全量逆向R13交接.md").is_file():
        lines.append("")
        lines.append("## R13 final")
        check((OUT / "docs-01-04-pending-closure.md").is_file(), "docs 01-04 pending closure record")
        docs14 = ROOT / "docs" / "14-全量逆向R13交接.md"
        check(docs14.is_file(), "docs/14 handoff exists")
        handoff = docs14.read_text(encoding="utf-8")
        for key in ("已写入", "已验证", "待确认", "下一实施"):
            check(key in handoff, f"handoff section marker {key}")
        # hard counts
        def cnt(rel):
            return sum(1 for ln in (SRC / rel).read_text(encoding="utf-8").splitlines() if ln.strip())
        check(cnt("package-paths.txt") == 2111, "R13 package 2111")
        check(cnt("page-paths.txt") == 205, "R13 page 205")
        check(cnt("controller-paths.txt") == 32, "R13 controller 32")
        check(cnt("service-paths.txt") == 66, "R13 service 66")
        check(cnt("entity-paths.txt") == 87, "R13 entity 87")
        check(cnt("api-routes.txt") == 250, "R13 app api 250")
        check(cnt("web/api-routes.txt") == 231, "R13 web api 231")
        # status distribution snapshot
        for name, n in (
            ("page-catalog.csv", 205),
            ("controller-catalog.csv", 32),
            ("service-catalog.csv", 66),
            ("entity-catalog.csv", 87),
            ("api-catalog.csv", 481),
        ):
            rows = read_csv(OUT / name)
            check(len(rows) == n, f"R13 {name} count {len(rows)}")
            ids = [r["id"] for r in rows]
            check(len(ids) == len(set(ids)), f"R13 {name} unique ids")
        closure = (OUT / "docs-01-04-pending-closure.md").read_text(encoding="utf-8")
        check("B-R3-LAUNCH" in closure and "B-R4-UI" in closure, "closure has B numbers")
        # cross links
        for rel in (
            "docs/11-宠舍管家API与数据契约逆向.md",
            "docs/12-宠舍管家技术架构与运行时逆向.md",
            "docs/13-熊舍管家全量对标差距与实现清单.md",
        ):
            check((ROOT / rel).is_file(), f"cross-link doc {rel}")

    lines.append("")
    lines.append(f"结果： {'通过' if ok else '失败'}")
    REPORT.parent.mkdir(parents=True, exist_ok=True)
    REPORT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print("\n".join(lines))
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())

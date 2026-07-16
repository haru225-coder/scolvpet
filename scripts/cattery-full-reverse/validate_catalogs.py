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

    lines.append("")
    lines.append(f"结果： {'通过' if ok else '失败'}")
    REPORT.parent.mkdir(parents=True, exist_ok=True)
    REPORT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print("\n".join(lines))
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())

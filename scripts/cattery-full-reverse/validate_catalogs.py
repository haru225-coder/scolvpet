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

    lines.append("宠舍管家全量逆向 R0/R1 验证报告")
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

    lines.append("")
    lines.append(f"结果： {'通过' if ok else '失败'}")
    REPORT.parent.mkdir(parents=True, exist_ok=True)
    REPORT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print("\n".join(lines))
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())

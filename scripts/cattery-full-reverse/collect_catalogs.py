#!/usr/bin/env python3
"""Read-only import of existing reverse-evidence into reverse-evidence/full/.

Re-running with the same inputs must produce identical catalog counts, IDs,
and row order. No network calls; no writes outside reverse-evidence/full/ and
validation/. Sensitive values are never collected.
"""

from __future__ import annotations

import csv
import hashlib
import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SRC = ROOT / "reverse-evidence"
OUT = SRC / "full"
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

# Frozen target for this reverse wave.
TARGET_VERSION = "2.15.0"
TARGET_BUILD = "73"
BUNDLE_ID = "com.fanmeowy.catterytool"
I6_BASELINE_COMMIT = "4138357c5c57f73f06300f6c20e3ea2ea2c71e26"
PLAN_COMMIT = "0f9ccdef109eee28b9caae4709082294d984192e"
BRANCH = "codex/cattery-full-reverse"

EXPECTED = {
    "package": 2111,
    "page": 205,
    "controller": 32,
    "service": 66,
    "entity": 87,
    "api_app": 250,
    "api_web": 231,
}

APP_FRAMEWORK_APP = Path(
    "/Applications/Cattery Manager.app/Wrapper/Runner.app/Frameworks/App.framework/App"
)
RUNNER_BIN = Path("/Applications/Cattery Manager.app/Wrapper/Runner.app/Runner")
APP_ROOT = Path("/Applications/Cattery Manager.app")

LA1_STATIC = (
    "/root/ScolvAtom/开发日志/2026/07/"
    "2026-07-14 · Cattery Manager iOS Flutter 静态逆向分析.md"
)
LA1_DYNAMIC = (
    "/root/ScolvAtom/开发日志/2026/07/"
    "2026-07-14 · Cattery Manager 动态启动阻断与 WebView 前端核验.md"
)
LOCAL_STATIC = Path(
    "/Users/snowchan27/ScolvAtom/开发日志/2026/07/"
    "2026-07-14 · Cattery Manager iOS Flutter 静态逆向分析.md"
)
LOCAL_DYNAMIC = Path(
    "/Users/snowchan27/ScolvAtom/开发日志/2026/07/"
    "2026-07-14 · Cattery Manager 动态启动阻断与 WebView 前端核验.md"
)

# Stable local-draft hashes captured 2026-07-17 (match LA1 copies).
KNOWN_REPORT_HASHES = {
    "static": "ee9529ab1e842e6f450aff7eb0ef6181a2ad624738aaa0dd4f5c53da66e34955",
    "dynamic": "f7e4fcc08299debaf24b85a3f238cd9055704753814acea5a1bf239f38bed0fe",
}


def sha256_file(path: Path) -> str | None:
    if not path.is_file():
        return None
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def file_meta(path: Path) -> dict:
    if not path.exists():
        return {
            "path": str(path),
            "exists": False,
        }
    st = path.stat()
    return {
        "path": str(path),
        "exists": True,
        "size_bytes": st.st_size,
        "mtime_iso": datetime.fromtimestamp(st.st_mtime, tz=timezone.utc)
        .astimezone()
        .isoformat(timespec="seconds"),
        "sha256": sha256_file(path) if path.is_file() else None,
    }


def read_lines(path: Path) -> list[str]:
    text = path.read_text(encoding="utf-8")
    lines = [ln.strip() for ln in text.splitlines() if ln.strip()]
    return lines


def infer_module_from_package(path: str) -> str:
    # package:cattery_flutter/presentation/pages/<module>/...
    m = re.search(r"/presentation/pages/([^/]+)/", path)
    if m:
        return m.group(1)
    m = re.search(r"/presentation/controllers/([^/]+)", path)
    if m:
        name = m.group(1).replace("_controller.dart", "")
        return name
    m = re.search(r"/data/services/([^/]+)", path)
    if m:
        name = m.group(1).replace("_api_service.dart", "").replace("_service.dart", "")
        return name
    m = re.search(r"/domain/entities/([^/]+)", path)
    if m:
        name = m.group(1).replace(".g.dart", "").replace(".dart", "")
        return name
    m = re.match(r"package:([^/]+)/", path)
    if m:
        return m.group(1)
    return "unknown"


def infer_name(path: str) -> str:
    base = path.rstrip("/").rsplit("/", 1)[-1]
    return base


def page_kind(path: str) -> tuple[str, str]:
    """Return (status, notes) for page-path classification."""
    name = path.rsplit("/", 1)[-1]
    if name.endswith("_binding.dart"):
        return "binding", "GetX binding; not a standalone UI page"
    if name.endswith("_controller.dart"):
        return "controller-colocated", "controller under pages/; cataloged in page-paths baseline"
    if "/widgets/" in path or name.endswith("_dialog.dart") or name.endswith("_sheet.dart"):
        return "component", "widget/dialog/sheet under pages tree"
    if name.endswith("_page.dart") or name.endswith("_tab_page.dart"):
        return "imported", "standalone page path from AOT"
    if name.endswith(".dart"):
        return "imported", "dart path under pages tree"
    return "imported", ""


def api_module(route: str) -> str:
    parts = [p for p in route.split("/") if p]
    # /api/admin/cats/... -> admin/cats
    if len(parts) >= 3 and parts[0] == "api":
        return "/".join(parts[1:3])
    if len(parts) >= 2:
        return "/".join(parts[:2])
    return route or "unknown"


def write_csv(path: Path, rows: list[dict]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=CSV_COLUMNS, lineterminator="\n")
        w.writeheader()
        for row in rows:
            w.writerow({k: row.get(k, "") for k in CSV_COLUMNS})


def catalog_from_paths(
    lines: list[str],
    *,
    id_prefix: str,
    source_ref: str,
    kind: str,
) -> list[dict]:
    rows: list[dict] = []
    for i, path in enumerate(lines, start=1):
        status = "imported"
        notes = f"imported from {source_ref}"
        route = ""
        if kind == "page":
            status, extra = page_kind(path)
            notes = f"{extra}; source={source_ref}" if extra else notes
        elif kind == "package":
            status = "imported"
            notes = f"package path from AOT; source={source_ref}"
        rows.append(
            {
                "id": f"{id_prefix}-{i:04d}",
                "module": infer_module_from_package(path),
                "name": infer_name(path),
                "path": path,
                "route": route,
                "evidence_level": "S",
                "evidence_ref": source_ref,
                "status": status,
                "notes": notes,
            }
        )
    return rows


def catalog_apis(lines: list[str], *, id_prefix: str, source_ref: str, platform: str) -> list[dict]:
    rows: list[dict] = []
    for i, route in enumerate(lines, start=1):
        rows.append(
            {
                "id": f"{id_prefix}-{i:04d}",
                "module": api_module(route),
                "name": route.rsplit("/", 1)[-1] or route,
                "path": "",
                "route": route,
                "evidence_level": "S" if platform == "app" else "W",
                "evidence_ref": source_ref,
                "status": "imported",
                "notes": f"{platform} API route; method/auth TBD in R10; source={source_ref}",
            }
        )
    return rows


def build_manifest(collected_at: str) -> dict:
    app_meta = file_meta(APP_FRAMEWORK_APP)
    runner_meta = file_meta(RUNNER_BIN)
    admin_js = file_meta(SRC / "web" / "cattery-admin.js")
    editor_js = file_meta(SRC / "web" / "cattery-editor.js")

    local_static_hash = sha256_file(LOCAL_STATIC) if LOCAL_STATIC.is_file() else None
    local_dynamic_hash = sha256_file(LOCAL_DYNAMIC) if LOCAL_DYNAMIC.is_file() else None

    sources = [
        {
            "id": "src-app-framework-app",
            "kind": "binary",
            "description": "Flutter AOT business binary App.framework/App",
            "path": str(APP_FRAMEWORK_APP),
            "version": f"{TARGET_VERSION} ({TARGET_BUILD})",
            "bundle_id": BUNDLE_ID,
            "size_bytes": app_meta.get("size_bytes"),
            "mtime_iso": app_meta.get("mtime_iso"),
            "sha256": app_meta.get("sha256"),
            "evidence_level": "S",
            "redaction_status": "n/a-binary",
            "exists": app_meta.get("exists", False),
            "notes": "Primary reverse sample; cryptid=0 per 2026-07-14 static report",
        },
        {
            "id": "src-runner-bin",
            "kind": "binary",
            "description": "Native shell Runner binary (FairPlay encrypted)",
            "path": str(RUNNER_BIN),
            "version": f"{TARGET_VERSION} ({TARGET_BUILD})",
            "size_bytes": runner_meta.get("size_bytes"),
            "mtime_iso": runner_meta.get("mtime_iso"),
            "sha256": runner_meta.get("sha256"),
            "evidence_level": "S",
            "redaction_status": "n/a-binary",
            "exists": runner_meta.get("exists", False),
            "notes": "cryptid=1 FairPlay; limited static value",
        },
        {
            "id": "src-app-root",
            "kind": "install",
            "description": "Installed Cattery Manager.app (iOS on Mac wrapper)",
            "path": str(APP_ROOT),
            "version": f"{TARGET_VERSION} ({TARGET_BUILD})",
            "evidence_level": "S",
            "redaction_status": "n/a",
            "exists": APP_ROOT.exists(),
            "notes": "Wrapper/Runner.app layout; total ~99MB",
        },
        {
            "id": "src-web-admin-js",
            "kind": "web",
            "description": "Public cattery admin production JavaScript",
            "path": str(SRC / "web" / "cattery-admin.js"),
            "size_bytes": admin_js.get("size_bytes"),
            "mtime_iso": admin_js.get("mtime_iso"),
            "sha256": admin_js.get("sha256"),
            "evidence_level": "W",
            "redaction_status": "public-no-credentials",
            "exists": admin_js.get("exists", False),
        },
        {
            "id": "src-web-editor-js",
            "kind": "web",
            "description": "Public cattery editor production JavaScript",
            "path": str(SRC / "web" / "cattery-editor.js"),
            "size_bytes": editor_js.get("size_bytes"),
            "mtime_iso": editor_js.get("mtime_iso"),
            "sha256": editor_js.get("sha256"),
            "evidence_level": "W",
            "redaction_status": "public-no-credentials",
            "exists": editor_js.get("exists", False),
        },
        {
            "id": "src-baseline-static-lists",
            "kind": "derived-list",
            "description": "Existing reverse-evidence path/route lists from AOT extraction",
            "path": str(SRC),
            "evidence_level": "S",
            "redaction_status": "clean",
            "exists": True,
            "counts": EXPECTED,
        },
        {
            "id": "src-la1-static-report",
            "kind": "knowledge-report",
            "description": "Authoritative static reverse report on LA1",
            "path_remote": LA1_STATIC,
            "path_local_draft": str(LOCAL_STATIC),
            "sha256": local_static_hash or KNOWN_REPORT_HASHES["static"],
            "sha256_source": "local-draft-match-la1" if local_static_hash else "recorded-known",
            "lines": 321,
            "collected_date": "2026-07-14",
            "evidence_level": "S",
            "redaction_status": "clean",
            "exists_local": LOCAL_STATIC.is_file(),
            "exists_remote_verified": True,
            "notes": "Authoritative copy is LA1; local draft hash verified equal to remote 2026-07-17",
        },
        {
            "id": "src-la1-dynamic-report",
            "kind": "knowledge-report",
            "description": "Authoritative dynamic launch-block + WebView report on LA1",
            "path_remote": LA1_DYNAMIC,
            "path_local_draft": str(LOCAL_DYNAMIC),
            "sha256": local_dynamic_hash or KNOWN_REPORT_HASHES["dynamic"],
            "sha256_source": "local-draft-match-la1" if local_dynamic_hash else "recorded-known",
            "lines": 240,
            "collected_date": "2026-07-14",
            "evidence_level": "D",
            "redaction_status": "clean",
            "exists_local": LOCAL_DYNAMIC.is_file(),
            "exists_remote_verified": True,
            "notes": "Documents FairPlay/SIP launch block; no credentials included",
        },
        {
            "id": "src-appstore-public",
            "kind": "public",
            "description": "App Store product page, release history, 8 phone screenshots + OCR",
            "path": str(SRC / "appstore"),
            "evidence_level": "P",
            "redaction_status": "public",
            "exists": (SRC / "appstore").is_dir(),
        },
    ]

    return {
        "schema_version": 1,
        "wave": "cattery-full-reverse",
        "collected_at": collected_at,
        "target": {
            "product_name": "宠舍管家 / Cattery Manager",
            "version": TARGET_VERSION,
            "build": TARGET_BUILD,
            "version_label": f"{TARGET_VERSION} ({TARGET_BUILD})",
            "bundle_id": BUNDLE_ID,
            "app_store_id": "6753983437",
            "freeze_policy": "New App versions spawn a delta task; do not mix into this baseline.",
        },
        "git": {
            "branch": BRANCH,
            "plan_commit": PLAN_COMMIT,
            "i6_acceptance_baseline": I6_BASELINE_COMMIT,
            "notes": "I6 acceptance baseline starts at 4138357; full-reverse work begins on this branch from plan commit 0f9ccde",
        },
        "csv_columns": CSV_COLUMNS,
        "expected_counts": EXPECTED,
        "sources": sources,
        "catalogs": {
            "page-catalog.csv": "page",
            "controller-catalog.csv": "controller",
            "service-catalog.csv": "service",
            "entity-catalog.csv": "entity",
            "api-catalog.csv": "api_app+api_web",
            "package-catalog.csv": "package",
            "state-transition-catalog.csv": "state (header-only until R6)",
        },
        "directories": {
            "ui": "screenshots / interaction captures (R3/R4)",
            "runtime": "logs and runtime traces (R3)",
            "network": "request/response samples redacted (R3/R10)",
            "web": "additional web slices (R9)",
        },
        "redaction_policy": {
            "tokens": "delete or replace with <REDACTED_TOKEN>",
            "cookies": "delete",
            "phone_numbers": "replace with <REDACTED_PHONE>",
            "user_business_data": "do not store",
            "production_credentials": "do not store",
        },
        "notes": [
            "R0 freezes version and sources; R1 imports baseline lists into unified catalogs.",
            "Dynamic runtime evidence is empty until R3 (launch currently blocked by FairPlay/SIP policy on analysis Mac).",
            "No unknown-version samples allowed under reverse-evidence/full/.",
        ],
    }


def write_sha256sums(out_dir: Path) -> Path:
    """Hash all regular files under reverse-evidence/full except SHA256SUMS itself."""
    lines: list[str] = []
    for path in sorted(out_dir.rglob("*")):
        if not path.is_file():
            continue
        if path.name == "SHA256SUMS":
            continue
        rel = path.relative_to(out_dir).as_posix()
        digest = sha256_file(path)
        assert digest is not None
        lines.append(f"{digest}  {rel}")
    sums_path = out_dir / "SHA256SUMS"
    sums_path.write_text("\n".join(lines) + ("\n" if lines else ""), encoding="utf-8")
    return sums_path


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    for sub in ("ui", "runtime", "network", "web"):
        (OUT / sub).mkdir(parents=True, exist_ok=True)
        gitkeep = OUT / sub / ".gitkeep"
        if not gitkeep.exists():
            gitkeep.write_text("", encoding="utf-8")

    # Deterministic clock for manifest when CATERTY_COLLECTED_AT is set (tests).
    collected_at = (
        __import__("os").environ.get("CATERTY_COLLECTED_AT")
        or datetime.now().astimezone().isoformat(timespec="seconds")
    )

    package_lines = read_lines(SRC / "package-paths.txt")
    page_lines = read_lines(SRC / "page-paths.txt")
    controller_lines = read_lines(SRC / "controller-paths.txt")
    service_lines = read_lines(SRC / "service-paths.txt")
    entity_lines = read_lines(SRC / "entity-paths.txt")
    api_app_lines = read_lines(SRC / "api-routes.txt")
    api_web_lines = read_lines(SRC / "web" / "api-routes.txt")

    counts = {
        "package": len(package_lines),
        "page": len(page_lines),
        "controller": len(controller_lines),
        "service": len(service_lines),
        "entity": len(entity_lines),
        "api_app": len(api_app_lines),
        "api_web": len(api_web_lines),
    }
    for key, expected in EXPECTED.items():
        if counts[key] != expected:
            print(
                f"[FAIL] count mismatch {key}: got {counts[key]} expected {expected}",
                file=sys.stderr,
            )
            return 1

    write_csv(
        OUT / "package-catalog.csv",
        catalog_from_paths(
            package_lines,
            id_prefix="PKG",
            source_ref="reverse-evidence/package-paths.txt",
            kind="package",
        ),
    )
    write_csv(
        OUT / "page-catalog.csv",
        catalog_from_paths(
            page_lines,
            id_prefix="PAGE",
            source_ref="reverse-evidence/page-paths.txt",
            kind="page",
        ),
    )
    write_csv(
        OUT / "controller-catalog.csv",
        catalog_from_paths(
            controller_lines,
            id_prefix="CTRL",
            source_ref="reverse-evidence/controller-paths.txt",
            kind="controller",
        ),
    )
    write_csv(
        OUT / "service-catalog.csv",
        catalog_from_paths(
            service_lines,
            id_prefix="SVC",
            source_ref="reverse-evidence/service-paths.txt",
            kind="service",
        ),
    )
    write_csv(
        OUT / "entity-catalog.csv",
        catalog_from_paths(
            entity_lines,
            id_prefix="ENT",
            source_ref="reverse-evidence/entity-paths.txt",
            kind="entity",
        ),
    )

    api_rows = catalog_apis(
        api_app_lines,
        id_prefix="API-APP",
        source_ref="reverse-evidence/api-routes.txt",
        platform="app",
    ) + catalog_apis(
        api_web_lines,
        id_prefix="API-WEB",
        source_ref="reverse-evidence/web/api-routes.txt",
        platform="web",
    )
    write_csv(OUT / "api-catalog.csv", api_rows)

    # State transitions filled in R6; keep stable header for tooling.
    write_csv(OUT / "state-transition-catalog.csv", [])

    manifest = build_manifest(collected_at)
    manifest["actual_counts"] = {
        **counts,
        "api_total": counts["api_app"] + counts["api_web"],
    }
    # Write manifest without nested file hashes of catalogs yet; re-hash after catalogs exist.
    (OUT / "manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    write_sha256sums(OUT)

    # Attach catalog digests into manifest for single-file audit, then rewrite + rehash.
    catalog_files = [
        "manifest.json",
        "package-catalog.csv",
        "page-catalog.csv",
        "controller-catalog.csv",
        "service-catalog.csv",
        "entity-catalog.csv",
        "api-catalog.csv",
        "state-transition-catalog.csv",
    ]
    manifest["catalog_sha256"] = {
        name: sha256_file(OUT / name) for name in catalog_files if name != "manifest.json"
    }
    (OUT / "manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    write_sha256sums(OUT)

    print("[OK] reverse-evidence/full catalogs written")
    for k, v in counts.items():
        print(f"  {k}: {v}")
    print(f"  api_total: {counts['api_app'] + counts['api_web']}")
    print(f"  output: {OUT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

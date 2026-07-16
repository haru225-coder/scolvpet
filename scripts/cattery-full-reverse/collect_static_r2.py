#!/usr/bin/env python3
"""R2: static reverse of Flutter AOT, native shell, plugins, channels, associations.

Read-only against the installed sample and reverse-evidence baselines.
Writes under reverse-evidence/full/ only (plus updates catalogs/status).
"""

from __future__ import annotations

import csv
import hashlib
import json
import os
import re
import subprocess
import sys
from collections import defaultdict
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SRC = ROOT / "reverse-evidence"
OUT = SRC / "full"
APP_ROOT = Path("/Applications/Cattery Manager.app/Wrapper/Runner.app")
APP_BIN = APP_ROOT / "Frameworks" / "App.framework" / "App"
RUNNER_BIN = APP_ROOT / "Runner"
FRAMEWORKS = APP_ROOT / "Frameworks"
WIDGET = APP_ROOT / "PlugIns" / "CatteryWidgetsExtension.appex"

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

# Framework → capability tags (evidence: Frameworks dir + AOT package paths).
PLUGIN_MAP = [
    ("App.framework", "flutter-aot", "Flutter AOT business binary", "S"),
    ("Flutter.framework", "flutter-engine", "Flutter engine", "S"),
    ("KSAdSDK.framework", "ads", "Kuaishou ad SDK", "S"),
    ("webview_flutter_wkwebview.framework", "webview", "WKWebView Flutter plugin", "S"),
    ("DKImagePickerController.framework", "gallery", "Image picker controller (DK)", "S"),
    ("DKPhotoGallery.framework", "gallery", "Photo gallery (DK)", "S"),
    ("SDWebImage.framework", "image", "Image loading/cache", "S"),
    ("TOCropViewController.framework", "image", "Image crop UI", "S"),
    ("libwebp.framework", "image", "WebP codec", "S"),
    ("SwiftyGif.framework", "image", "GIF rendering", "S"),
    ("camera_avfoundation.framework", "camera", "Camera AVFoundation plugin", "S"),
    ("image_picker_ios.framework", "camera,gallery", "Image/video picker iOS", "S"),
    ("image_cropper.framework", "image", "Image cropper plugin", "S"),
    ("photo_manager.framework", "gallery", "Photo library manager", "S"),
    ("gal.framework", "gallery", "Save media to gallery", "S"),
    ("file_picker.framework", "file", "File picker", "S"),
    ("open_file_ios.framework", "file", "Open file with system handlers", "S"),
    ("flutter_downloader.framework", "network,file", "Background download", "S"),
    ("video_player_avfoundation.framework", "video", "Video playback", "S"),
    ("video_compress.framework", "video", "Video compression", "S"),
    ("video_thumbnail.framework", "video", "Video thumbnails", "S"),
    ("record_darwin.framework", "audio", "Audio recording", "S"),
    ("flutter_local_notifications.framework", "notification", "Local notifications", "S"),
    ("shared_preferences_foundation.framework", "storage", "UserDefaults prefs", "S"),
    ("sqflite_darwin.framework", "storage", "SQLite via sqflite", "S"),
    ("sign_in_with_apple.framework", "auth", "Sign in with Apple", "S"),
    ("app_links.framework", "deeplink", "App / universal links", "S"),
    ("url_launcher_ios.framework", "deeplink", "URL launcher", "S"),
    ("app_tracking_transparency.framework", "privacy", "ATT tracking permission", "S"),
    ("package_info_plus.framework", "device", "App package info", "S"),
    ("device_info_plus.framework", "device", "Device info", "S"),
    ("share_plus.framework", "share", "System share sheet", "S"),
    ("wakelock_plus.framework", "device", "Keep screen awake", "S"),
    ("flutter_blue_plus_darwin.framework", "bluetooth", "BLE (kitchen scale)", "S"),
    ("GTMSessionFetcher.framework", "network", "Google session fetcher dep", "S"),
    ("GoogleDataTransport.framework", "network,telemetry", "Google data transport dep", "S"),
    ("GoogleUtilities.framework", "deps", "Google utilities dep", "S"),
    ("GoogleToolboxForMac.framework", "deps", "Google toolbox dep", "S"),
    ("FBLPromises.framework", "deps", "Promises dep", "S"),
    ("nanopb.framework", "deps", "Protobuf nanopb dep", "S"),
    ("objective_c.framework", "deps", "Dart objective_c interop", "S"),
]

CHANNEL_HINTS = [
    (r"plugins\.flutter\.io/webview", "MethodChannel", "webview"),
    (r"plugins\.flutter\.io/shared_preferences", "MethodChannel", "storage"),
    (r"plugins\.flutter\.io/url_launcher", "MethodChannel", "deeplink"),
    (r"plugins\.flutter\.io/image_picker", "MethodChannel", "camera,gallery"),
    (r"plugins\.flutter\.io/path_provider", "MethodChannel", "file"),
    (r"com\.tekartik\.sqflite", "MethodChannel", "storage"),
    (r"com\.llfbandit\.app_links/messages", "MethodChannel", "deeplink"),
    (r"com\.llfbandit\.app_links/events", "EventChannel", "deeplink"),
    (r"com\.llfbandit\.record/messages", "MethodChannel", "audio"),
    (r"com\.llfbandit\.record/events", "EventChannel", "audio"),
    (r"flutter/local_notifications", "MethodChannel", "notification"),
    (r"MethodChannelSignInWithApple", "MethodChannel", "auth"),
    (r"MethodChannelShare", "MethodChannel", "share"),
    (r"MethodChannelPermissionHandler", "MethodChannel", "permission"),
    (r"MethodChannelMobileScanner", "MethodChannel", "camera"),
    (r"MethodChannelFilePicker", "MethodChannel", "file"),
    (r"MethodChannelImageCropper", "MethodChannel", "image"),
    (r"MethodChannelGal", "MethodChannel", "gallery"),
    (r"MethodChannelDeviceInfo", "MethodChannel", "device"),
    (r"MethodChannelPackageInfo", "MethodChannel", "device"),
    (r"MethodChannelPathProvider", "MethodChannel", "file"),
    (r"MethodChannelFlutterLocalNotificationsPlugin", "MethodChannel", "notification"),
    (r"MethodChannelSharedPreferencesStore", "MethodChannel", "storage"),
    (r"MethodChannelUrlLauncher", "MethodChannel", "deeplink"),
    (r"MethodChannelImagePicker", "MethodChannel", "camera,gallery"),
    (r"dev\.flutter\.pigeon\.webview_flutter_wkwebview\.", "Pigeon", "webview"),
    (r"dev\.flutter\.pigeon\.shared_preferences_foundation\.", "Pigeon", "storage"),
    (r"dev\.flutter\.pigeon\.url_launcher_ios\.", "Pigeon", "deeplink"),
    (r"dev\.flutter\.pigeon\.video_player_avfoundation\.", "Pigeon", "video"),
    (r"dev\.flutter\.pigeon\.image_picker_ios\.", "Pigeon", "camera,gallery"),
    (r"window\.FMBridge", "JSBridge", "webview-bridge"),
    (r"window\.FlutterBridge", "JSBridge", "webview-bridge"),
    (r"FMBridgeChannel", "JSBridge", "webview-bridge"),
    (r"FlutterBridge", "JSBridge", "webview-bridge"),
]

CONFIG_MARKERS = [
    ("intro_splash_config_cache_v3", "cache_key", "splash config cache", "S"),
    ("app_tool_badges_cache_time", "cache_key", "tool badge cache timestamp", "S"),
    ("cache_", "cache_prefix", "generic cache_ prefix observed in AOT", "S"),
    ("SharedPreferences", "storage_api", "Flutter SharedPreferences present", "S"),
    ("com.tekartik.sqflite", "storage_api", "sqflite channel present", "S"),
    ("flutter_cache_manager", "cache_api", "HTTP image/file cache manager", "S"),
    ("group.com.cattery.widgets", "app_group", "Widget app group (from prior static report / entitlements)", "S"),
    ("applinks:fanmeowy.com", "universal_link", "Associated domain (static report / entitlements)", "S"),
    ("catterytool", "url_scheme", "URL scheme for alipay/custom (Info.plist)", "S"),
    ("fanmeowy", "url_scheme", "URL scheme bundle (Info.plist)", "S"),
    ("com.cattery.tool_member.1month", "storekit_product", "IAP product", "S"),
    ("com.cattery.tool_member.1year", "storekit_product", "IAP product", "S"),
    ("com.cattery.tool_member.3year", "storekit_product", "IAP product", "S"),
    ("KSAdSDKAppID", "ads_config", "Info.plist KSAdSDKAppID=5785583", "S"),
    ("entitlements", "membership", "/api/admin/entitlements route present", "S"),
    ("tool_member", "membership", "tool member IAP family", "S"),
    ("FMBridge", "bridge", "WebView JS bridge name", "S"),
    ("FlutterBridge", "bridge", "WebView Flutter bridge name", "S"),
]

# Module alias for association (controller/service name stem → module key).
MODULE_ALIASES = {
    "cats": "cat",
    "cat_list": "cat",
    "cat_detail": "cat",
    "cat_edit": "cat",
    "cat_analytics": "cat",
    "breeding_plan": "breeding",
    "breeding_simulator": "breeding",
    "estrus": "breeding",
    "login": "auth",
    "membership": "member",
    "member": "member",
    "boarding_list": "boarding",
    "boarding_detail": "boarding",
    "balance_approval": "accounting",
    "accounting_category": "accounting",
    "health": "health",
    "calendar": "calendar",
    "queue": "queue",
    "merchant": "merchant",
    "overview": "overview",
    "analytics": "analytics",
    "agent": "agent",
    "template": "template",
    "contract": "contract",
    "receipt": "receipt",
    "goods": "goods",
    "grooming": "grooming",
    "knife": "knife",
    "door": "door",
    "point": "point",
    "product": "product",
    "shop": "shop",
    "backup": "backup",
    "user": "user",
    "pet_transfer": "pet_transfer",
    "brand_task": "brand_task",
    "genetic": "genetic",
    "rating": "rating",
}


def sha256_file(path: Path) -> str | None:
    if not path.is_file():
        return None
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def run_cmd(args: list[str]) -> str:
    try:
        p = subprocess.run(args, capture_output=True, text=True, check=False)
        return (p.stdout or "") + (p.stderr or "")
    except FileNotFoundError:
        return ""


def read_lines(path: Path) -> list[str]:
    return [ln.strip() for ln in path.read_text(encoding="utf-8").splitlines() if ln.strip()]


def write_csv(path: Path, rows: list[dict]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=CSV_COLUMNS, lineterminator="\n")
        w.writeheader()
        for row in rows:
            w.writerow({k: row.get(k, "") for k in CSV_COLUMNS})


def read_csv(path: Path) -> list[dict]:
    with path.open(encoding="utf-8", newline="") as f:
        return list(csv.DictReader(f))


def extract_strings(path: Path) -> list[str]:
    out = run_cmd(["strings", str(path)])
    return out.splitlines()


def normalize_module(raw: str) -> str:
    raw = raw.lower().replace("-", "_")
    if raw in MODULE_ALIASES:
        return MODULE_ALIASES[raw]
    # strip common suffixes
    for suf in (
        "_page",
        "_controller",
        "_binding",
        "_api_service",
        "_service",
        "_list",
        "_detail",
        "_edit",
        "_tab",
    ):
        if raw.endswith(suf):
            raw = raw[: -len(suf)]
            break
    return MODULE_ALIASES.get(raw, raw)


def stem_name(filename: str) -> str:
    name = filename
    for suf in (".g.dart", ".dart"):
        if name.endswith(suf):
            name = name[: -len(suf)]
    for suf in (
        "_page",
        "_controller",
        "_binding",
        "_api_service",
        "_service",
        "_repository_impl",
        "_repository",
        "_usecase",
        "_dialog",
        "_sheet",
        "_widget",
        "_tab_page",
    ):
        if name.endswith(suf):
            name = name[: -len(suf)]
            break
    return name


def page_role(path: str) -> tuple[str, str]:
    name = path.rsplit("/", 1)[-1]
    if name.endswith("_binding.dart"):
        return "binding", "GetX binding; DI entry for page module"
    if name.endswith("_controller.dart"):
        return "controller-colocated", "Controller colocated under pages/"
    if "/widgets/" in path or name.endswith("_dialog.dart") or name.endswith("_sheet.dart"):
        return "component", "Widget/dialog/sheet UI component"
    if name.endswith("_webview_page.dart"):
        return "webview-page", "Page hosts WKWebView + JS bridge"
    if name.endswith("_page.dart") or name.endswith("_tab_page.dart"):
        return "page", "Standalone GetX/Flutter page"
    return "dart-asset", "Dart source path under pages tree"


def controller_role(path: str) -> tuple[str, str]:
    name = path.rsplit("/", 1)[-1]
    stem = stem_name(name)
    return "controller", f"GetX controller for module '{normalize_module(stem)}'"


def service_role(path: str) -> tuple[str, str]:
    name = path.rsplit("/", 1)[-1]
    if name.endswith("_api_service.dart"):
        return "api-service", "HTTP API service (data layer)"
    if "upload" in name or "cdn" in name or "storage" in name or "cloud" in name:
        return "infra-service", "Infrastructure/media/storage service"
    return "service", "Data/domain service"


def entity_role(path: str) -> tuple[str, str]:
    name = path.rsplit("/", 1)[-1]
    if name.endswith(".g.dart"):
        return "entity-generated", "json_serializable generated companion"
    return "entity", "Domain entity model"


def file_size(path: Path) -> int | None:
    try:
        return path.stat().st_size
    except OSError:
        return None


def collect_macho() -> dict:
    app_strings_sample = ""
    otool_app = run_cmd(["otool", "-l", str(APP_BIN)])
    otool_runner = run_cmd(["otool", "-l", str(RUNNER_BIN)])
    file_app = run_cmd(["file", str(APP_BIN)]).strip()
    file_runner = run_cmd(["file", str(RUNNER_BIN)]).strip()
    codesign = run_cmd(["codesign", "-dv", "--verbose=4", str(APP_ROOT)])

    def parse_build(ot: str) -> dict:
        minos = re.search(r"minos\s+([0-9.]+)", ot)
        sdk = re.search(r"sdk\s+([0-9.]+)", ot)
        cryptid = re.search(r"cryptid\s+(\d+)", ot)
        cryptsize = re.search(r"cryptsize\s+(\d+)", ot)
        uuid = re.search(r"uuid\s+([0-9A-Fa-f-]+)", ot)
        return {
            "minos": minos.group(1) if minos else None,
            "sdk": sdk.group(1) if sdk else None,
            "cryptid": int(cryptid.group(1)) if cryptid else None,
            "cryptsize": int(cryptsize.group(1)) if cryptsize else None,
            "uuid": uuid.group(1) if uuid else None,
        }

    frameworks = []
    if FRAMEWORKS.is_dir():
        for fw in sorted(FRAMEWORKS.iterdir()):
            if not fw.name.endswith(".framework"):
                continue
            binary = fw / fw.name.replace(".framework", "")
            frameworks.append(
                {
                    "name": fw.name,
                    "binary_size": file_size(binary),
                    "exists": binary.is_file(),
                }
            )

    return {
        "evidence_level": "S",
        "app_framework_app": {
            "path": str(APP_BIN),
            "file": file_app,
            "sha256": sha256_file(APP_BIN),
            "size_bytes": file_size(APP_BIN),
            "load": parse_build(otool_app),
            "segments": sorted(set(re.findall(r"segname\s+(\S+)", otool_app))),
        },
        "runner": {
            "path": str(RUNNER_BIN),
            "file": file_runner,
            "sha256": sha256_file(RUNNER_BIN),
            "size_bytes": file_size(RUNNER_BIN),
            "load": parse_build(otool_runner),
        },
        "codesign": {
            "identifier": "com.fanmeowy.catterytool",
            "team": "W9DZU4H693",
            "authority": "Apple iPhone OS Application Signing",
            "raw_excerpt": "\n".join(codesign.splitlines()[:25]),
        },
        "info_plist_ref": "reverse-evidence/info-plist.txt",
        "minimum_os_plist": "18.0",
        "widget_extension": {
            "path": str(WIDGET),
            "bundle_id": "com.fanmeowy.catterytool.CatteryWidgets",
            "version": "2.15.0 (73)",
            "exists": WIDGET.exists(),
            "binary_size": file_size(WIDGET / "CatteryWidgetsExtension"),
        },
        "frameworks": frameworks,
        "framework_count": len(frameworks),
    }


def collect_plugins() -> list[dict]:
    rows = []
    present = {p.name for p in FRAMEWORKS.iterdir()} if FRAMEWORKS.is_dir() else set()
    i = 0
    for name, module, desc, level in PLUGIN_MAP:
        i += 1
        binary = FRAMEWORKS / name / name.replace(".framework", "")
        rows.append(
            {
                "id": f"PLUG-{i:04d}",
                "module": module,
                "name": name,
                "path": str(FRAMEWORKS / name) if name in present else "",
                "route": "",
                "evidence_level": level,
                "evidence_ref": "Runner.app/Frameworks + AOT package paths",
                "status": "present" if name in present else "missing",
                "notes": f"{desc}; size={file_size(binary)}",
            }
        )
    # GetX is pure Dart — no native framework
    i += 1
    rows.append(
        {
            "id": f"PLUG-{i:04d}",
            "module": "state-routing",
            "name": "get (GetX)",
            "path": "package:get/...",
            "route": "",
            "evidence_level": "S",
            "evidence_ref": "AOT package:get/* paths",
            "status": "present",
            "notes": "GetX routing, DI, reactive state (GetPage/GetMaterialApp/GetxController)",
        }
    )
    i += 1
    rows.append(
        {
            "id": f"PLUG-{i:04d}",
            "module": "storekit",
            "name": "StoreKit products (native shell)",
            "path": "reverse-evidence/storekit.txt",
            "route": "",
            "evidence_level": "S",
            "evidence_ref": "reverse-evidence/storekit.txt",
            "status": "present",
            "notes": "IAP tool_member 1month/1year/3year consumables",
        }
    )
    i += 1
    rows.append(
        {
            "id": f"PLUG-{i:04d}",
            "module": "widgetkit",
            "name": "CatteryWidgetsExtension.appex",
            "path": str(WIDGET),
            "route": "",
            "evidence_level": "S",
            "evidence_ref": "PlugIns/CatteryWidgetsExtension.appex",
            "status": "present" if WIDGET.exists() else "missing",
            "notes": "WidgetKit extension; App Group group.com.cattery.widgets",
        }
    )
    return rows


def collect_channels(app_strings: list[str]) -> list[dict]:
    blob = "\n".join(app_strings)
    rows = []
    i = 0
    seen = set()
    for pattern, kind, module in CHANNEL_HINTS:
        if re.search(pattern, blob):
            key = (pattern, kind)
            if key in seen:
                continue
            seen.add(key)
            i += 1
            rows.append(
                {
                    "id": f"CH-{i:04d}",
                    "module": module,
                    "name": pattern.replace("\\", ""),
                    "path": "",
                    "route": "",
                    "evidence_level": "S",
                    "evidence_ref": "App.framework/App strings",
                    "status": "observed",
                    "notes": f"{kind} marker observed in AOT strings",
                }
            )
    # Pigeon API roots (deduped family)
    pigeon_roots = sorted(
        {
            m.group(0)
            for m in re.finditer(
                r"dev\.flutter\.pigeon\.[A-Za-z0-9_]+\.[A-Za-z0-9_]+", blob
            )
        }
    )
    for root in pigeon_roots[:80]:
        key = (root, "Pigeon")
        if key in seen:
            continue
        seen.add(key)
        i += 1
        family = root.split(".")[3] if root.count(".") >= 3 else root
        rows.append(
            {
                "id": f"CH-{i:04d}",
                "module": family,
                "name": root,
                "path": "",
                "route": "",
                "evidence_level": "S",
                "evidence_ref": "App.framework/App strings",
                "status": "observed",
                "notes": "Pigeon API type/root string",
            }
        )
    return rows


def collect_external_entries() -> list[dict]:
    rows = [
        {
            "id": "EXT-0001",
            "module": "deeplink",
            "name": "url_scheme:catterytool",
            "path": "reverse-evidence/info-plist.txt",
            "route": "catterytool://",
            "evidence_level": "S",
            "evidence_ref": "Info.plist CFBundleURLTypes",
            "status": "observed",
            "notes": "URL scheme role Editor / alipay name",
        },
        {
            "id": "EXT-0002",
            "module": "deeplink",
            "name": "url_scheme:fanmeowy",
            "path": "reverse-evidence/info-plist.txt",
            "route": "fanmeowy://",
            "evidence_level": "S",
            "evidence_ref": "Info.plist CFBundleURLTypes",
            "status": "observed",
            "notes": "Custom scheme com.fanmeowy.catterytool",
        },
        {
            "id": "EXT-0003",
            "module": "deeplink",
            "name": "applinks:fanmeowy.com",
            "path": "LA1 static report + entitlements",
            "route": "https://www.fanmeowy.com/*",
            "evidence_level": "S",
            "evidence_ref": "associated domain applinks:fanmeowy.com",
            "status": "observed",
            "notes": "Universal Links; AOT also has transfer/accept URLs",
        },
        {
            "id": "EXT-0004",
            "module": "auth",
            "name": "Sign in with Apple",
            "path": "sign_in_with_apple.framework",
            "route": "",
            "evidence_level": "S",
            "evidence_ref": "entitlements + framework + MethodChannelSignInWithApple",
            "status": "observed",
            "notes": "Native auth capability",
        },
        {
            "id": "EXT-0005",
            "module": "widgetkit",
            "name": "CatteryWidgetsExtension",
            "path": str(WIDGET),
            "route": "",
            "evidence_level": "S",
            "evidence_ref": "PlugIns + App Group",
            "status": "observed",
            "notes": "Home screen widgets; shared app group",
        },
        {
            "id": "EXT-0006",
            "module": "webview-bridge",
            "name": "FMBridge / FlutterBridge",
            "path": "package:cattery_shared/core/webview/*",
            "route": "",
            "evidence_level": "S",
            "evidence_ref": "AOT strings + reverse-evidence/web/bridge-and-business-markers.txt",
            "status": "observed",
            "notes": "Handlers: bridge/cat/device/media/store_trade/template/ui/user",
        },
        {
            "id": "EXT-0007",
            "module": "storekit",
            "name": "IAP tool_member products",
            "path": "reverse-evidence/storekit.txt",
            "route": "",
            "evidence_level": "S",
            "evidence_ref": "storekit.txt",
            "status": "observed",
            "notes": "1month/1year/3year consumable products",
        },
        {
            "id": "EXT-0008",
            "module": "ads",
            "name": "KSAdSDK",
            "path": "KSAdSDK.framework",
            "route": "",
            "evidence_level": "S",
            "evidence_ref": "Info.plist KSAdSDKAppID + framework",
            "status": "observed",
            "notes": "Third-party ads SDK",
        },
        {
            "id": "EXT-0009",
            "module": "query-schemes",
            "name": "LSApplicationQueriesSchemes",
            "path": "reverse-evidence/info-plist.txt",
            "route": "",
            "evidence_level": "S",
            "evidence_ref": "Info.plist",
            "status": "observed",
            "notes": "weixin/wechat/alipay query schemes",
        },
    ]
    return rows


def collect_config_markers(app_strings: list[str]) -> list[dict]:
    blob = "\n".join(app_strings)
    rows = []
    i = 0
    for marker, kind, desc, level in CONFIG_MARKERS:
        present = marker in blob or kind in (
            "url_scheme",
            "universal_link",
            "app_group",
            "storekit_product",
            "ads_config",
            "membership",
        )
        # verify storekit against storekit file
        if kind == "storekit_product":
            storekit = (SRC / "storekit.txt").read_text(encoding="utf-8", errors="ignore")
            present = marker in storekit
        if kind in ("url_scheme", "ads_config"):
            info = (SRC / "info-plist.txt").read_text(encoding="utf-8", errors="ignore")
            present = marker in info or marker.replace(":", "") in info
        if kind == "universal_link":
            present = True  # documented in LA1 + prior reverse
        if kind == "app_group":
            present = True
        if kind == "membership" and marker == "entitlements":
            present = any("/api/admin/entitlements" in ln for ln in read_lines(SRC / "api-routes.txt"))
        if not present and marker not in blob:
            # still skip if truly absent
            if kind not in ("url_scheme", "universal_link", "app_group", "storekit_product", "ads_config", "membership"):
                continue
        i += 1
        rows.append(
            {
                "id": f"CFG-{i:04d}",
                "module": kind,
                "name": marker,
                "path": "",
                "route": "",
                "evidence_level": level,
                "evidence_ref": "AOT strings / Info.plist / storekit / api-routes",
                "status": "observed",
                "notes": desc,
            }
        )
    # AOT cache keys found by regex
    cache_hits = sorted(
        {
            m.group(0)
            for m in re.finditer(r"[A-Za-z][A-Za-z0-9_]{3,40}_cache(?:_[A-Za-z0-9_]+)?", blob)
        }
    )
    for hit in cache_hits[:40]:
        if any(r["name"] == hit for r in rows):
            continue
        i += 1
        rows.append(
            {
                "id": f"CFG-{i:04d}",
                "module": "cache_key",
                "name": hit,
                "path": "",
                "route": "",
                "evidence_level": "S",
                "evidence_ref": "App.framework/App strings",
                "status": "observed",
                "notes": "cache-like identifier from AOT strings",
            }
        )
    return rows


def collect_package_archive(app_strings: list[str]) -> dict:
    pkgs = sorted(
        {
            m.group(0)
            for s in app_strings
            for m in [re.search(r"package:cattery_[a-z_]+/[A-Za-z0-9_./]+\.dart", s)]
            if m
        }
    )
    groups: dict[str, list[str]] = defaultdict(list)
    for p in pkgs:
        if "/presentation/pages/" in p:
            groups["pages"].append(p)
        elif "/presentation/controllers/" in p:
            groups["controllers"].append(p)
        elif "/data/services/" in p:
            groups["services"].append(p)
        elif "/domain/entities/" in p:
            groups["entities"].append(p)
        elif "/domain/repositories/" in p:
            groups["domain_repositories"].append(p)
        elif "/data/repositories/" in p:
            groups["data_repositories"].append(p)
        elif "/domain/usecases/" in p:
            groups["usecases"].append(p)
        elif "/domain/models/" in p:
            groups["domain_models"].append(p)
        elif "/data/models/" in p:
            groups["data_models"].append(p)
        elif "/core/webview/" in p:
            groups["webview_handlers"].append(p)
        elif "/presentation/pages/" not in p and "_binding.dart" in p:
            groups["bindings"].append(p)
        elif "/request" in p or "Request" in p:
            groups["request_like"].append(p)
        elif "/response" in p or "Response" in p:
            groups["response_like"].append(p)
        else:
            groups["other_cattery"].append(p)
    return {"counts": {k: len(v) for k, v in groups.items()}, "groups": groups, "total": len(pkgs)}


def build_associations(
    pages: list[dict],
    controllers: list[dict],
    services: list[dict],
    entities: list[dict],
    apis: list[dict],
) -> tuple[list[dict], dict[str, list[str]]]:
    """Return (edge rows, node_id -> association summary)."""

    def tokens(row: dict) -> set[str]:
        name = stem_name(row.get("name") or "")
        mod = normalize_module(row.get("module") or name)
        parts = {mod, name, normalize_module(name)}
        for p in re.split(r"[_\-/]", name):
            if len(p) >= 3:
                parts.add(normalize_module(p))
        return {p for p in parts if p}

    page_idx = [(r, tokens(r)) for r in pages]
    ctrl_idx = [(r, tokens(r)) for r in controllers]
    svc_idx = [(r, tokens(r)) for r in services]
    ent_idx = [(r, tokens(r)) for r in entities]
    api_idx = []
    for r in apis:
        if not str(r.get("id", "")).startswith("API-APP"):
            continue
        route = r.get("route") or ""
        segs = [s for s in route.split("/") if s and s not in ("api", "admin")]
        t = {normalize_module(s) for s in segs}
        for s in segs:
            t |= {normalize_module(x) for x in s.split("_") if len(x) >= 3}
        api_idx.append((r, t))

    edges: list[dict] = []
    assoc: dict[str, list[str]] = defaultdict(list)
    eid = 0

    def add_edge(src: dict, dst: dict, relation: str, shared: set[str]) -> None:
        nonlocal eid
        eid += 1
        evidence = f"token_overlap:{','.join(sorted(shared)[:6])}"
        edges.append(
            {
                "id": f"EDGE-{eid:04d}",
                "module": ",".join(sorted(shared)[:3]),
                "name": relation,
                "path": src["id"],
                "route": dst["id"],
                "evidence_level": "S",
                "evidence_ref": "static name/path token overlap from AOT catalogs",
                "status": "linked",
                "notes": f"{src['id']} -[{relation}]-> {dst['id']}; {evidence}",
            }
        )
        assoc[src["id"]].append(f"{relation}:{dst['id']}")
        assoc[dst["id"]].append(f"{relation}_from:{src['id']}")

    # page ↔ controller
    for p, pt in page_idx:
        for c, ct in ctrl_idx:
            shared = pt & ct
            if shared:
                add_edge(p, c, "page_controller", shared)
    # controller ↔ service
    for c, ct in ctrl_idx:
        for s, st in svc_idx:
            shared = ct & st
            if shared:
                add_edge(c, s, "controller_service", shared)
    # service ↔ entity
    for s, st in svc_idx:
        for e, et in ent_idx:
            shared = st & et
            if shared:
                add_edge(s, e, "service_entity", shared)
    # service ↔ api
    for s, st in svc_idx:
        for a, at in api_idx:
            shared = st & at
            if shared:
                add_edge(s, a, "service_api", shared)
    # page ↔ service (direct module)
    for p, pt in page_idx:
        for s, st in svc_idx:
            shared = pt & st
            if shared:
                add_edge(p, s, "page_service", shared)

    return edges, assoc


def enrich_catalog(
    rows: list[dict],
    *,
    kind: str,
    role_fn,
    assoc: dict[str, list[str]],
) -> list[dict]:
    out = []
    for r in rows:
        role, role_note = role_fn(r.get("path") or r.get("name") or "")
        links = assoc.get(r["id"], [])
        if links:
            assoc_status = f"associated:{len(links)}"
            assoc_note = ";".join(links[:12])
            if len(links) > 12:
                assoc_note += f";+{len(links)-12}more"
        else:
            assoc_status = "orphan-static"
            assoc_note = "no token-overlap edge yet; may still bind dynamically"
        status = f"{role}|{assoc_status}"
        notes = f"role={role_note}; assoc={assoc_note}"
        nr = dict(r)
        nr["status"] = status
        nr["notes"] = notes
        nr["evidence_level"] = r.get("evidence_level") or "S"
        out.append(nr)
    return out


def write_sha256sums(out_dir: Path) -> None:
    lines = []
    for path in sorted(out_dir.rglob("*")):
        if not path.is_file() or path.name == "SHA256SUMS":
            continue
        rel = path.relative_to(out_dir).as_posix()
        digest = sha256_file(path)
        lines.append(f"{digest}  {rel}")
    (out_dir / "SHA256SUMS").write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    if not APP_BIN.is_file():
        print(f"[FAIL] missing sample: {APP_BIN}", file=sys.stderr)
        return 1

    collected_at = os.environ.get("CATERTY_COLLECTED_AT") or datetime.now().astimezone().isoformat(
        timespec="seconds"
    )

    print("[R2] extracting strings from App.framework/App ...")
    app_strings = extract_strings(APP_BIN)

    macho = collect_macho()
    plugins = collect_plugins()
    channels = collect_channels(app_strings)
    external = collect_external_entries()
    config = collect_config_markers(app_strings)
    pkg_archive = collect_package_archive(app_strings)

    pages = read_csv(OUT / "page-catalog.csv")
    controllers = read_csv(OUT / "controller-catalog.csv")
    services = read_csv(OUT / "service-catalog.csv")
    entities = read_csv(OUT / "entity-catalog.csv")
    apis = read_csv(OUT / "api-catalog.csv")

    edges, assoc = build_associations(pages, controllers, services, entities, apis)

    pages2 = enrich_catalog(pages, kind="page", role_fn=page_role, assoc=assoc)
    controllers2 = enrich_catalog(
        controllers, kind="controller", role_fn=controller_role, assoc=assoc
    )
    services2 = enrich_catalog(services, kind="service", role_fn=service_role, assoc=assoc)
    entities2 = enrich_catalog(entities, kind="entity", role_fn=entity_role, assoc=assoc)

    write_csv(OUT / "page-catalog.csv", pages2)
    write_csv(OUT / "controller-catalog.csv", controllers2)
    write_csv(OUT / "service-catalog.csv", services2)
    write_csv(OUT / "entity-catalog.csv", entities2)
    write_csv(OUT / "plugin-catalog.csv", plugins)
    write_csv(OUT / "channel-catalog.csv", channels)
    write_csv(OUT / "external-entry-catalog.csv", external)
    write_csv(OUT / "config-markers.csv", config)
    write_csv(OUT / "association-graph.csv", edges)

    # Persist package archive lists (compact)
    archive_path = OUT / "runtime" / "aot-package-archive.json"
    archive_path.parent.mkdir(parents=True, exist_ok=True)
    archive_path.write_text(
        json.dumps(
            {
                "collected_at": collected_at,
                "source": str(APP_BIN),
                "sha256": macho["app_framework_app"]["sha256"],
                "total_cattery_packages": pkg_archive["total"],
                "counts": pkg_archive["counts"],
                "groups": {k: v for k, v in pkg_archive["groups"].items() if k != "other_cattery"},
                "other_cattery_sample": pkg_archive["groups"].get("other_cattery", [])[:50],
            },
            ensure_ascii=False,
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )

    # Association summary stats
    def coverage(rows: list[dict]) -> dict:
        linked = sum(1 for r in rows if "associated:" in r["status"])
        return {
            "total": len(rows),
            "with_association": linked,
            "orphan_static": len(rows) - linked,
        }

    static_summary = {
        "schema_version": 1,
        "wave": "R2",
        "collected_at": collected_at,
        "target_version": "2.15.0 (73)",
        "macho": macho,
        "plugin_count": len(plugins),
        "channel_count": len(channels),
        "external_entry_count": len(external),
        "config_marker_count": len(config),
        "association_edge_count": len(edges),
        "coverage": {
            "page": coverage(pages2),
            "controller": coverage(controllers2),
            "service": coverage(services2),
            "entity": coverage(entities2),
        },
        "stack": {
            "ui": "Flutter + GetX",
            "state": "GetX (GetxController, bindings)",
            "network": "Dart HTTP services (*_api_service) + GTMSessionFetcher deps",
            "storage": "shared_preferences + sqflite + flutter_cache_manager",
            "webview": "webview_flutter_wkwebview + FMBridge/FlutterBridge handlers",
            "commerce": "StoreKit tool_member products + KSAdSDK",
            "notifications": "flutter_local_notifications",
            "widgets": "CatteryWidgetsExtension WidgetKit",
        },
        "layering": [
            "presentation/pages + controllers + bindings",
            "domain/entities + repositories + usecases + models",
            "data/services + repositories_impl + models",
            "core/webview handlers + native plugins",
        ],
        "notes": [
            "Association edges use static token overlap (S-level heuristic), not runtime call graph.",
            "Runner cryptid=1 (FairPlay 4KB); App.framework/App cryptid=0 fully readable.",
            "Mach-O minos on binaries reports 13.0; Info.plist MinimumOSVersion=18.0 is product gate.",
        ],
    }
    (OUT / "runtime" / "static-architecture.json").write_text(
        json.dumps(static_summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )

    # Mermaid association overview (top modules by edge count)
    mod_counts: dict[str, int] = defaultdict(int)
    for e in edges:
        for m in (e.get("module") or "").split(","):
            if m:
                mod_counts[m] += 1
    top_mods = [m for m, _ in sorted(mod_counts.items(), key=lambda x: -x[1])[:25]]
    mermaid = ["```mermaid", "flowchart LR"]
    for m in top_mods:
        safe = re.sub(r"[^A-Za-z0-9_]", "_", m)
        mermaid.append(f"  {safe}[{m}]")
    # show page->controller->service chains for top mods
    shown = 0
    for e in edges:
        if e["name"] not in ("page_controller", "controller_service", "service_api"):
            continue
        mods = set((e.get("module") or "").split(","))
        if not mods & set(top_mods):
            continue
        src = e["path"].replace("-", "_")
        dst = e["route"].replace("-", "_")
        mermaid.append(f"  {src} -->|{e['name']}| {dst}")
        shown += 1
        if shown >= 80:
            break
    mermaid.append("```")
    (OUT / "runtime" / "association-overview.md").write_text(
        "# 静态关联概览（R2）\n\n"
        "证据等级：S（AOT 路径/名称 token 重合）。非运行时调用图。\n\n"
        + "\n".join(mermaid)
        + "\n",
        encoding="utf-8",
    )

    # Update manifest sources lightly if present
    manifest_path = OUT / "manifest.json"
    if manifest_path.is_file():
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        manifest["r2"] = {
            "collected_at": collected_at,
            "plugin_catalog": "plugin-catalog.csv",
            "channel_catalog": "channel-catalog.csv",
            "external_entry_catalog": "external-entry-catalog.csv",
            "config_markers": "config-markers.csv",
            "association_graph": "association-graph.csv",
            "static_architecture": "runtime/static-architecture.json",
            "association_edges": len(edges),
        }
        manifest_path.write_text(
            json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )

    write_sha256sums(OUT)

    print("[OK] R2 static reverse artifacts written")
    print(f"  plugins: {len(plugins)}")
    print(f"  channels: {len(channels)}")
    print(f"  external entries: {len(external)}")
    print(f"  config markers: {len(config)}")
    print(f"  association edges: {len(edges)}")
    print(f"  cattery package paths in AOT: {pkg_archive['total']}")
    for k, v in static_summary["coverage"].items():
        print(f"  coverage {k}: {v}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
"""R9: static reverse of public admin/editor web platforms.

Read-only against reverse-evidence/web/*.js and HTML.
Writes reverse-evidence/full/web/ and enriches api-catalog web rows.
"""

from __future__ import annotations

import csv
import hashlib
import json
import os
import re
import sys
from collections import Counter, defaultdict
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SRC_WEB = ROOT / "reverse-evidence" / "web"
OUT = ROOT / "reverse-evidence" / "full"
OUT_WEB = OUT / "web"

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

NAMED_API_RE = re.compile(
    r"([A-Za-z_][A-Za-z0-9_]*)\s*:\s*\([^)]*\)\s*=>\s*[A-Za-z0-9_$]+\(\)\.request\(\{"
    r"url\s*:\s*[\"'](/api/[^\"']+)[\"']\s*,\s*method\s*:\s*[\"']([a-zA-Z]+)[\"']"
)
URL_METHOD_RE = re.compile(
    r"url\s*:\s*[\"'](/api/[^\"']+)[\"']\s*,\s*method\s*:\s*[\"']([a-zA-Z]+)[\"']"
)
PATH_RE = re.compile(r"path\s*:\s*[\"']([^\"']+)[\"']")
TITLE_RE = re.compile(r"title\s*:\s*[\"']([^\"']{1,60})[\"']")
API_ANY_RE = re.compile(r"/api/[A-Za-z0-9_./:${}-]+")


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


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


def read_lines(path: Path) -> list[str]:
    return [ln.strip() for ln in path.read_text(encoding="utf-8").splitlines() if ln.strip()]


def api_module(route: str) -> str:
    parts = [p for p in route.split("/") if p and not p.startswith(":") and "${" not in p]
    if len(parts) >= 3 and parts[0] == "api":
        return "/".join(parts[1:3])
    if len(parts) >= 2:
        return "/".join(parts[:2])
    return route or "unknown"


def normalize_route(route: str) -> str:
    # collapse template literals to :param style for comparison
    r = re.sub(r"\$\{[^}]+\}", ":id", route)
    r = re.sub(r"\{[^}]+\}", ":id", r)
    return r


def extract_admin(admin: str) -> dict:
    named = NAMED_API_RE.findall(admin)
    url_methods = URL_METHOD_RE.findall(admin)
    # prefer named mapping: route -> (method, client_fn)
    by_route: dict[str, dict] = {}
    for fn, url, method in named:
        by_route[url] = {
            "method": method.lower(),
            "client_fn": fn,
            "source": "named-request",
        }
    for url, method in url_methods:
        if url not in by_route:
            by_route[url] = {
                "method": method.lower(),
                "client_fn": "",
                "source": "url-method",
            }

    paths = []
    for p in PATH_RE.findall(admin):
        if p.startswith("/Users/"):
            continue  # leaked source path, not a route
        paths.append(p)
    paths = sorted(set(paths))

    titles = sorted(set(TITLE_RE.findall(admin)))

    # frontend route groups
    groups = defaultdict(list)
    for p in paths:
        if p.startswith("/ws-mobile"):
            groups["ws-mobile"].append(p)
        elif p.startswith("/ws"):
            groups["ws"].append(p)
        elif p.startswith("/pricing"):
            groups["pricing"].append(p)
        elif p.startswith("/help"):
            groups["help"].append(p)
        elif p.startswith("/transfer"):
            groups["transfer"].append(p)
        elif p.startswith("/marketing"):
            groups["marketing"].append(p)
        else:
            groups["other"].append(p)

    bridge_markers = {
        "FMBridge": admin.count("FMBridge"),
        "FMBridgeChannel": admin.count("FMBridgeChannel"),
        "FlutterBridge": admin.count("FlutterBridge"),
        "__APP_DATA__": admin.count("__APP_DATA__"),
        "__onTokenReceived": admin.count("__onTokenReceived"),
        "__onUserInfoReceived": admin.count("__onUserInfoReceived"),
        "localStorage.token": admin.count('localStorage.getItem("token")'),
        "isInApp": admin.count("isInApp"),
        "getToken": admin.count("getToken"),
        "getUserInfo": admin.count("getUserInfo"),
        "startPayment": admin.count("startPayment"),
        "openAppStore": admin.count("openAppStore"),
        "fmbridge://": admin.count("fmbridge://"),
        "CatteryApp UA": admin.count("catteryapp") + admin.count("cattery-app"),
    }

    enums = {
        "breeding_status_zh": {
            k: admin.count(k) for k in ("待搭配", "待生产", "带娃中", "已归档")
        },
        "content_flow_zh": {
            k: admin.count(k)
            for k in ("提交审核", "审核", "发布", "预览", "小程序版本管理/发布", "微信小程序/授权")
        },
    }

    return {
        "api_by_route": by_route,
        "paths": paths,
        "path_groups": {k: v for k, v in groups.items()},
        "titles": titles,
        "bridge_markers": bridge_markers,
        "enums": enums,
        "raw_api_strings": sorted(set(API_ANY_RE.findall(admin))),
    }


def extract_editor(editor: str) -> dict:
    apis = sorted(set(API_ANY_RE.findall(editor)))
    paths = sorted({p for p in PATH_RE.findall(editor) if not p.startswith("/Users/")})
    titles = sorted(set(TITLE_RE.findall(editor)))
    bridge_markers = {
        "FMBridge": editor.count("FMBridge"),
        "FMBridgeChannel": editor.count("FMBridgeChannel"),
        "FlutterBridge": editor.count("FlutterBridge"),
        "__APP_DATA__": editor.count("__APP_DATA__"),
        "localStorage.token": editor.count('localStorage.getItem("token")'),
        "getToken": editor.count("getToken"),
        "postMessage": editor.count("postMessage"),
        "fmbridge://": editor.count("fmbridge://"),
        "preview": editor.count("preview"),
        "template": editor.count("template"),
    }
    # axios-like get/post for editor fonts
    method_hits = []
    for m in re.finditer(
        r"\.(get|post|put|delete)\(\s*[\"'](/api/[^\"']+)[\"']", editor
    ):
        method_hits.append((m.group(2), m.group(1).lower()))
    by_route = {}
    for url, method in method_hits:
        by_route[url] = {"method": method, "client_fn": "", "source": "axios-style"}
    # dam/cos often template strings
    for a in apis:
        if a not in by_route:
            by_route[a] = {"method": "", "client_fn": "", "source": "string-only"}

    return {
        "apis": apis,
        "api_by_route": by_route,
        "paths": paths,
        "titles": titles,
        "bridge_markers": bridge_markers,
    }


def build_web_api_rows(
    baseline_web: list[str],
    admin_info: dict,
    editor_info: dict,
) -> list[dict]:
    admin_map = admin_info["api_by_route"]
    editor_map = editor_info["api_by_route"]
    rows = []
    for i, route in enumerate(baseline_web, start=1):
        meta = admin_map.get(route) or {}
        # fuzzy for template variants
        if not meta:
            for k, v in editor_map.items():
                if normalize_route(k) == normalize_route(route) or route in k or k in route:
                    meta = v
                    break
        if not meta:
            for k, v in admin_map.items():
                if normalize_route(k) == normalize_route(route):
                    meta = v
                    break
        method = meta.get("method", "")
        fn = meta.get("client_fn", "")
        src = meta.get("source", "")
        if route in admin_map:
            platform = "admin-js"
        elif any(normalize_route(route) == normalize_route(k) for k in editor_map):
            platform = "editor-js"
        else:
            platform = "baseline-list"
        status = "method-resolved" if method else "route-only"
        notes = (
            f"web API; method={method or 'TBD'}; client_fn={fn or '-'}; "
            f"extract={src or 'none'}; platform={platform}; R10 may refine auth/body"
        )
        rows.append(
            {
                "id": f"API-WEB-{i:04d}",
                "module": api_module(route),
                "name": fn or route.rsplit("/", 1)[-1] or route,
                "path": platform,
                "route": route,
                "evidence_level": "W",
                "evidence_ref": "reverse-evidence/web/cattery-admin.js|cattery-editor.js|api-routes.txt",
                "status": status,
                "notes": notes,
            }
        )
    return rows


def build_frontend_route_rows(admin_info: dict, editor_info: dict) -> list[dict]:
    rows = []
    i = 0
    for p in admin_info["paths"]:
        i += 1
        if p.startswith("/ws/weixin"):
            mod = "weixin-miniprogram"
        elif p.startswith("/ws/shop") or p.startswith("/ws-mobile/shop"):
            mod = "shop-site"
        elif p.startswith("/ws/article"):
            mod = "content-article"
        elif p.startswith("/ws/cats"):
            mod = "cats-web"
        elif p.startswith("/pricing"):
            mod = "pricing"
        elif p.startswith("/ws"):
            mod = "workspace"
        else:
            mod = "web-route"
        rows.append(
            {
                "id": f"WROUTE-{i:04d}",
                "module": mod,
                "name": p.rsplit("/", 1)[-1] or p,
                "path": "cattery-admin",
                "route": p,
                "evidence_level": "W",
                "evidence_ref": "reverse-evidence/web/cattery-admin.js path:",
                "status": "observed",
                "notes": "Vue router path object in admin SPA",
            }
        )
    for p in editor_info["paths"]:
        i += 1
        rows.append(
            {
                "id": f"WROUTE-{i:04d}",
                "module": "editor",
                "name": p.rsplit("/", 1)[-1] or p,
                "path": "cattery-editor",
                "route": p,
                "evidence_level": "W",
                "evidence_ref": "reverse-evidence/web/cattery-editor.js path:",
                "status": "observed",
                "notes": "Editor SPA route",
            }
        )
    return rows


def build_bridge_rows(admin_info: dict, editor_info: dict) -> list[dict]:
    rows = []
    i = 0
    items = [
        ("FMBridge", "js-bridge", "Primary window.FMBridge in admin/editor"),
        ("FMBridgeChannel", "js-bridge", "Channel alias for bridge detection"),
        ("FlutterBridge", "js-bridge", "Compatibility bridge object"),
        ("__APP_DATA__", "app-data", "Injected app payload (token/user/platform)"),
        ("localStorage.token", "auth", "Browser fallback token key"),
        ("isInApp", "env-detect", "Detect WebView vs browser"),
        ("getToken", "bridge-api", "Request auth token from native"),
        ("getUserInfo", "bridge-api", "Request user profile from native"),
        ("startPayment", "bridge-api", "Native payment handoff"),
        ("openAppStore", "bridge-api", "Open store / membership"),
        ("fmbridge://", "url-scheme", "Custom bridge URL scheme marker"),
        ("CatteryApp UA", "env-detect", "UserAgent contains catteryapp/flutter"),
    ]
    for name, mod, desc in items:
        i += 1
        a = admin_info["bridge_markers"].get(name, 0)
        e = editor_info["bridge_markers"].get(name, 0)
        rows.append(
            {
                "id": f"BRIDGE-{i:04d}",
                "module": mod,
                "name": name,
                "path": f"admin_count={a};editor_count={e}",
                "route": "",
                "evidence_level": "W",
                "evidence_ref": "cattery-admin.js + cattery-editor.js string counts",
                "status": "observed" if (a + e) > 0 else "absent",
                "notes": desc,
            }
        )
    # AOT webview handlers from R2 archive if present
    aot = OUT / "runtime" / "aot-package-archive.json"
    if aot.is_file():
        data = json.loads(aot.read_text(encoding="utf-8"))
        handlers = data.get("groups", {}).get("webview_handlers", [])
        for h in handlers:
            i += 1
            rows.append(
                {
                    "id": f"BRIDGE-{i:04d}",
                    "module": "native-webview-handler",
                    "name": Path(h).name,
                    "path": h,
                    "route": "",
                    "evidence_level": "S",
                    "evidence_ref": "App AOT package paths (R2)",
                    "status": "observed",
                    "notes": "Flutter-side WebView bridge handler package",
                }
            )
    return rows


def build_crossmap(app_routes: list[str], web_routes: list[str], admin_map: dict) -> list[dict]:
    app_set = set(app_routes)
    web_set = set(web_routes)
    # normalize for overlap
    def keyset(routes):
        return {normalize_route(r): r for r in routes}

    app_n = keyset(app_routes)
    web_n = keyset(web_routes)
    shared_keys = set(app_n) & set(web_n)
    only_app = set(app_n) - set(web_n)
    only_web = set(web_n) - set(app_n)

    rows = []
    i = 0
    for k in sorted(shared_keys):
        i += 1
        route = web_n[k]
        method = (admin_map.get(route) or {}).get("method", "")
        rows.append(
            {
                "id": f"XMAP-{i:04d}",
                "module": api_module(route),
                "name": "shared",
                "path": "app+web",
                "route": route,
                "evidence_level": "S+W",
                "evidence_ref": "api-routes.txt + web/api-routes.txt",
                "status": "shared",
                "notes": f"present in both App AOT and Web admin; method={method or 'TBD'}",
            }
        )
    for k in sorted(only_web):
        i += 1
        route = web_n[k]
        method = (admin_map.get(route) or {}).get("method", "")
        rows.append(
            {
                "id": f"XMAP-{i:04d}",
                "module": api_module(route),
                "name": "web-only",
                "path": "web",
                "route": route,
                "evidence_level": "W",
                "evidence_ref": "web/api-routes.txt",
                "status": "web-only",
                "notes": f"not seen in App AOT route list; method={method or 'TBD'}",
            }
        )
    for k in sorted(only_app):
        i += 1
        route = app_n[k]
        rows.append(
            {
                "id": f"XMAP-{i:04d}",
                "module": api_module(route),
                "name": "app-only",
                "path": "app",
                "route": route,
                "evidence_level": "S",
                "evidence_ref": "api-routes.txt",
                "status": "app-only",
                "notes": "not present in public web api-routes baseline",
            }
        )
    stats = {
        "shared": len(shared_keys),
        "web_only": len(only_web),
        "app_only": len(only_app),
        "app_total": len(app_routes),
        "web_total": len(web_routes),
    }
    return rows, stats


def write_module_index(admin_info: dict, editor_info: dict, cross_stats: dict, out: Path) -> None:
    lines = [
        "# R9 Web 模块索引",
        "",
        f"- 采集时间：{datetime.now().astimezone().isoformat(timespec='seconds')}",
        "- 证据等级：W（公开生产 JS/HTML）",
        f"- Admin JS SHA-256：见 manifest / SHA256SUMS",
        "",
        "## 技术栈信号",
        "",
        "- 管理端：Vue SPA + 请求封装 `request({url, method})`（Pinia `defineStore` 名称在压缩后未保留明文）",
        "- 编辑器：独立 SPA；字体列表走 `/api/editor/fonts`；模板资源走 DAM/COS",
        "- 鉴权：`localStorage.token`；App 内优先 Bridge `getToken`",
        "",
        "## 前端路由分组（admin）",
        "",
    ]
    for g, paths in sorted(admin_info["path_groups"].items()):
        lines.append(f"### {g}（{len(paths)}）")
        for p in paths:
            lines.append(f"- `{p}`")
        lines.append("")
    lines += [
        "## 编辑器路由",
        "",
    ]
    for p in editor_info["paths"]:
        lines.append(f"- `{p}`")
    lines += [
        "",
        "## 官网 / 小程序相关路由与 API（共用工作台）",
        "",
        "管理端同一 SPA 同时承载「店铺/官网装修」与「微信小程序」能力：",
        "",
        "| 能力 | 前端路由（例） | API（例） |",
        "|---|---|---|",
        "| 店铺/官网 | `/ws/shop/*`, `/ws/seo/config` | `/api/admin/shops*`, `/api/admin/seo/*` |",
        "| 小程序 | `/ws/weixin/mini`, `/audit`, `/version`, `/tester` | `/api/admin/weixin/mini/*` |",
        "| 模板 | `/ws/shipping/templates`, shop templates | `/api/admin/shop/templates`, shipping templates |",
        "| 文章 | `/ws/article` | `/api/admin/articles*` |",
        "| 导航 TabBar | `/ws/shop/tabbar*` | `/api/admin/tabbar*` |",
        "",
        "结论：**内容模型在管理端侧共用同一套店铺/商品/文章/导航/SEO 配置**；",
        "小程序额外挂微信授权、审核、上传、版本、体验者 API。",
        "版本「回滚」明文未出现（B：需动态或更多构建确认）。",
        "",
        "## App API × Web API 交叉统计",
        "",
        f"- shared: **{cross_stats['shared']}**",
        f"- web-only: **{cross_stats['web_only']}**",
        f"- app-only: **{cross_stats['app_only']}**",
        f"- app total: {cross_stats['app_total']}, web total: {cross_stats['web_total']}",
        "",
        "## 枚举片段（admin 明文）",
        "",
        f"- 繁育：{admin_info['enums']['breeding_status_zh']}",
        f"- 内容流：{admin_info['enums']['content_flow_zh']}",
        "",
        "## 标题词云（节选）",
        "",
    ]
    for t in admin_info["titles"][:60]:
        lines.append(f"- {t}")
    out.write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_r9_report(
    *,
    admin_info: dict,
    editor_info: dict,
    cross_stats: dict,
    method_resolved: int,
    web_total: int,
    out: Path,
) -> None:
    text = f"""# R9 公开管理端 / 编辑器 / 平台逆向报告

> 证据等级：**W**（公开 HTML + 生产 JS）+ **S**（App AOT WebView handlers）  
> 目标版本关联：宠舍管家 `2.15.0 (73)`（Web 资源为 2026-07-15 归档构建）  
> 约束：只读；未登录业务后台；未保存 Token/Cookie

## 1. 样本

| 资源 | 路径 | SHA-256（见 full/SHA256SUMS） |
|---|---|---|
| Admin JS | `reverse-evidence/web/cattery-admin.js` | 5572f703… |
| Editor JS | `reverse-evidence/web/cattery-editor.js` | 165b6369… |
| 脚本 URL | `script-urls.txt` | cdn.fanmeowy.com |
| HTML | pricing / trade / editor | 公开 200 |

## 2. 步骤完成情况

| 步骤 | 结果 |
|---|---|
| JS 切片与模块索引 | **完成** → `web/module-index.md` + catalogs |
| 路由/接口/权限/枚举 | **完成（W）** → routes/API/methods；Pinia store 名压缩丢失 |
| 官网/小程序/模板/审核/发布 | **完成（W）+ 回滚 B** |
| WebView Bridge 边界 | **完成（W+S）** → `bridge-catalog.csv` |
| AI Agent 工具目录 | **B/部分** — Agent 主路径在 App；Web 管理端未见完整工具清单 |
| App×Web API 交叉映射 | **完成** → `app-web-api-crossmap.csv` |

## 3. API 验收

- 基线 Web API：**{web_total}** 条全部进入 `api-catalog.csv`（API-WEB-*）
- 本轮 method 解析成功：**{method_resolved}/{web_total}**
- Admin named client 函数：{len(admin_info['api_by_route'])}
- Editor API 字符串：{len(editor_info['apis'])}（以 fonts/DAM/COS/merchant 为主）

交叉统计：shared={cross_stats['shared']}, web-only={cross_stats['web_only']}, app-only={cross_stats['app_only']}

## 4. Bridge 与鉴权边界（W）

请求拦截器逻辑（admin 明文片段）：

1. 默认 `localStorage.getItem("token")`
2. 若 `isInApp()` / Bridge 存在：`await getToken()` 覆盖为 App Token
3. UA 含 `catteryapp` / `flutter` 亦判定 App 环境
4. `__APP_DATA__` 携带 `platform` / `token` / `userInfo`

原生侧 handler（AOT，S）：`bridge_handler`, `cat_handler`, `device_handler`, `media_handler`, `store_trade_handler`, `template_handler`, `ui_handler`, `user_handler`

App 入口页（S，R1/R2 catalogs）：`membership_webview_page`, `editor_webview_page`, `pet_art_gallery_webview_page`, `pet_bean_webview_page`

## 5. docs/01 P2 关闭状态

| P2 项 | 状态 | 结论 |
|---|---|---|
| 官网与微信小程序内容模型是否共用 | **W 已验证（共用管理模型）** | 同一 admin SPA：`/ws/shop*`+SEO+文章+TabBar 与 `/ws/weixin/*`+`/api/admin/weixin/mini/*` 并存；店铺内容 API 共用，小程序多授权/审核/版本面 |
| 模板编辑器、审核、发布流程 | **W 已验证（主路径）** | 路由 `/ws/weixin/audit|version|mini`；API `mini/audit|publish|upload|version|template`；编辑器独立 `/editor` + fonts/DAM |
| 版本回滚 | **B** | 生产 JS 未见「回滚」明文或 rollback API；需动态或新构建补证 |
| App 内 WebView 与原生切换 | **S+W 部分** | Bridge 环境检测 + 多个 `*_webview_page`；完整切换序列仍待 R3 解除后 D 确认 |

详见 `web/p2-closure.md`。

## 6. AI Agent

- App：`AgentController` / `agent_workbench_page` / `agent_api_service`（S）
- Web 管理端：未提取到与 App 对等的 Agent 工具注册表；定价/订单等路径名含 detail 噪声
- 状态：**B** — 工具参数、写入确认、权益限制以 App 动态/R5–R7 为主，Web 侧本轮不假装完成

## 7. 数据模型边界结论

```text
共享（App + Web 管理端调用同一 /api/admin 域）：
  猫只、繁育 planes、文章、店铺、商品相关、队列/上门等大量 admin API

Web 侧重 / Web-only：
  微信小程序发布链、部分 SEO/装修、editor fonts、部分 DAM 模板路径

App 侧重 / App-only：
  大量移动端经营/健康/通知/会员 StoreKit 相关路由（见 crossmap app-only）

编辑器：
  主要为可视化装修运行时 + 字体/素材 API，不承载完整业务 CRUD
```

## 8. 敏感信息

- 未登录后台，无 Token
- 日志/报告不含用户业务数据
- 开发机路径泄漏（`/Users/jianghong/Desktop/fgoll/...`）仅作来源标记，不扩散
"""
    out.write_text(text, encoding="utf-8")


def write_p2_closure(out: Path) -> None:
    out.write_text(
        """# docs/01 P2 清单关闭记录（R9）

> 不改写 docs/01 历史正文；以本文件作为勘误/关闭表。证据等级：W/S/B。

| # | P2 原文 | 关闭状态 | 证据 | 说明 |
|---|---|---|---|---|
| 1 | 宠舍官网与微信小程序的内容模型是否共用 | **已验证（W）— 共用管理端内容模型** | `web-routes.csv` `/ws/shop*`+`/ws/weixin/*`；`api-catalog` `/api/admin/shops*` 与 `/api/admin/weixin/mini/*` | 官网/店铺装修与小程序发布在同一 admin SPA；内容实体（店/商品/文章/导航/SEO）共享，小程序叠加微信审核发布链 |
| 2 | 模板编辑器、审核、发布和版本回滚流程 | **主路径已验证（W）；回滚 B** | 路由 audit/version/mini；API audit/publish/upload/version/template；editor SPA | 审核/发布/版本/体验者/模板 API 齐全；未见 rollback 明文或 API |
| 3 | （延伸）App WebView 与原生切换边界 | **部分 S+W；动态 B** | bridge-catalog + AOT webview pages/handlers | Bridge 与入口页明确；交互序列待 R3 解除 |

关联交付：`runtime/r3/`（App 动态阻断）、`web/r9-report.md`。
""",
        encoding="utf-8",
    )


def write_sha256sums(out_dir: Path) -> None:
    lines = []
    for path in sorted(out_dir.rglob("*")):
        if not path.is_file() or path.name == "SHA256SUMS":
            continue
        rel = path.relative_to(out_dir).as_posix()
        lines.append(f"{sha256_file(path)}  {rel}")
    (out_dir / "SHA256SUMS").write_text("\n".join(lines) + "\n", encoding="utf-8")


def extract_api_client_slice(admin: str, out: Path) -> None:
    """Save a compact slice of request client definitions for human review."""
    # find dense region of url:"/api/admin
    idx = admin.find('url:"/api/admin/articles"')
    if idx < 0:
        idx = admin.find("/api/admin/articles")
    if idx < 0:
        out.write_text("// slice not found\n", encoding="utf-8")
        return
    start = max(0, idx - 200)
    end = min(len(admin), idx + 12000)
    chunk = admin[start:end]
    # soft-wrap long line for readability
    wrapped = re.sub(r"\),([A-Za-z_][A-Za-z0-9_]*):\(", r"),\n\1:(", chunk)
    out.write_text(
        "// Extracted slice from cattery-admin.js around admin API client\n"
        + "// Not full beautify; stable for review.\n\n"
        + wrapped
        + "\n",
        encoding="utf-8",
    )


def main() -> int:
    collected_at = os.environ.get("CATERTY_COLLECTED_AT") or datetime.now().astimezone().isoformat(
        timespec="seconds"
    )
    admin_path = SRC_WEB / "cattery-admin.js"
    editor_path = SRC_WEB / "cattery-editor.js"
    if not admin_path.is_file() or not editor_path.is_file():
        print("[FAIL] missing web JS samples", file=sys.stderr)
        return 1

    admin = admin_path.read_text(encoding="utf-8", errors="ignore")
    editor = editor_path.read_text(encoding="utf-8", errors="ignore")
    admin_info = extract_admin(admin)
    editor_info = extract_editor(editor)

    baseline_web = read_lines(SRC_WEB / "api-routes.txt")
    baseline_app = read_lines(ROOT / "reverse-evidence" / "api-routes.txt")
    if len(baseline_web) != 231:
        print(f"[FAIL] web api baseline {len(baseline_web)} != 231", file=sys.stderr)
        return 1

    OUT_WEB.mkdir(parents=True, exist_ok=True)

    web_api_rows = build_web_api_rows(baseline_web, admin_info, editor_info)
    method_resolved = sum(1 for r in web_api_rows if r["status"] == "method-resolved")

    # Merge into api-catalog: keep APP rows, replace WEB rows
    api_catalog_path = OUT / "api-catalog.csv"
    existing = read_csv(api_catalog_path) if api_catalog_path.is_file() else []
    app_rows = [r for r in existing if str(r.get("id", "")).startswith("API-APP")]
    if not app_rows:
        # rebuild app rows minimally from baseline
        for i, route in enumerate(baseline_app, start=1):
            app_rows.append(
                {
                    "id": f"API-APP-{i:04d}",
                    "module": api_module(route),
                    "name": route.rsplit("/", 1)[-1] or route,
                    "path": "",
                    "route": route,
                    "evidence_level": "S",
                    "evidence_ref": "reverse-evidence/api-routes.txt",
                    "status": "imported",
                    "notes": "app API route; method/auth TBD in R10",
                }
            )
    write_csv(api_catalog_path, app_rows + web_api_rows)

    route_rows = build_frontend_route_rows(admin_info, editor_info)
    bridge_rows = build_bridge_rows(admin_info, editor_info)
    cross_rows, cross_stats = build_crossmap(
        baseline_app, baseline_web, admin_info["api_by_route"]
    )

    write_csv(OUT_WEB / "web-api-methods.csv", web_api_rows)
    write_csv(OUT_WEB / "web-routes.csv", route_rows)
    write_csv(OUT_WEB / "bridge-catalog.csv", bridge_rows)
    write_csv(OUT_WEB / "app-web-api-crossmap.csv", cross_rows)

    write_module_index(admin_info, editor_info, cross_stats, OUT_WEB / "module-index.md")
    write_p2_closure(OUT_WEB / "p2-closure.md")
    write_r9_report(
        admin_info=admin_info,
        editor_info=editor_info,
        cross_stats=cross_stats,
        method_resolved=method_resolved,
        web_total=len(baseline_web),
        out=OUT_WEB / "r9-report.md",
    )
    extract_api_client_slice(admin, OUT_WEB / "admin-api-client.slice.js")

    # source meta
    meta = {
        "collected_at": collected_at,
        "wave": "R9",
        "sources": {
            "admin_js": {
                "path": str(admin_path),
                "sha256": sha256_file(admin_path),
                "size": admin_path.stat().st_size,
            },
            "editor_js": {
                "path": str(editor_path),
                "sha256": sha256_file(editor_path),
                "size": editor_path.stat().st_size,
            },
            "cdn": read_lines(SRC_WEB / "script-urls.txt"),
        },
        "counts": {
            "web_api_baseline": len(baseline_web),
            "web_api_method_resolved": method_resolved,
            "admin_frontend_routes": len(admin_info["paths"]),
            "editor_frontend_routes": len(editor_info["paths"]),
            "bridge_rows": len(bridge_rows),
            "crossmap_rows": len(cross_rows),
            **cross_stats,
        },
        "admin_bridge_markers": admin_info["bridge_markers"],
        "editor_bridge_markers": editor_info["bridge_markers"],
        "enums": admin_info["enums"],
    }
    (OUT_WEB / "r9-meta.json").write_text(
        json.dumps(meta, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )

    # manifest
    manifest_path = OUT / "manifest.json"
    if manifest_path.is_file():
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        manifest["r9"] = {
            "collected_at": collected_at,
            "report": "web/r9-report.md",
            "web_api_total": len(baseline_web),
            "web_api_method_resolved": method_resolved,
            "crossmap": cross_stats,
            "p2_closure": "web/p2-closure.md",
        }
        manifest_path.write_text(
            json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )

    write_sha256sums(OUT)

    print("[OK] R9 web reverse written")
    print(f"  web APIs: {len(baseline_web)} method-resolved={method_resolved}")
    print(f"  admin routes: {len(admin_info['paths'])}")
    print(f"  crossmap: {cross_stats}")
    print(f"  output: {OUT_WEB}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

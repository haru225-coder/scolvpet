#!/usr/bin/env python3
"""R10: merge App/Web APIs, infer methods/auth, P0 contracts, docs/11.

Read-only against reverse-evidence baselines and R9 web extracts.
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
SRC = ROOT / "reverse-evidence"
OUT = SRC / "full"
OUT_API = OUT / "api"
DOCS = ROOT / "docs"

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

# P0 domains for deep contract rows (static evidence only).
P0_PREFIXES = (
    "/api/admin/app/login",
    "/api/admin/sms",
    "/api/admin/account",
    "/api/admin/entitlements",
    "/api/admin/cats",
    "/api/admin/cat/planes",
    "/api/admin/cat/weights",
    "/api/admin/breeding",
    "/api/admin/weixin/mini",
    "/api/admin/auth",
    "/api/admin/cos/upload",
    "/api/admin/dam/",
    "/api/editor/fonts",
    "/api/admin/member",
    "/api/admin/merchant",
)

P1_PREFIXES = (
    "/api/admin/boarding",
    "/api/admin/queue",
    "/api/admin/queues",
    "/api/admin/door",
    "/api/admin/doors",
    "/api/admin/grooming",
    "/api/admin/accounting",
    "/api/admin/contract",
    "/api/admin/receipt",
    "/api/admin/goods",
    "/api/admin/shops",
    "/api/admin/articles",
    "/api/admin/seo",
    "/api/admin/tabbar",
    "/api/admin/health",
    "/api/admin/event",
    "/api/admin/calendar",
    "/api/admin/agent",
    "/api/admin/ai",
    "/api/admin/point",
    "/api/admin/product",
)


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


def normalize_route(route: str) -> str:
    r = route.strip()
    r = re.sub(r"\$\{[^}]+\}", ":param", r)
    r = re.sub(r"\{[^}]+\}", ":param", r)
    # unify trailing id patterns without colon (app list often ends with /)
    r = re.sub(r"/+", "/", r)
    if len(r) > 1 and r.endswith("/") and not r.endswith(":id/"):
        # keep trailing slash as distinct from non-slash in raw, but normalize key
        pass
    # App routes like /api/admin/cat/planes/confirm/ ≈ web /confirm/:id
    r_key = r.rstrip("/")
    r_key = re.sub(r"/:\w+", "/:param", r_key)
    # treat bare trailing action dirs as needing :param
    return r_key


def api_module(route: str) -> str:
    parts = [p for p in route.split("/") if p and not p.startswith(":") and "${" not in p]
    if len(parts) >= 3 and parts[0] == "api":
        return "/".join(parts[1:3])
    if len(parts) >= 2:
        return "/".join(parts[:2])
    return "unknown"


def path_params(route: str) -> list[str]:
    params = re.findall(r":([A-Za-z_][A-Za-z0-9_]*)", route)
    # app-style incomplete trailing slash actions imply :id
    if route.rstrip("/").endswith(
        ("/detail", "/delete", "/update", "/confirm", "/archive", "/breeding", "/weights")
    ) or re.search(r"/(detail|delete|update|confirm|archive|breeding|weights)/$", route):
        if "id" not in params and ":id" not in route:
            params = params + ["id?"]
    return params


def infer_method_from_path(route: str) -> tuple[str, str]:
    """Return (method, confidence) where confidence is high|medium|low|unknown."""
    r = route.lower().rstrip("/")
    leaf = r.rsplit("/", 1)[-1]
    # explicit CRUD suffixes
    if leaf in ("add", "create", "register", "upload", "record", "accept") or r.endswith(
        "/add"
    ):
        return "post", "medium"
    if leaf in ("delete",) or "/delete/" in r + "/" or r.endswith("/delete"):
        return "delete", "medium"
    if leaf in (
        "update",
        "confirm",
        "archive",
        "breeding",
        "bind",
        "publish",
        "audit",
        "show",
        "recover",
    ) or any(
        x in r
        for x in (
            "/update/",
            "/confirm/",
            "/archive/",
            "/breeding/",
            "/set-",
            "/bind/",
        )
    ):
        return "put", "medium"
    if leaf in ("list", "detail", "info", "categories", "pages", "version", "template"):
        return "get", "medium"
    # collection root often GET
    if leaf in (
        "cats",
        "planes",
        "articles",
        "brands",
        "shops",
        "entitlements",
        "account",
        "sms",
        "merchant",
        "tabbar",
        "fonts",
    ):
        return "get", "low"
    if "login" in r:
        return "post", "medium"
    return "", "unknown"


def parse_admin_methods(admin_js: str) -> dict[str, dict]:
    out: dict[str, dict] = {}
    for fn, url, method in NAMED_API_RE.findall(admin_js):
        out[url] = {
            "method": method.lower(),
            "client_fn": fn,
            "source": "web-admin-named-request",
            "level": "W",
        }
    # axios-style in editor may be loaded separately
    return out


def match_web_method(route: str, web_map: dict[str, dict]) -> dict | None:
    if route in web_map:
        return web_map[route]
    n = normalize_route(route)
    # try with :id variants
    candidates = [
        route,
        route.rstrip("/"),
        route.rstrip("/") + "/:id",
        re.sub(r"/+$", "", route) + "/:id",
    ]
    for c in candidates:
        if c in web_map:
            return web_map[c]
    for k, v in web_map.items():
        if normalize_route(k) == n:
            return v
        # app /confirm/ vs web /confirm/:id
        kn = normalize_route(k)
        if n.rstrip("/") + "/:param" == kn or kn.rstrip("/") + "/:param" == n:
            return v
        if n.replace("/:param", "") == kn.replace("/:param", ""):
            return v
    return None


def priority(route: str) -> str:
    for p in P0_PREFIXES:
        if route.startswith(p):
            return "P0"
    for p in P1_PREFIXES:
        if route.startswith(p):
            return "P1"
    return "P2"


def auth_model(route: str) -> dict:
    # public-ish
    pub = any(
        x in route
        for x in (
            "/login",
            "/sms",
            "/help",
            "/pricing",
            "/breeding/invite/",
        )
    )
    if pub and "invite" not in route:
        return {
            "auth": "likely-public-or-pre-session",
            "auth_evidence": "I",
            "notes": "login/sms typically pre-auth; still confirm dynamically",
        }
    return {
        "auth": "bearer-or-token-header",
        "auth_evidence": "W",
        "notes": "admin interceptor uses localStorage.token or App Bridge getToken; Authorization header used by HTTP stack",
    }


def idempotent_hint(method: str, route: str) -> str:
    m = (method or "").lower()
    if m in ("get", "head", "options"):
        return "yes-safe"
    if m == "put" and any(x in route for x in ("/update", "/confirm", "/archive", "/set-")):
        return "likely-idempotent-put"
    if m == "delete":
        return "likely-idempotent-delete"
    if m == "post":
        if any(x in route for x in ("/add", "/create", "/upload", "/record", "/login")):
            return "non-idempotent-create"
        return "unknown-post"
    return "unknown"


def entity_links(route: str, entities: list[str], services: list[str]) -> dict:
    tokens = set(re.findall(r"[a-z]+", route.lower()))
    # map common
    alias = {
        "cats": "cat",
        "planes": "breeding_plan",
        "plane": "breeding_plan",
        "articles": "article",
        "brands": "brand",
        "shops": "shop",
        "queues": "queue",
        "doors": "door",
        "weights": "weight",
        "entitlements": "entitlement",
        "member": "member",
        "merchant": "merchant",
        "boarding": "boarding",
        "grooming": "grooming",
        "receipt": "receipt",
        "contract": "contract",
        "agent": "agent",
    }
    hits_e = []
    hits_s = []
    for t in tokens:
        key = alias.get(t, t)
        for e in entities:
            en = e.rsplit("/", 1)[-1].replace(".g.dart", "").replace(".dart", "")
            if key in en or en in key:
                hits_e.append(en)
        for s in services:
            sn = s.rsplit("/", 1)[-1].replace(".dart", "")
            if key in sn:
                hits_s.append(sn)
    return {
        "entities": sorted(set(hits_e))[:8],
        "services": sorted(set(hits_s))[:8],
    }


def p0_contract_row(route: str, method: str, meta: dict) -> dict:
    """Static contract skeleton; body/response marked B when not dynamically observed."""
    params = path_params(route)
    auth = auth_model(route)
    pri = priority(route)
    # known structural hints from web/static
    req_fields = "B-not-observed-runtime"
    resp_fields = "B-not-observed-runtime"
    errors = "B-not-observed-runtime"
    pagination = "none-or-unknown"
    notes = []

    if method == "get" and not params:
        pagination = "page/pageSize-or-limit possible (admin uses pageSize)"
        notes.append("list-like GET; pagination params common in admin SPA")
    if "login" in route:
        req_fields = "I: phone/code or apple credential fields likely; exact keys B"
        resp_fields = "I: token + user profile likely; exact schema B"
        errors = "I: invalid code / rate limit likely; codes B"
        notes.append("pre-session auth")
    if route.endswith("/sms") or route.endswith("/sms"):
        req_fields = "I: phone number; exact key B"
        resp_fields = "I: send-result; B"
    if "entitlements" in route:
        req_fields = "none-or-empty"
        resp_fields = "I: capacity/module limits object; field names B (see membership static report)"
        notes.append("membership gate")
    if "planes" in route and "confirm" in route:
        req_fields = "I: ConfirmProduction-like payload; App has ConfirmProductionRequest string; fields B"
        resp_fields = "I: updated plane + side effects; B"
        notes.append("breeding state transition P0")
    if "planes" in route and "archive" in route:
        req_fields = "I: archive reason/flags possible; B"
        notes.append("breeding archive transition")
    if "weights" in route:
        req_fields = "I: weight records array/cat ids; B"
        notes.append("weight / newborn monitoring")
    if "weixin/mini" in route:
        notes.append("miniprogram publish chain")
    if "upload" in route or "cos" in route or "dam" in route:
        req_fields = "I: multipart/form-data or signed upload; FormData seen in admin"
        notes.append("upload path")
        pagination = "n/a"

    status = "p0-skeleton" if pri == "P0" else "p1-skeleton"
    if method:
        analysis = "method-resolved" if meta.get("method_source", "").startswith("web") else "method-inferred"
    else:
        analysis = "method-unknown"
        status = "blocked-method"

    return {
        "route": route,
        "priority": pri,
        "method": method or "",
        "method_source": meta.get("method_source", ""),
        "path_params": params,
        "query_params": pagination,
        "auth": auth["auth"],
        "auth_evidence": auth["auth_evidence"],
        "idempotency": idempotent_hint(method, route),
        "request_body": req_fields,
        "response_body": resp_fields,
        "errors": errors,
        "time_format": "B-unknown (likely ISO-8601 or unix; not runtime-confirmed)",
        "null_rules": "B-unknown",
        "entities": meta.get("entities", []),
        "services": meta.get("services", []),
        "evidence_level": meta.get("evidence_level", "I"),
        "analysis_status": analysis,
        "notes": "; ".join(notes + [auth["notes"]]),
    }


def write_sha256sums(out_dir: Path) -> None:
    lines = []
    for path in sorted(out_dir.rglob("*")):
        if not path.is_file() or path.name == "SHA256SUMS":
            continue
        lines.append(f"{sha256_file(path)}  {path.relative_to(out_dir).as_posix()}")
    (out_dir / "SHA256SUMS").write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_docs11(
    *,
    stats: dict,
    p0_rows: list[dict],
    error_model: dict,
    auth_model_summary: dict,
    out: Path,
) -> None:
    lines = [
        "# 11 · 宠舍管家 API 与数据契约逆向",
        "",
        f"> 生成时间：{datetime.now().astimezone().isoformat(timespec='seconds')}  ",
        "> 波次：**R10**  ",
        "> 证据等级：S（App AOT 路由）、W（公开 admin/editor JS）、I（命名/路径推断）、B（运行态未观测）",
        "",
        "## 1. 范围与验收",
        "",
        f"- 原始路由总数：**{stats['raw_total']}**（App {stats['app_raw']} + Web {stats['web_raw']}）",
        f"- 规范化去重后：**{stats['normalized_unique']}**（shared {stats['shared']} / app-only {stats['app_only']} / web-only {stats['web_only']}）",
        f"- 每条均有来源、模块、分析状态：见 `reverse-evidence/full/api-catalog.csv` 与 `api/api-normalized.csv`",
        f"- Method 已解析（W）：**{stats['method_web']}**；路径推断（I）：**{stats['method_inferred']}**；未知：**{stats['method_unknown']}**",
        f"- P0 契约行：**{stats['p0_count']}**（字段级运行态均为 B 或 I，逐条标注）",
        "",
        "机器可读目录：",
        "",
        "```text",
        "reverse-evidence/full/api/",
        "├── api-normalized.csv      # 去重合并视图",
        "├── api-dedup-map.csv       # 原始 id → 规范 key",
        "├── p0-contracts.json       # P0/P1 契约骨架",
        "├── p0-contracts.csv",
        "├── error-auth-model.json",
        "└── r10-meta.json",
        "```",
        "",
        "## 2. 认证与传输",
        "",
        "### 2.1 认证（W + S）",
        "",
        "| 通道 | 行为 | 等级 |",
        "|---|---|---|",
        "| Browser admin | `localStorage.token` → 请求拦截器注入 | W |",
        "| App WebView | Bridge `getToken()` 覆盖 local token | W |",
        "| UA 检测 | `catteryapp` / `flutter` 视为 App 环境 | W |",
        "| HTTP 栈 | `Authorization` 头构造出现在打包的 axios/xhr 层 | W |",
        "| 登录前 | `/api/admin/app/login`、`/api/admin/sms` 等 | I |",
        "",
        "令牌生命周期、刷新与吊销：**B**（App 动态阻断，未见运行态）。",
        "",
        "### 2.2 错误模型（W 片段 + B）",
        "",
        f"- 成功码线索：admin 出现 `code===0` 计数 {error_model.get('code_eq_0_count', 0)}；编辑器字体接口注释式 `o.code===200`",
        "- 业务错误字段：`message` 字符串广泛存在；统一 schema **B**",
        "- HTTP 401/403：打包库中存在状态码分支，业务映射 **B**",
        "- 取消：`Cancel` / `__CANCEL__`（axios 风格）",
        "",
        "在动态补证前，所有 P0 的错误字段完整率按验收要求标记为 **B**（逐条见 `p0-contracts`）。",
        "",
        "## 3. 分页 / 时间 / 空值",
        "",
        "| 主题 | 结论 | 等级 |",
        "|---|---|---|",
        "| 分页 | admin 使用 `page` / `pageSize` / `total` 等；列表 GET 可能带分页 | W |",
        "| 时间格式 | 未运行态确认；I 倾向 ISO-8601 字符串 | B/I |",
        "| 空值 | 未确认 omit vs null vs 0 | B |",
        "| 上传 | `FormData` / `multipart` 出现；COS/DAM 路径 | W |",
        "",
        "## 4. 方法推断规则",
        "",
        "1. **优先** Web admin `url+method` 命名请求（W）",
        "2. App 与 Web 路径规范化匹配时复用 Web method（S+W）",
        "3. 否则路径后缀启发式：`add/create→POST`，`update/confirm/archive→PUT`，`delete→DELETE`，`detail/list→GET`（I）",
        "4. 仍无法判断 → method 空，status=`method-unknown`（进入 R3 后补 D）",
        "",
        f"启发式统计：{json.dumps(stats.get('method_sources', {}), ensure_ascii=False)}",
        "",
        "## 5. 幂等与批处理 / 归档",
        "",
        "| 行为 | 识别 | 等级 |",
        "|---|---|---|",
        "| GET 安全幂等 | method=GET | W/I |",
        "| PUT 更新/确认/归档 | `/update` `/confirm` `/archive` | W/I |",
        "| DELETE | `/delete` | W/I |",
        "| POST 创建 | `/add` `/create` `/upload` `/record` | W/I |",
        "| 繁育归档 | `/api/admin/cat/planes/archive` | W+S |",
        "| 批量 | `batch` 实体/服务名存在；具体 API 体 B | S/B |",
        "| 乐观锁 | 未见明确 version 字段证据 | B |",
        "| 重复提交 | 未见客户端锁证据 | B |",
        "",
        "## 6. P0 契约骨架（摘要）",
        "",
        "完整 JSON：`reverse-evidence/full/api/p0-contracts.json`。",
        "",
        "| 路由 | Method | Auth | 请求 | 响应 | 错误 |",
        "|---|---|---|---|---|---|",
    ]
    for row in p0_rows[:40]:
        if row["priority"] != "P0":
            continue
        lines.append(
            f"| `{row['route']}` | {row['method'] or '∅'} | {row['auth']} | {row['request_body'][:40]} | {row['response_body'][:40]} | {row['errors'][:30]} |"
        )
    lines += [
        "",
        "说明：验收要求 P0 字段完整率 100% **或** 逐条 B — 本轮采用后者（无运行态抓包）。",
        "",
        "## 7. 实体 / Service 交叉引用",
        "",
        "规范化目录的 `notes` / `p0-contracts.json` 含 `entities` 与 `services` 字段，",
        "来自 AOT 路径 token 与路由段的静态重合（S），例如：",
        "",
        "- `cats` → `cat` entity / `cat_api_service`",
        "- `planes` → `breeding_plan*` entities / `breeding_plan_api_service`",
        "- `entitlements` → membership 相关（字段级 B）",
        "",
        "状态机四级枚举（Web 明文，W）：`待搭配 / 待生产 / 带娃中 / 已归档` — 与 docs/02 对齐，动作 API 见 planes confirm/archive/breeding。",
        "",
        "## 8. 与 R9 交叉统计",
        "",
        f"- shared normalized keys: **{stats['shared']}**",
        f"- app-only: **{stats['app_only']}**",
        f"- web-only: **{stats['web_only']}**",
        "",
        "## 9. 缺口与补证",
        "",
        "1. 解除 R3 FairPlay 阻断后，对 P0 做代理抓包，将 B 升级为 D。",
        "2. 补齐 method-unknown 列表（见 `api/r10-meta.json`）。",
        "3. 错误码表、分页默认值、时间/时区、乐观锁字段需运行态或更多前端解压。",
        "4. App-only 路由的 method 目前大量依赖启发式（I），优先用真机日志校验。",
        "",
        "## 10. 敏感信息",
        "",
        "- 本文与目录不含 Token、Cookie、手机号或用户业务数据。",
        "",
    ]
    out.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    collected_at = os.environ.get("CATERTY_COLLECTED_AT") or datetime.now().astimezone().isoformat(
        timespec="seconds"
    )
    OUT_API.mkdir(parents=True, exist_ok=True)

    app_routes = read_lines(SRC / "api-routes.txt")
    web_routes = read_lines(SRC / "web" / "api-routes.txt")
    if len(app_routes) != 250 or len(web_routes) != 231:
        print(
            f"[FAIL] baseline counts app={len(app_routes)} web={len(web_routes)}",
            file=sys.stderr,
        )
        return 1

    admin_js = (SRC / "web" / "cattery-admin.js").read_text(encoding="utf-8", errors="ignore")
    web_map = parse_admin_methods(admin_js)
    # editor axios fonts
    editor_js = (SRC / "web" / "cattery-editor.js").read_text(encoding="utf-8", errors="ignore")
    for m in re.finditer(
        r"\.(get|post|put|delete)\(\s*[\"'](/api/[^\"']+)[\"']", editor_js
    ):
        web_map.setdefault(
            m.group(2),
            {
                "method": m.group(1).lower(),
                "client_fn": "",
                "source": "web-editor-axios",
                "level": "W",
            },
        )

    entities = read_lines(SRC / "entity-paths.txt")
    services = read_lines(SRC / "service-paths.txt")

    # Build unified raw rows from existing catalog if present
    catalog_path = OUT / "api-catalog.csv"
    if catalog_path.is_file():
        catalog = read_csv(catalog_path)
    else:
        catalog = []

    # Rebuild enriched catalog
    enriched: list[dict] = []
    dedup_map_rows: list[dict] = []
    norm_groups: dict[str, list[dict]] = defaultdict(list)

    method_sources = Counter()
    method_web = method_inferred = method_unknown = 0

    def enrich_one(raw_id: str, route: str, platform: str, base: dict | None = None) -> dict:
        nonlocal method_web, method_inferred, method_unknown
        base = base or {}
        web_hit = match_web_method(route, web_map)
        method = ""
        method_source = ""
        # Single-letter evidence_level only (S/D/W/P/I/B); multi-source details go in notes.
        level = "S" if platform == "app" else "W"
        level_note = platform
        if web_hit:
            method = web_hit["method"]
            method_source = web_hit["source"]
            method_web += 1
            method_sources[method_source] += 1
            if platform == "app":
                level = "S"
                level_note = "S+W"
            else:
                level = "W"
                level_note = "W"
        else:
            method, conf = infer_method_from_path(route)
            if method:
                method_source = f"path-heuristic-{conf}"
                method_inferred += 1
                method_sources[method_source] += 1
                level = "I"
                level_note = "I-path-heuristic"
            else:
                method_unknown += 1
                method_sources["unknown"] += 1
                level_note = f"{level}-route-only"
        links = entity_links(route, entities, services)
        auth = auth_model(route)
        pri = priority(route)
        params = path_params(route)
        idem = idempotent_hint(method, route)

        if method and method_source.startswith("web"):
            status = f"analyzed|{pri}|method-web"
        elif method:
            status = f"analyzed|{pri}|method-inferred"
        else:
            status = f"analyzed|{pri}|method-unknown"

        notes = (
            f"platform={platform}; evidence_combo={level_note}; "
            f"method={method or '∅'}; method_source={method_source or '∅'}; "
            f"auth={auth['auth']}; auth_ev={auth['auth_evidence']}; "
            f"params={','.join(params) or '-'}; idempotency={idem}; "
            f"entities={','.join(links['entities']) or '-'}; "
            f"services={','.join(links['services']) or '-'}; "
            f"priority={pri}"
        )

        name = (web_hit or {}).get("client_fn") or (base.get("name") if base else "") or (
            route.rstrip("/").rsplit("/", 1)[-1]
        )
        row = {
            "id": raw_id,
            "module": api_module(route),
            "name": name,
            "path": platform,
            "route": route,
            "evidence_level": level,
            "evidence_ref": (
                "reverse-evidence/api-routes.txt"
                if platform == "app"
                else "reverse-evidence/web/api-routes.txt + cattery-admin.js"
            ),
            "status": status,
            "notes": notes,
            # internal
            "_method": method,
            "_method_source": method_source,
            "_priority": pri,
            "_params": params,
            "_entities": links["entities"],
            "_services": links["services"],
            "_auth": auth["auth"],
        }
        return row

    # Prefer stable IDs from baselines
    for i, route in enumerate(app_routes, 1):
        base = next((r for r in catalog if r.get("id") == f"API-APP-{i:04d}"), None)
        row = enrich_one(f"API-APP-{i:04d}", route, "app", base)
        enriched.append({k: row[k] for k in CSV_COLUMNS})
        key = normalize_route(route)
        norm_groups[key].append(row)
        dedup_map_rows.append(
            {
                "id": f"MAP-{len(dedup_map_rows)+1:04d}",
                "module": row["module"],
                "name": row["id"],
                "path": "app",
                "route": route,
                "evidence_level": row["evidence_level"],
                "evidence_ref": row["evidence_ref"],
                "status": key,
                "notes": f"normalized_key={key}",
            }
        )

    for i, route in enumerate(web_routes, 1):
        base = next((r for r in catalog if r.get("id") == f"API-WEB-{i:04d}"), None)
        row = enrich_one(f"API-WEB-{i:04d}", route, "web", base)
        enriched.append({k: row[k] for k in CSV_COLUMNS})
        key = normalize_route(route)
        norm_groups[key].append(row)
        dedup_map_rows.append(
            {
                "id": f"MAP-{len(dedup_map_rows)+1:04d}",
                "module": row["module"],
                "name": row["id"],
                "path": "web",
                "route": route,
                "evidence_level": row["evidence_level"],
                "evidence_ref": row["evidence_ref"],
                "status": key,
                "notes": f"normalized_key={key}",
            }
        )

    # Normalized unique view
    norm_rows: list[dict] = []
    shared = app_only = web_only = 0
    for i, (key, group) in enumerate(sorted(norm_groups.items(), key=lambda x: x[0]), 1):
        platforms = sorted({g["path"] for g in group})
        if platforms == ["app", "web"] or set(platforms) == {"app", "web"}:
            src = "shared"
            shared += 1
            level = "S"  # primary; combo in notes
            combo = "S+W"
        elif platforms == ["app"]:
            src = "app-only"
            app_only += 1
            level = "S"
            combo = "S"
        else:
            src = "web-only"
            web_only += 1
            level = "W"
            combo = "W"
        # pick best method
        methods = [(g.get("_method") or "", g.get("_method_source") or "") for g in group]
        method = ""
        method_source = ""
        for m, s in methods:
            if m and s.startswith("web"):
                method, method_source = m, s
                break
        if not method:
            for m, s in methods:
                if m:
                    method, method_source = m, s
                    break
        if method and method_source.startswith("path-heuristic"):
            level = "I"
            combo = f"{combo}+I"
        sample = group[0]
        raw_ids = ",".join(g["id"] for g in group)
        routes_raw = " | ".join(sorted({g["route"] for g in group}))
        auth = auth_model(sample["route"])
        pri = priority(sample["route"])
        links = entity_links(sample["route"], entities, services)
        status = f"normalized|{src}|{pri}|method={'web' if method_source.startswith('web') else ('inferred' if method else 'unknown')}"
        notes = (
            f"sources={src}; evidence_combo={combo}; raw_ids={raw_ids}; method={method or '∅'}; "
            f"method_source={method_source or '∅'}; auth={auth['auth']}; "
            f"entities={','.join(links['entities']) or '-'}; "
            f"services={','.join(links['services']) or '-'}"
        )
        norm_rows.append(
            {
                "id": f"API-N-{i:04d}",
                "module": api_module(key),
                "name": method_source or src,
                "path": src,
                "route": routes_raw if src == "shared" else sample["route"],
                "evidence_level": level,
                "evidence_ref": "merged app+web baselines",
                "status": status,
                "notes": notes,                "_method": method,
                "_priority": pri,
                "_route_primary": sample["route"],
                "_entities": links["entities"],
                "_services": links["services"],
                "_method_source": method_source,
                "_auth": auth["auth"],
            }
        )

    # P0/P1 contracts from normalized + any matching prefix
    p0_rows = []
    for nr in norm_rows:
        route = nr["_route_primary"]
        pri = nr["_priority"]
        if pri not in ("P0", "P1"):
            continue
        meta = {
            "method_source": nr.get("_method_source", ""),
            "entities": nr.get("_entities", []),
            "services": nr.get("_services", []),
            "evidence_level": nr["evidence_level"],
        }
        p0_rows.append(p0_contract_row(route, nr.get("_method", ""), meta))
        # also add sibling raw routes in shared?
    p0_rows.sort(key=lambda r: (0 if r["priority"] == "P0" else 1, r["route"]))

    # Write catalogs
    write_csv(catalog_path, enriched)
    write_csv(OUT_API / "api-normalized.csv", [{k: r[k] for k in CSV_COLUMNS} for r in norm_rows])
    write_csv(OUT_API / "api-dedup-map.csv", dedup_map_rows)

    p0_csv = []
    for i, r in enumerate(p0_rows, 1):
        p0_csv.append(
            {
                "id": f"P0C-{i:04d}",
                "module": r["priority"],
                "name": r["method"] or "∅",
                "path": r["auth"],
                "route": r["route"],
                "evidence_level": r["evidence_level"],
                "evidence_ref": "static R10 skeleton",
                "status": r["analysis_status"],
                "notes": (
                    f"req={r['request_body']}; resp={r['response_body']}; err={r['errors']}; "
                    f"params={','.join(r['path_params']) or '-'}; idem={r['idempotency']}; "
                    f"entities={','.join(r['entities']) or '-'}; {r['notes']}"
                ),
            }
        )
    write_csv(OUT_API / "p0-contracts.csv", p0_csv)
    (OUT_API / "p0-contracts.json").write_text(
        json.dumps(p0_rows, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )

    error_model = {
        "code_eq_0_count": admin_js.count("code===0"),
        "code_200_editor_pattern": editor_js.count("code===200"),
        "message_count_admin": admin_js.count("message"),
        "authorization_header_count": admin_js.count("Authorization"),
        "form_data_count": admin_js.count("FormData"),
        "pageSize_count": admin_js.count("pageSize"),
        "notes": [
            "Unified business error schema not fully recovered from minified JS",
            "Runtime HTTP captures blocked by R3 FairPlay",
        ],
    }
    auth_summary = {
        "browser_token": "localStorage.token",
        "app_bridge_token": "getToken via FMBridge/FlutterBridge",
        "header": "Authorization present in HTTP client stack",
        "public_candidates": ["/api/admin/app/login", "/api/admin/sms"],
    }
    (OUT_API / "error-auth-model.json").write_text(
        json.dumps(
            {"auth": auth_summary, "errors": error_model, "pagination": {"pageSize": True, "total": True}},
            ensure_ascii=False,
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )

    unknown_methods = [r["route"] for r in enriched if "method-unknown" in r["status"]]
    stats = {
        "raw_total": len(app_routes) + len(web_routes),
        "app_raw": len(app_routes),
        "web_raw": len(web_routes),
        "normalized_unique": len(norm_rows),
        "shared": shared,
        "app_only": app_only,
        "web_only": web_only,
        "method_web": method_web,
        "method_inferred": method_inferred,
        "method_unknown": method_unknown,
        "method_sources": dict(method_sources),
        "p0_count": sum(1 for r in p0_rows if r["priority"] == "P0"),
        "p1_count": sum(1 for r in p0_rows if r["priority"] == "P1"),
        "unknown_method_sample": unknown_methods[:40],
    }
    (OUT_API / "r10-meta.json").write_text(
        json.dumps(
            {
                "collected_at": collected_at,
                "wave": "R10",
                "stats": stats,
                "p0_prefixes": list(P0_PREFIXES),
                "p1_prefixes": list(P1_PREFIXES),
            },
            ensure_ascii=False,
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )

    write_docs11(
        stats=stats,
        p0_rows=p0_rows,
        error_model=error_model,
        auth_model_summary=auth_summary,
        out=DOCS / "11-宠舍管家API与数据契约逆向.md",
    )

    # manifest
    manifest_path = OUT / "manifest.json"
    if manifest_path.is_file():
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        manifest["r10"] = {
            "collected_at": collected_at,
            "docs": "docs/11-宠舍管家API与数据契约逆向.md",
            "api_dir": "api/",
            "stats": stats,
        }
        manifest_path.write_text(
            json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )

    write_sha256sums(OUT)

    print("[OK] R10 API contracts written")
    print(f"  raw={stats['raw_total']} normalized={stats['normalized_unique']}")
    print(
        f"  method web={method_web} inferred={method_inferred} unknown={method_unknown}"
    )
    print(f"  shared={shared} app_only={app_only} web_only={web_only}")
    print(f"  p0={stats['p0_count']} p1={stats['p1_count']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

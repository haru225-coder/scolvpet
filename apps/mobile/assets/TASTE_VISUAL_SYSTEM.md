# 熊舍管家 · Taste 视觉资产系统

> Generated via Grok2API `grok-imagine-image` · 2026-07-17  
> Skill: `design-taste-frontend` (preserve · warm-cute · HIG)

## Design Read

**Reading this as:** 金丝熊繁育经营 App 给中国熊舍主，暖萌 + 专业工具（playful-calm），非 marketing kinetic。

| Dial | Value | Why |
|------|-------|-----|
| DESIGN_VARIANCE | 5 | 产品壳 + 角色插画点缀 |
| MOTION_INTENSITY | 4 | 轻 PopIn / 无 scroll hijack |
| VISUAL_DENSITY | 5 | 经营信息仍优先 |

## Palette Lock（禁止偏离）

| Token | Hex | Use |
|-------|-----|-----|
| accent | `#c77852` | 主品牌 / CTA |
| accentSoft | `#fff1e8` | 背景洗色 |
| cream | bone / paper | 插画底 |
| sage (muted) | soft green-gray | 健康空态 |
| charcoal | soft near-black | 线稿 |

**Banned:** AI purple, neon, cyber mesh, glassmorphism-for-show, photoreal stock.

## Asset Map

### Brand (`assets/brand/`)

| File | Role |
|------|------|
| `mascot_happy.png` | 默认吉祥物 / 成功空态 |
| `mascot_sleepy.png` | 一切正常 / 无待办 |
| `mascot_worried.png` | 关注/异常氛围（仍可爱） |
| `app_icon.png` | 应用图标源 |
| `login_hero.png` | 登录/引导宽构图 |

### Icons (`assets/icons/`)

| File | Feature |
|------|---------|
| `ic_today.png` | 今日 |
| `ic_hamster.png` | 仓鼠 |
| `ic_enclosure.png` | 笼舍 |
| `ic_breeding.png` | 繁育 |
| `ic_litter.png` | 窝次 |
| `ic_tasks.png` | 任务 |
| `ic_weight.png` | 称重 |
| `ic_calendar.png` | 日历 |
| `ic_data.png` | 数据中心 |
| `ic_mine.png` | 我的 |

### Illustrations (`assets/illustrations/`)

| File | Screen |
|------|--------|
| `empty_care.png` | 今日护理空态 |
| `empty_attention.png` | 需关注空态 |
| `empty_list.png` | 通用列表空 |
| `loading_wake.png` | 启动加载 |
| `onboarding_setup.png` | 首次建舍 |

## Usage Rules (Taste)

1. **One accent family** across all assets (already baked in generation prompts).
2. Prefer illustration for **empty / loading / brand** only; dense lists stay HIG rows.
3. Icons: use as **32–48pt** soft tiles, not full-bleed photos.
4. Never put marketing eyebrows / em-dashes on illustration captions.
5. If regenerating: keep the Style block in generation scripts identical (palette + anti-slop bans).

## Regeneration

```bash
# Grok2API
# POST https://gk.scolv.com:8443/v1/images/generations
# model: grok-imagine-image
# response_format: b64_json
```

Prompt prefix is the STYLE constant in the generation script (warm terracotta hand-drawn, no purple).

# R9 Web 模块索引

- 采集时间：2026-07-17T02:17:02+08:00
- 证据等级：W（公开生产 JS/HTML）
- Admin JS SHA-256：见 manifest / SHA256SUMS

## 技术栈信号

- 管理端：Vue SPA + 请求封装 `request({url, method})`（Pinia `defineStore` 名称在压缩后未保留明文）
- 编辑器：独立 SPA；字体列表走 `/api/editor/fonts`；模板资源走 DAM/COS
- 鉴权：`localStorage.token`；App 内优先 Bridge `getToken`

## 前端路由分组（admin）

### help（3）
- `/help/app/privacy`
- `/help/privacy`
- `/help/user_agreement`

### marketing（1）
- `/marketing/breeding-challenge`

### other（7）
- `/`
- `/bind`
- `/bind-service`
- `/login`
- `/summarize/2024`
- `@@/core/runtime.ts`
- `@@/plugin-locale/runtime.ts`

### pricing（4）
- `/pricing`
- `/pricing/orders`
- `/pricing/orders/detail/:order_no`
- `/pricing/trade`

### transfer（3）
- `/transfer/:id`
- `/transfer/loan`
- `/transfer/loan/:id`

### ws（57）
- `/ws`
- `/ws/article`
- `/ws/article/edit/:id`
- `/ws/cats/list`
- `/ws/cats/list/detail/:id`
- `/ws/cats/list/edit/:id`
- `/ws/cats/list/edit/visual/:id`
- `/ws/cats/plane`
- `/ws/cats/plane/detail/:id`
- `/ws/cats/plane/edit/:id`
- `/ws/goods/edit/:id`
- `/ws/goods/list`
- `/ws/levels/example`
- `/ws/levels/list`
- `/ws/membership/levels`
- `/ws/orders/create`
- `/ws/orders/detail/:id`
- `/ws/orders/list`
- `/ws/point/activities`
- `/ws/point/products`
- `/ws/point/products/edit/:id`
- `/ws/point/rules`
- `/ws/point/settings`
- `/ws/point/sign-config`
- `/ws/point/stats`
- `/ws/profile/info`
- `/ws/recharge/rules`
- `/ws/sale/contract/list`
- `/ws/sale/door/detail/:id`
- `/ws/sale/door/list`
- `/ws/sale/loan/list`
- `/ws/sale/queue/detail/:id`
- `/ws/sale/queue/list`
- `/ws/seo/config`
- `/ws/shipping/templates`
- `/ws/shop/brand`
- `/ws/shop/brand/edit/:id`
- `/ws/shop/category`
- `/ws/shop/detail`
- `/ws/shop/facade`
- `/ws/shop/goods`
- `/ws/shop/list`
- `/ws/shop/list/edit/:id`
- `/ws/shop/tabbar`
- `/ws/shop/tabbar/edit/:id`
- `/ws/shop/tabbar/list`
- `/ws/tags/list`
- `/ws/tools/list`
- `/ws/tools/price-form/list`
- `/ws/tools/watermark`
- `/ws/users/list`
- `/ws/variety/list`
- `/ws/weixin/audit`
- `/ws/weixin/mini`
- `/ws/weixin/tester`
- `/ws/weixin/version`
- `/ws/work`

### ws-mobile（14）
- `/ws-mobile`
- `/ws-mobile/goods/edit/:id`
- `/ws-mobile/goods/list`
- `/ws-mobile/orders/create`
- `/ws-mobile/orders/detail/:id`
- `/ws-mobile/orders/list`
- `/ws-mobile/point/products`
- `/ws-mobile/recharge/rules`
- `/ws-mobile/seo/config`
- `/ws-mobile/shipping/list`
- `/ws-mobile/shop/category`
- `/ws-mobile/shop/list/edit/:id`
- `/ws-mobile/shop/tabbar/edit/:id`
- `/ws-mobile/shop/tabbar/list`

## 编辑器路由

- `/`
- `/editor`

## 官网 / 小程序相关路由与 API（共用工作台）

管理端同一 SPA 同时承载「店铺/官网装修」与「微信小程序」能力：

| 能力 | 前端路由（例） | API（例） |
|---|---|---|
| 店铺/官网 | `/ws/shop/*`, `/ws/seo/config` | `/api/admin/shops*`, `/api/admin/seo/*` |
| 小程序 | `/ws/weixin/mini`, `/audit`, `/version`, `/tester` | `/api/admin/weixin/mini/*` |
| 模板 | `/ws/shipping/templates`, shop templates | `/api/admin/shop/templates`, shipping templates |
| 文章 | `/ws/article` | `/api/admin/articles*` |
| 导航 TabBar | `/ws/shop/tabbar*` | `/api/admin/tabbar*` |

结论：**内容模型在管理端侧共用同一套店铺/商品/文章/导航/SEO 配置**；
小程序额外挂微信授权、审核、上传、版本、体验者 API。
版本「回滚」明文未出现（B：需动态或更多构建确认）。

## App API × Web API 交叉统计

- shared: **49**
- web-only: **181**
- app-only: **201**
- app total: 250, web total: 231

## 枚举片段（admin 明文）

- 繁育：{'待搭配': 1, '待生产': 1, '带娃中': 1, '已归档': 1}
- 内容流：{'提交审核': 2, '审核': 2, '发布': 1, '预览': 0, '小程序版本管理/发布': 1, '微信小程序/授权': 1}

## 标题词云（节选）

- APP隐私政策
- Cattery
- ID
- SEO 配置
- title
- 上门管理
- 上门详情
- 体验者管理
- 余额
- 借配管理
- 借配详情
- 公众号授权
- 分类
- 创建时间
- 创建订单
- 名称
- 品牌管理
- 品种
- 品种名称
- 品种管理
- 商品列表配置
- 商品管理
- 商品编辑
- 基础组件
- 头像
- 定级
- 定级管理
- 定级组件示例
- 宠物组件
- 导航栏管理
- 导航栏编辑
- 导航栏配置管理
- 导航栏配置编辑
- 小程序版本管理/发布
- 展示
- 展示区
- 岁数
- 崽崽
- 工作台
- 店铺装修
- 待售区
- 待售宠物
- 微信小程序/授权
- 成长区
- 我的会员订单
- 我的工具
- 我的种群
- 排队信息
- 排队管理
- 提交审核
- 操作
- 文章列表
- 标签管理
- 档案转移
- 水印管理
- 猫舍
- 猫舍甄选
- 用户列表
- 用户协议
- 用户名称

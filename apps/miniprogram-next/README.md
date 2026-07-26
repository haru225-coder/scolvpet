# scolvpet-miniprogram-next

ScolvPet B 端小程序(docs/32 迁移工程,Taro 4.2.1 + React + TypeScript,编译目标 weapp,Skyline 按页开启)。

## 结构

```text
src/
  app.ts / app.config.ts   入口(移植旧 app.js 的 globalData/静默登录,原生页 getApp() 兼容)
  pages/today, pages/login  主包 Taro 页(today 为 Skyline 样例页)
  pages/{index,catalog,detail,pedigree,simulate,my-reservations,contract}
                            C 端 7 页原生混写(与 apps/miniprogram 同源,路径不变保深链)
  utils/                    原生 CommonJS 模块(config.js 为构建注入点)
  packages/{animals,breeding,crm,contracts,finance,ai}
                            B 端分包位(M1+ 填充;animals 含个体列表样例页)
packages/mp-ui/             @scolvpet/mp-ui 组件库(tokens 真源:apps/mobile/lib/ui/theme/ios_theme.dart)
```

## 命令

- `npm run dev:weapp` / `npm run build:weapp`:开发/构建(开发默认 touristappid + staging)。
- `npm test`:vitest(mp-ui 快照);`npm run test:native`:迁移的 C 端原生单测。
- 仓库根:`make miniprogram-next-test` / `make miniprogram-next-build`(含分包体积门禁)/ `make release-miniprogram-next`(fail-closed 注入,见 `scripts/build-miniprogram-next.sh`)。

## 约定

- 微信开发者工具导入本目录,产物在 `dist/`(project.config.json 指向 dist)。
- 接口一律走 `generated/ts/scolvpet-api` + `src/api` adapter,禁止手写 fetch/request 封装(旧 `src/utils/api.js` 仅服务混写 C 端页,不再增长)。
- `.npmrc` 固定 legacy-peer-deps(Taro peerOptional vite@4 与 vitest 冲突,webpack5 路径不受影响)。
- 旧 `apps/miniprogram/` 在真机回归 PASS 前保留,勿删。

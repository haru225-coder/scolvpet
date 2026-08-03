import fs from 'node:fs'

function quotedValues(source: string): string[] {
  return [...source.matchAll(/'([^']+)'/g)].map((match) => match[1])
}

/** 从 Taro 配置中读取主包和分包的完整路由，供迁移覆盖测试复用。 */
export function readDeclaredRoutes(configPath: string): string[] {
  const source = fs.readFileSync(configPath, 'utf8')
  const mainPackageRoutes = [...source.matchAll(/^\s*'(pages\/[^']+)'/gm)].map((match) => match[1])
  const subPackageRoutes = [...source.matchAll(/\{\s*root:\s*'([^']+)'\s*,\s*pages:\s*\[([\s\S]*?)\]\s*\}/g)]
    .flatMap((match) => quotedValues(match[2]).map((page) => `${match[1]}/${page}`))

  return [...mainPackageRoutes, ...subPackageRoutes]
}

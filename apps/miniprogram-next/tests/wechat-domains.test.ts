import { describe, expect, it } from 'vitest'
import fs from 'node:fs'
import path from 'node:path'

const appRoot = path.resolve(__dirname, '..')

describe('微信小程序文件传输边界', () => {
  it('下载使用 FileSystemManager.saveFile，不再调用已废弃 Taro.saveFile', () => {
    const source = fs.readFileSync(path.join(appRoot, 'src/packages/data-center/actions/index.tsx'), 'utf8')
    expect(source).not.toContain('Taro.saveFile')
    expect(source).toContain('Taro.getFileSystemManager()')
    expect(source).toContain('.saveFile(')
  })

  it('合法域名清单覆盖 request、downloadFile、uploadFile 三类通道', () => {
    const readme = fs.readFileSync(path.join(appRoot, 'README.md'), 'utf8')
    for (const channel of ['request', 'downloadFile', 'uploadFile']) expect(readme).toContain(channel)
    expect(readme).toContain('pet.scolv.com')
    expect(readme).toContain('uploadUrl')
    // 预签名 PUT 走 request，不是 uploadFile 通道
    expect(readme).toContain('Taro.request')
  })
})

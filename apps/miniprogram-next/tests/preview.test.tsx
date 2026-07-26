import { render } from '@testing-library/react'
import { describe, it } from 'vitest'
import fs from 'node:fs'
import path from 'node:path'

import TodayPage from '../src/pages/today'
import LoginPage from '../src/pages/login'
import AnimalsSamplePage from '../src/packages/animals/index'

// 视觉预览生成器(非断言测试):把样例页经 DOM 桩渲染成静态 HTML,
// 供无微信开发者工具环境下做视觉走查。默认跳过,显式开启:
//   PREVIEW_OUT=/path/to/dir npx vitest run tests/preview.test.tsx
const OUT = process.env.PREVIEW_OUT

describe.skipIf(!OUT)('render static previews', () => {
  it('writes page HTML fragments', () => {
    const pages: Array<[string, () => JSX.Element]> = [
      ['today', TodayPage],
      ['animals', AnimalsSamplePage],
      ['login', LoginPage]
    ]
    fs.mkdirSync(OUT!, { recursive: true })
    for (const [name, Page] of pages) {
      const { container } = render(<Page />)
      fs.writeFileSync(path.join(OUT!, `${name}.html`), container.innerHTML)
    }
  })
})

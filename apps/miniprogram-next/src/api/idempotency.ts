import { newIdempotencyKey } from './client'

/**
 * 将幂等键绑定到一次业务意图：失败重试复用同一个 key，成功后才作废。
 * 这样双击/弱网重试不会把同一笔业务写成两条记录。
 */
export function createIdempotencyIntent() {
  let key = ''
  return {
    getKey() {
      if (!key) key = newIdempotencyKey()
      return key
    },
    complete() {
      key = ''
    }
  }
}

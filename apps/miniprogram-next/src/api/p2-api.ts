// P2Api 域实例（AI 助手等）。
import { P2Api } from '@scolvpet/api-client'

import { apiConfiguration } from './runtime-config'

export const p2Api = new P2Api(apiConfiguration)

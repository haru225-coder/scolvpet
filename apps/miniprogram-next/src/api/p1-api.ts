// P1Api 域实例（合同/财务/部分遗传档案等）。
import { P1Api } from '@scolvpet/api-client'

import { apiConfiguration } from './runtime-config'

export const p1Api = new P1Api(apiConfiguration)

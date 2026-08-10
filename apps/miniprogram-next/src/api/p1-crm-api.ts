// P1CRMApi 域实例。
import { P1CRMApi } from '@scolvpet/api-client'

import { apiConfiguration } from './runtime-config'

export const p1CrmApi = new P1CRMApi(apiConfiguration)

// DefaultApi 域实例：仅被真正用到 Default 契约的页面/路径静态引用。
import { DefaultApi } from '@scolvpet/api-client'

import { apiConfiguration } from './runtime-config'

export const defaultApi = new DefaultApi(apiConfiguration)

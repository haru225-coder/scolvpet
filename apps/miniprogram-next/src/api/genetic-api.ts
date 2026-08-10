// GeneticApi 域实例（试配/表型目录/反馈摘要）。
import { GeneticApi } from '@scolvpet/api-client'

import { apiConfiguration } from './runtime-config'

export const geneticApi = new GeneticApi(apiConfiguration)

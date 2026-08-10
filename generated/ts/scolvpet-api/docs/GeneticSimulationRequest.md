
# GeneticSimulationRequest

繁殖推算请求。商家默认使用 phenotype_table 模式，数据来自《金丝熊后代推算整理表（双重核验版）》权威表。 mendel 模式保留简化位点基因型推算（教育用）。

## Properties

Name | Type
------------ | -------------
`mode` | string
`series` | string
`sirePhenotype` | string
`damPhenotype` | string
`sireGenotypeKey` | string
`damGenotypeKey` | string
`sireHamsterId` | string
`damHamsterId` | string
`targetPhenotype` | string
`sire` | { [key: string]: string; }
`dam` | { [key: string]: string; }

## Example

```typescript
import type { GeneticSimulationRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "mode": null,
  "series": null,
  "sirePhenotype": null,
  "damPhenotype": null,
  "sireGenotypeKey": null,
  "damGenotypeKey": null,
  "sireHamsterId": null,
  "damHamsterId": null,
  "targetPhenotype": null,
  "sire": null,
  "dam": null,
} satisfies GeneticSimulationRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as GeneticSimulationRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



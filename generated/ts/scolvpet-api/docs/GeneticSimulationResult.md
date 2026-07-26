
# GeneticSimulationResult


## Properties

Name | Type
------------ | -------------
`mode` | string
`tableId` | string
`tableVersion` | string
`series` | string
`seriesName` | string
`sirePhenotype` | string
`damPhenotype` | string
`sire` | { [key: string]: string; }
`dam` | { [key: string]: string; }
`outcomes` | [Array&lt;GeneticOutcome&gt;](GeneticOutcome.md)
`tableOutcomes` | [Array&lt;PhenotypeTableOutcome&gt;](PhenotypeTableOutcome.md)
`predictionBasis` | string
`historyLitterCount` | number
`historyPupCount` | number
`notes` | string

## Example

```typescript
import type { GeneticSimulationResult } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "mode": null,
  "tableId": null,
  "tableVersion": null,
  "series": null,
  "seriesName": null,
  "sirePhenotype": null,
  "damPhenotype": null,
  "sire": null,
  "dam": null,
  "outcomes": null,
  "tableOutcomes": null,
  "predictionBasis": null,
  "historyLitterCount": null,
  "historyPupCount": null,
  "notes": null,
} satisfies GeneticSimulationResult

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as GeneticSimulationResult
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



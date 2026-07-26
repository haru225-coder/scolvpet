
# GeneticOutcome


## Properties

Name | Type
------------ | -------------
`genotypeKey` | string
`genotype` | { [key: string]: string; }
`phenotypeLabel` | string
`phenotype` | { [key: string]: string; }
`probability` | number
`countWeight` | number

## Example

```typescript
import type { GeneticOutcome } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "genotypeKey": null,
  "genotype": null,
  "phenotypeLabel": null,
  "phenotype": null,
  "probability": null,
  "countWeight": null,
} satisfies GeneticOutcome

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as GeneticOutcome
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



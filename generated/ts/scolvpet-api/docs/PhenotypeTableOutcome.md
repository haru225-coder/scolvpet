
# PhenotypeTableOutcome


## Properties

Name | Type
------------ | -------------
`phenotype` | string
`probability` | number
`fraction` | string
`note` | string

## Example

```typescript
import type { PhenotypeTableOutcome } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "phenotype": null,
  "probability": null,
  "fraction": null,
  "note": null,
} satisfies PhenotypeTableOutcome

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as PhenotypeTableOutcome
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



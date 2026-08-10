
# UpdateGeneticProfileRequest


## Properties

Name | Type
------------ | -------------
`name` | string
`notes` | string
`confidence` | string
`phenotype` | { [key: string]: any; }
`genotype` | { [key: string]: string; }
`version` | number
`hamsterId` | string

## Example

```typescript
import type { UpdateGeneticProfileRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "name": null,
  "notes": null,
  "confidence": null,
  "phenotype": null,
  "genotype": null,
  "version": null,
  "hamsterId": null,
} satisfies UpdateGeneticProfileRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as UpdateGeneticProfileRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



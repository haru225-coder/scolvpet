
# GeneticProfile


## Properties

Name | Type
------------ | -------------
`id` | string
`hamsterId` | string
`hamsterName` | string
`hamsterCode` | string
`name` | string
`phenotype` | { [key: string]: any; }
`genotype` | { [key: string]: string; }
`confidence` | string
`notes` | string
`version` | number
`updatedAt` | Date

## Example

```typescript
import type { GeneticProfile } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "hamsterId": null,
  "hamsterName": null,
  "hamsterCode": null,
  "name": null,
  "phenotype": null,
  "genotype": null,
  "confidence": null,
  "notes": null,
  "version": null,
  "updatedAt": null,
} satisfies GeneticProfile

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as GeneticProfile
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



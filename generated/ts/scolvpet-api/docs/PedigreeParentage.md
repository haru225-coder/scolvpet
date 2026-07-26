
# PedigreeParentage


## Properties

Name | Type
------------ | -------------
`id` | string
`ownerId` | string
`childHamsterId` | string
`parentHamsterId` | string
`role` | string
`evidenceType` | string
`confidence` | number
`validFrom` | Date
`validTo` | Date
`notes` | string
`version` | number
`createdAt` | Date

## Example

```typescript
import type { PedigreeParentage } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "ownerId": null,
  "childHamsterId": null,
  "parentHamsterId": null,
  "role": null,
  "evidenceType": null,
  "confidence": null,
  "validFrom": null,
  "validTo": null,
  "notes": null,
  "version": null,
  "createdAt": null,
} satisfies PedigreeParentage

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as PedigreeParentage
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)




# PedigreeParentageCreateRequest


## Properties

Name | Type
------------ | -------------
`childHamsterId` | string
`parentHamsterId` | string
`role` | string
`evidenceType` | string
`confidence` | number
`validFrom` | Date
`notes` | string
`correctionReason` | string

## Example

```typescript
import type { PedigreeParentageCreateRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "childHamsterId": null,
  "parentHamsterId": null,
  "role": null,
  "evidenceType": null,
  "confidence": null,
  "validFrom": null,
  "notes": null,
  "correctionReason": null,
} satisfies PedigreeParentageCreateRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as PedigreeParentageCreateRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



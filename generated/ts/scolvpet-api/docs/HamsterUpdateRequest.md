
# HamsterUpdateRequest


## Properties

Name | Type
------------ | -------------
`internalCode` | string
`name` | string
`varietyCode` | string
`sex` | [Sex](Sex.md)
`sexConfidence` | number
`birthDate` | Date
`coverMediaId` | string
`notes` | string

## Example

```typescript
import type { HamsterUpdateRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "internalCode": null,
  "name": null,
  "varietyCode": null,
  "sex": null,
  "sexConfidence": null,
  "birthDate": null,
  "coverMediaId": null,
  "notes": null,
} satisfies HamsterUpdateRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as HamsterUpdateRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



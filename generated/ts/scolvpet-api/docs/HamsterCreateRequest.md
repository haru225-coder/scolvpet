
# HamsterCreateRequest


## Properties

Name | Type
------------ | -------------
`internalCode` | string
`name` | string
`speciesRuleVersionId` | string
`varietyCode` | string
`sex` | [Sex](Sex.md)
`sexConfidence` | number
`birthDate` | Date
`sourceType` | [HamsterSourceType](HamsterSourceType.md)
`coverMediaId` | string
`notes` | string
`sireId` | string
`damId` | string
`litterId` | string

## Example

```typescript
import type { HamsterCreateRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "internalCode": null,
  "name": null,
  "speciesRuleVersionId": null,
  "varietyCode": null,
  "sex": null,
  "sexConfidence": null,
  "birthDate": null,
  "sourceType": null,
  "coverMediaId": null,
  "notes": null,
  "sireId": null,
  "damId": null,
  "litterId": null,
} satisfies HamsterCreateRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as HamsterCreateRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



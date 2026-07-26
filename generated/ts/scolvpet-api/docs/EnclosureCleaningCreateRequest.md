
# EnclosureCleaningCreateRequest


## Properties

Name | Type
------------ | -------------
`cleaningType` | [EnclosureCleaningType](EnclosureCleaningType.md)
`performedAt` | Date
`supplies` | { [key: string]: any; }
`notes` | string
`correctsCleaningRecordId` | string
`correctionReason` | string

## Example

```typescript
import type { EnclosureCleaningCreateRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "cleaningType": null,
  "performedAt": null,
  "supplies": null,
  "notes": null,
  "correctsCleaningRecordId": null,
  "correctionReason": null,
} satisfies EnclosureCleaningCreateRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as EnclosureCleaningCreateRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



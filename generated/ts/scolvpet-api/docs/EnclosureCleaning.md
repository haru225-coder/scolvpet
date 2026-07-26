
# EnclosureCleaning


## Properties

Name | Type
------------ | -------------
`id` | string
`enclosureId` | string
`cleaningType` | [EnclosureCleaningType](EnclosureCleaningType.md)
`performedAt` | Date
`supplies` | { [key: string]: any; }
`notes` | string
`correctsCleaningRecordId` | string
`correctionReason` | string
`createdAt` | Date

## Example

```typescript
import type { EnclosureCleaning } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "enclosureId": null,
  "cleaningType": null,
  "performedAt": null,
  "supplies": null,
  "notes": null,
  "correctsCleaningRecordId": null,
  "correctionReason": null,
  "createdAt": null,
} satisfies EnclosureCleaning

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as EnclosureCleaning
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



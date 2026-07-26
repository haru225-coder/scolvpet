
# WeightRecordCreateRequest


## Properties

Name | Type
------------ | -------------
`hamsterId` | string
`pupIdentityId` | string
`litterId` | string
`measurementKind` | string
`subjectCount` | number
`weightG` | number
`recordedAt` | Date
`source` | string
`deviceReadingId` | string
`notes` | string
`correctsWeightRecordId` | string
`correctionReason` | string

## Example

```typescript
import type { WeightRecordCreateRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "hamsterId": null,
  "pupIdentityId": null,
  "litterId": null,
  "measurementKind": null,
  "subjectCount": null,
  "weightG": null,
  "recordedAt": null,
  "source": null,
  "deviceReadingId": null,
  "notes": null,
  "correctsWeightRecordId": null,
  "correctionReason": null,
} satisfies WeightRecordCreateRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as WeightRecordCreateRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



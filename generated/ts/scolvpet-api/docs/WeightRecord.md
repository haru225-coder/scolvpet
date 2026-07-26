
# WeightRecord


## Properties

Name | Type
------------ | -------------
`id` | string
`hamsterId` | string
`pupIdentityId` | string
`litterId` | string
`measurementKind` | string
`subjectCount` | number
`weightG` | number
`recordedAt` | Date
`source` | string
`birthWeightG` | number
`previousWeightG` | number
`changeFromPreviousG` | number
`changeFromBirthG` | number
`alertFlags` | Array&lt;string&gt;
`notes` | string
`correctsWeightRecordId` | string
`correctionReason` | string
`createdAt` | Date

## Example

```typescript
import type { WeightRecord } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "hamsterId": null,
  "pupIdentityId": null,
  "litterId": null,
  "measurementKind": null,
  "subjectCount": null,
  "weightG": null,
  "recordedAt": null,
  "source": null,
  "birthWeightG": null,
  "previousWeightG": null,
  "changeFromPreviousG": null,
  "changeFromBirthG": null,
  "alertFlags": null,
  "notes": null,
  "correctsWeightRecordId": null,
  "correctionReason": null,
  "createdAt": null,
} satisfies WeightRecord

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as WeightRecord
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



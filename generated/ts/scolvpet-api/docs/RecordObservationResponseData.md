
# RecordObservationResponseData


## Properties

Name | Type
------------ | -------------
`observation` | [MatingObservation](MatingObservation.md)
`pairingAttemptVersion` | number
`baselineCandidateAt` | Date

## Example

```typescript
import type { RecordObservationResponseData } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "observation": null,
  "pairingAttemptVersion": null,
  "baselineCandidateAt": null,
} satisfies RecordObservationResponseData

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as RecordObservationResponseData
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



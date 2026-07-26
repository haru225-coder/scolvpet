
# MatingObservation


## Properties

Name | Type
------------ | -------------
`id` | string
`pairingAttemptId` | string
`observedAt` | Date
`type` | [ObservationType](ObservationType.md)
`durationSeconds` | number
`severity` | [Severity](Severity.md)
`confidence` | number
`mediaIds` | Array&lt;string&gt;
`notes` | string
`createdAt` | Date

## Example

```typescript
import type { MatingObservation } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "pairingAttemptId": null,
  "observedAt": null,
  "type": null,
  "durationSeconds": null,
  "severity": null,
  "confidence": null,
  "mediaIds": null,
  "notes": null,
  "createdAt": null,
} satisfies MatingObservation

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as MatingObservation
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



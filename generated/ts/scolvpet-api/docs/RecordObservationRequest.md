
# RecordObservationRequest


## Properties

Name | Type
------------ | -------------
`observedAt` | Date
`type` | [ObservationType](ObservationType.md)
`durationSeconds` | number
`severity` | [Severity](Severity.md)
`confidence` | number
`mediaIds` | Set&lt;string&gt;
`notes` | string

## Example

```typescript
import type { RecordObservationRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "observedAt": null,
  "type": null,
  "durationSeconds": null,
  "severity": null,
  "confidence": null,
  "mediaIds": null,
  "notes": null,
} satisfies RecordObservationRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as RecordObservationRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



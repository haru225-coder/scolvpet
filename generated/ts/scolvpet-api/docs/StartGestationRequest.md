
# StartGestationRequest


## Properties

Name | Type
------------ | -------------
`pairingAttemptId` | string
`result` | string
`baselineAt` | Date
`timezone` | string
`notes` | string

## Example

```typescript
import type { StartGestationRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "pairingAttemptId": null,
  "result": null,
  "baselineAt": null,
  "timezone": null,
  "notes": null,
} satisfies StartGestationRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as StartGestationRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



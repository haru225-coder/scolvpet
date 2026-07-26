
# StartPairingRequest


## Properties

Name | Type
------------ | -------------
`enclosureId` | string
`startedAt` | Date
`timezone` | string
`notes` | string

## Example

```typescript
import type { StartPairingRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "enclosureId": null,
  "startedAt": null,
  "timezone": null,
  "notes": null,
} satisfies StartPairingRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as StartPairingRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



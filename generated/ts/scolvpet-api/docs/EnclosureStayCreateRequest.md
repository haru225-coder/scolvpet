
# EnclosureStayCreateRequest


## Properties

Name | Type
------------ | -------------
`hamsterId` | string
`purpose` | string
`pairingAttemptId` | string
`startedAt` | Date
`previousStayId` | string
`reason` | string

## Example

```typescript
import type { EnclosureStayCreateRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "hamsterId": null,
  "purpose": null,
  "pairingAttemptId": null,
  "startedAt": null,
  "previousStayId": null,
  "reason": null,
} satisfies EnclosureStayCreateRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as EnclosureStayCreateRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)




# EnclosureStay


## Properties

Name | Type
------------ | -------------
`id` | string
`enclosureId` | string
`hamsterId` | string
`purpose` | string
`pairingAttemptId` | string
`startedAt` | Date
`endedAt` | Date
`reason` | string
`version` | number

## Example

```typescript
import type { EnclosureStay } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "enclosureId": null,
  "hamsterId": null,
  "purpose": null,
  "pairingAttemptId": null,
  "startedAt": null,
  "endedAt": null,
  "reason": null,
  "version": null,
} satisfies EnclosureStay

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as EnclosureStay
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



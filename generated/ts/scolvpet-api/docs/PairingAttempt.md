
# PairingAttempt


## Properties

Name | Type
------------ | -------------
`id` | string
`breedingPlanId` | string
`sequence` | number
`enclosureId` | string
`startedAt` | Date
`endedAt` | Date
`separatedAt` | Date
`separationDeadline` | Date
`status` | [PairingAttemptStatus](PairingAttemptStatus.md)
`result` | [PairingResult](PairingResult.md)
`conflictLevel` | string
`sireDestinationEnclosureId` | string
`damDestinationEnclosureId` | string
`notes` | string
`version` | number

## Example

```typescript
import type { PairingAttempt } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "breedingPlanId": null,
  "sequence": null,
  "enclosureId": null,
  "startedAt": null,
  "endedAt": null,
  "separatedAt": null,
  "separationDeadline": null,
  "status": null,
  "result": null,
  "conflictLevel": null,
  "sireDestinationEnclosureId": null,
  "damDestinationEnclosureId": null,
  "notes": null,
  "version": null,
} satisfies PairingAttempt

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as PairingAttempt
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



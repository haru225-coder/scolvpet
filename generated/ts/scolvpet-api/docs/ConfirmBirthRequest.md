
# ConfirmBirthRequest


## Properties

Name | Type
------------ | -------------
`bornAt` | Date
`enclosureId` | string
`initialAliveCount` | number
`initialOtherCount` | number
`damCondition` | [DamCondition](DamCondition.md)
`outcomeReason` | string
`temporaryCodePrefix` | string
`temporaryCodes` | Set&lt;string&gt;
`timezone` | string
`notes` | string

## Example

```typescript
import type { ConfirmBirthRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "bornAt": null,
  "enclosureId": null,
  "initialAliveCount": null,
  "initialOtherCount": null,
  "damCondition": null,
  "outcomeReason": null,
  "temporaryCodePrefix": null,
  "temporaryCodes": null,
  "timezone": null,
  "notes": null,
} satisfies ConfirmBirthRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as ConfirmBirthRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



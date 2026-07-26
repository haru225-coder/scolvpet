
# Litter


## Properties

Name | Type
------------ | -------------
`id` | string
`ownerId` | string
`origin` | string
`code` | string
`breedingPlanId` | string
`sireId` | string
`damId` | string
`bornAt` | Date
`initialAliveCount` | number
`initialOtherCount` | number
`currentManagedCount` | number
`state` | [LitterState](LitterState.md)
`enclosureId` | string
`damCondition` | [DamCondition](DamCondition.md)
`weanedAt` | Date
`sexSeparatedAt` | Date
`reconciledAt` | Date
`notes` | string
`version` | number
`createdAt` | Date
`updatedAt` | Date

## Example

```typescript
import type { Litter } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "ownerId": null,
  "origin": null,
  "code": null,
  "breedingPlanId": null,
  "sireId": null,
  "damId": null,
  "bornAt": null,
  "initialAliveCount": null,
  "initialOtherCount": null,
  "currentManagedCount": null,
  "state": null,
  "enclosureId": null,
  "damCondition": null,
  "weanedAt": null,
  "sexSeparatedAt": null,
  "reconciledAt": null,
  "notes": null,
  "version": null,
  "createdAt": null,
  "updatedAt": null,
} satisfies Litter

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as Litter
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



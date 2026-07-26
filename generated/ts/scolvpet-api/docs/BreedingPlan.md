
# BreedingPlan


## Properties

Name | Type
------------ | -------------
`id` | string
`ownerId` | string
`name` | string
`sireId` | string
`damId` | string
`ruleVersionId` | string
`state` | [BreedingPlanState](BreedingPlanState.md)
`plannedPairingAt` | Date
`matingBaselineAt` | Date
`expectedBirthStart` | Date
`expectedBirthEnd` | Date
`actualBirthAt` | Date
`activePairingAttemptId` | string
`litterId` | string
`objectiveTraits` | { [key: string]: any; }
`kinshipCheck` | [KinshipCheck](KinshipCheck.md)
`notes` | string
`version` | number
`createdAt` | Date
`updatedAt` | Date

## Example

```typescript
import type { BreedingPlan } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "ownerId": null,
  "name": null,
  "sireId": null,
  "damId": null,
  "ruleVersionId": null,
  "state": null,
  "plannedPairingAt": null,
  "matingBaselineAt": null,
  "expectedBirthStart": null,
  "expectedBirthEnd": null,
  "actualBirthAt": null,
  "activePairingAttemptId": null,
  "litterId": null,
  "objectiveTraits": null,
  "kinshipCheck": null,
  "notes": null,
  "version": null,
  "createdAt": null,
  "updatedAt": null,
} satisfies BreedingPlan

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as BreedingPlan
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



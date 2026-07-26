
# ConfirmBirthNoLitterData

此分支不存在 litter、litter_count_event、pup_identity 或窝仔阶段任务字段

## Properties

Name | Type
------------ | -------------
`resultType` | string
`breedingPlan` | [BreedingPlan](BreedingPlan.md)
`birthEventId` | string
`eventType` | string
`bornAt` | Date
`initialOtherCount` | number
`outcomeReason` | string
`damCondition` | [DamCondition](DamCondition.md)
`celebrationJob` | [AsyncJob](AsyncJob.md)

## Example

```typescript
import type { ConfirmBirthNoLitterData } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "resultType": null,
  "breedingPlan": null,
  "birthEventId": null,
  "eventType": null,
  "bornAt": null,
  "initialOtherCount": null,
  "outcomeReason": null,
  "damCondition": null,
  "celebrationJob": null,
} satisfies ConfirmBirthNoLitterData

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as ConfirmBirthNoLitterData
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



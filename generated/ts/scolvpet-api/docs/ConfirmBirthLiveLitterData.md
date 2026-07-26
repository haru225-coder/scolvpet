
# ConfirmBirthLiveLitterData


## Properties

Name | Type
------------ | -------------
`resultType` | string
`breedingPlan` | [BreedingPlan](BreedingPlan.md)
`litter` | [Litter](Litter.md)
`pupIdentityCount` | number
`pupIdentities` | [Array&lt;PupIdentity&gt;](PupIdentity.md)
`initialCountEvent` | [LitterCountEvent](LitterCountEvent.md)
`celebrationJob` | [AsyncJob](AsyncJob.md)

## Example

```typescript
import type { ConfirmBirthLiveLitterData } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "resultType": null,
  "breedingPlan": null,
  "litter": null,
  "pupIdentityCount": null,
  "pupIdentities": null,
  "initialCountEvent": null,
  "celebrationJob": null,
} satisfies ConfirmBirthLiveLitterData

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as ConfirmBirthLiveLitterData
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



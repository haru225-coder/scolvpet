
# BreedingPlanUpdateRequest


## Properties

Name | Type
------------ | -------------
`name` | string
`sireId` | string
`damId` | string
`ruleVersionId` | string
`plannedPairingAt` | Date
`objectiveTraits` | { [key: string]: any; }
`notes` | string

## Example

```typescript
import type { BreedingPlanUpdateRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "name": null,
  "sireId": null,
  "damId": null,
  "ruleVersionId": null,
  "plannedPairingAt": null,
  "objectiveTraits": null,
  "notes": null,
} satisfies BreedingPlanUpdateRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as BreedingPlanUpdateRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)




# StartPairingResponseData


## Properties

Name | Type
------------ | -------------
`breedingPlan` | [BreedingPlan](BreedingPlan.md)
`pairingAttempt` | [PairingAttempt](PairingAttempt.md)

## Example

```typescript
import type { StartPairingResponseData } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "breedingPlan": null,
  "pairingAttempt": null,
} satisfies StartPairingResponseData

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as StartPairingResponseData
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



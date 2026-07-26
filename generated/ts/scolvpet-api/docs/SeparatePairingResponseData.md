
# SeparatePairingResponseData


## Properties

Name | Type
------------ | -------------
`pairingAttempt` | [PairingAttempt](PairingAttempt.md)
`breedingPlan` | [BreedingPlan](BreedingPlan.md)
`createdStays` | [Array&lt;EnclosureStay&gt;](EnclosureStay.md)
`createdTaskIds` | Array&lt;string&gt;

## Example

```typescript
import type { SeparatePairingResponseData } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "pairingAttempt": null,
  "breedingPlan": null,
  "createdStays": null,
  "createdTaskIds": null,
} satisfies SeparatePairingResponseData

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as SeparatePairingResponseData
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



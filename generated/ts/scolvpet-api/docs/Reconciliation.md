
# Reconciliation


## Properties

Name | Type
------------ | -------------
`initialAliveCount` | number
`discoveredCount` | number
`deceasedCount` | number
`transferredCount` | number
`expectedManagedCount` | number
`unindividualizedAliveCount` | number
`individualizedAliveCount` | number
`difference` | number
`closed` | boolean

## Example

```typescript
import type { Reconciliation } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "initialAliveCount": null,
  "discoveredCount": null,
  "deceasedCount": null,
  "transferredCount": null,
  "expectedManagedCount": null,
  "unindividualizedAliveCount": null,
  "individualizedAliveCount": null,
  "difference": null,
  "closed": null,
} satisfies Reconciliation

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as Reconciliation
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



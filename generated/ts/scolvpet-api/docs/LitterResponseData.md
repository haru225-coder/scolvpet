
# LitterResponseData


## Properties

Name | Type
------------ | -------------
`litter` | [Litter](Litter.md)
`reconciliation` | [Reconciliation](Reconciliation.md)

## Example

```typescript
import type { LitterResponseData } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "litter": null,
  "reconciliation": null,
} satisfies LitterResponseData

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as LitterResponseData
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



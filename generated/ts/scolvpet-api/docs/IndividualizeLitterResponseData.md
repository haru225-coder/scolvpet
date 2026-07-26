
# IndividualizeLitterResponseData


## Properties

Name | Type
------------ | -------------
`litterId` | string
`evaluatedEligibleSetToken` | string
`evaluatedEligibleCount` | number
`mappings` | [Array&lt;IndividualizeMapping&gt;](IndividualizeMapping.md)
`createdLitterMemberCount` | number
`createdParentageCount` | number
`reconciliation` | [Reconciliation](Reconciliation.md)
`litterVersion` | number

## Example

```typescript
import type { IndividualizeLitterResponseData } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "litterId": null,
  "evaluatedEligibleSetToken": null,
  "evaluatedEligibleCount": null,
  "mappings": null,
  "createdLitterMemberCount": null,
  "createdParentageCount": null,
  "reconciliation": null,
  "litterVersion": null,
} satisfies IndividualizeLitterResponseData

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as IndividualizeLitterResponseData
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



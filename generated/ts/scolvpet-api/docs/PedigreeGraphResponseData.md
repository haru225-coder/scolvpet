
# PedigreeGraphResponseData


## Properties

Name | Type
------------ | -------------
`rootHamsterId` | string
`nodes` | [Array&lt;Hamster&gt;](Hamster.md)
`parentages` | [Array&lt;PedigreeParentage&gt;](PedigreeParentage.md)
`litterParents` | [Array&lt;LitterParent&gt;](LitterParent.md)
`litterMembers` | [Array&lt;LitterMember&gt;](LitterMember.md)
`commonAncestors` | [Array&lt;PedigreeGraphResponseDataCommonAncestorsInner&gt;](PedigreeGraphResponseDataCommonAncestorsInner.md)

## Example

```typescript
import type { PedigreeGraphResponseData } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "rootHamsterId": null,
  "nodes": null,
  "parentages": null,
  "litterParents": null,
  "litterMembers": null,
  "commonAncestors": null,
} satisfies PedigreeGraphResponseData

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as PedigreeGraphResponseData
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



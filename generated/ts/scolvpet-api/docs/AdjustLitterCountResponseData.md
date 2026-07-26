
# AdjustLitterCountResponseData


## Properties

Name | Type
------------ | -------------
`litter` | [Litter](Litter.md)
`countEvent` | [LitterCountEvent](LitterCountEvent.md)
`createdPupIdentities` | [Array&lt;PupIdentity&gt;](PupIdentity.md)
`closedPupIdentityIds` | Array&lt;string&gt;
`reconciliation` | [Reconciliation](Reconciliation.md)

## Example

```typescript
import type { AdjustLitterCountResponseData } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "litter": null,
  "countEvent": null,
  "createdPupIdentities": null,
  "closedPupIdentityIds": null,
  "reconciliation": null,
} satisfies AdjustLitterCountResponseData

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as AdjustLitterCountResponseData
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



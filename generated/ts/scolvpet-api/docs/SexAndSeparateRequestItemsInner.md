
# SexAndSeparateRequestItemsInner


## Properties

Name | Type
------------ | -------------
`pupIdentityId` | string
`sex` | [Sex](Sex.md)
`sexConfidence` | number
`destinationEnclosureId` | string
`requiresRecheck` | boolean
`notes` | string

## Example

```typescript
import type { SexAndSeparateRequestItemsInner } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "pupIdentityId": null,
  "sex": null,
  "sexConfidence": null,
  "destinationEnclosureId": null,
  "requiresRecheck": null,
  "notes": null,
} satisfies SexAndSeparateRequestItemsInner

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as SexAndSeparateRequestItemsInner
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



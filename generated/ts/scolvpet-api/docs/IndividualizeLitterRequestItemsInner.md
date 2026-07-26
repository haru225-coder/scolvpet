
# IndividualizeLitterRequestItemsInner


## Properties

Name | Type
------------ | -------------
`pupIdentityId` | string
`internalCode` | string
`name` | string
`varietyCode` | string
`coverMediaId` | string
`notes` | string

## Example

```typescript
import type { IndividualizeLitterRequestItemsInner } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "pupIdentityId": null,
  "internalCode": null,
  "name": null,
  "varietyCode": null,
  "coverMediaId": null,
  "notes": null,
} satisfies IndividualizeLitterRequestItemsInner

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as IndividualizeLitterRequestItemsInner
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



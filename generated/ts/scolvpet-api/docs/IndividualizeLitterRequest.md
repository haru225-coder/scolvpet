
# IndividualizeLitterRequest


## Properties

Name | Type
------------ | -------------
`individualizedAt` | Date
`timezone` | string
`eligibleSetToken` | string
`items` | [Array&lt;IndividualizeLitterRequestItemsInner&gt;](IndividualizeLitterRequestItemsInner.md)

## Example

```typescript
import type { IndividualizeLitterRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "individualizedAt": null,
  "timezone": null,
  "eligibleSetToken": null,
  "items": null,
} satisfies IndividualizeLitterRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as IndividualizeLitterRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



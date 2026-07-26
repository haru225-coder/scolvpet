
# WeanLitterRequest


## Properties

Name | Type
------------ | -------------
`weanedAt` | Date
`timezone` | string
`items` | [Array&lt;WeanLitterRequestItemsInner&gt;](WeanLitterRequestItemsInner.md)

## Example

```typescript
import type { WeanLitterRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "weanedAt": null,
  "timezone": null,
  "items": null,
} satisfies WeanLitterRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as WeanLitterRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



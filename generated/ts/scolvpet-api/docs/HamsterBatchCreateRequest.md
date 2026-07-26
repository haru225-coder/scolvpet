
# HamsterBatchCreateRequest


## Properties

Name | Type
------------ | -------------
`atomic` | boolean
`items` | [Array&lt;HamsterBatchCreateRequestItemsInner&gt;](HamsterBatchCreateRequestItemsInner.md)

## Example

```typescript
import type { HamsterBatchCreateRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "atomic": null,
  "items": null,
} satisfies HamsterBatchCreateRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as HamsterBatchCreateRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



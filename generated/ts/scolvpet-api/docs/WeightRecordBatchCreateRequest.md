
# WeightRecordBatchCreateRequest


## Properties

Name | Type
------------ | -------------
`taskId` | string
`items` | [Array&lt;WeightRecordBatchCreateRequestItemsInner&gt;](WeightRecordBatchCreateRequestItemsInner.md)

## Example

```typescript
import type { WeightRecordBatchCreateRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "taskId": null,
  "items": null,
} satisfies WeightRecordBatchCreateRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as WeightRecordBatchCreateRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)




# WeightRecordBatchCreateResponseData


## Properties

Name | Type
------------ | -------------
`transactionStatus` | [BatchTransactionStatus](BatchTransactionStatus.md)
`succeededCount` | number
`failedCount` | number
`alertCount` | number
`items` | [Array&lt;WeightRecordBatchCreateResponseDataItemsInner&gt;](WeightRecordBatchCreateResponseDataItemsInner.md)

## Example

```typescript
import type { WeightRecordBatchCreateResponseData } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "transactionStatus": null,
  "succeededCount": null,
  "failedCount": null,
  "alertCount": null,
  "items": null,
} satisfies WeightRecordBatchCreateResponseData

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as WeightRecordBatchCreateResponseData
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



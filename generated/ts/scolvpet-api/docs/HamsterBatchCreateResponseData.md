
# HamsterBatchCreateResponseData


## Properties

Name | Type
------------ | -------------
`transactionStatus` | [BatchTransactionStatus](BatchTransactionStatus.md)
`succeededCount` | number
`failedCount` | number
`items` | [Array&lt;HamsterBatchCreateResponseDataItemsInner&gt;](HamsterBatchCreateResponseDataItemsInner.md)

## Example

```typescript
import type { HamsterBatchCreateResponseData } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "transactionStatus": null,
  "succeededCount": null,
  "failedCount": null,
  "items": null,
} satisfies HamsterBatchCreateResponseData

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as HamsterBatchCreateResponseData
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



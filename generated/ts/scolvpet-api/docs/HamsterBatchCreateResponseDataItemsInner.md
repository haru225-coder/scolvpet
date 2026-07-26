
# HamsterBatchCreateResponseDataItemsInner


## Properties

Name | Type
------------ | -------------
`clientItemId` | string
`status` | [BatchItemStatus](BatchItemStatus.md)
`resource` | [Hamster](Hamster.md)
`error` | [ErrorObject](ErrorObject.md)

## Example

```typescript
import type { HamsterBatchCreateResponseDataItemsInner } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "clientItemId": null,
  "status": null,
  "resource": null,
  "error": null,
} satisfies HamsterBatchCreateResponseDataItemsInner

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as HamsterBatchCreateResponseDataItemsInner
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



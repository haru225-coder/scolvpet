
# CompleteTaskResponseDataItemResultsInner


## Properties

Name | Type
------------ | -------------
`subjectId` | string
`status` | [BatchItemStatus](BatchItemStatus.md)
`completionRecordId` | string
`error` | [ErrorObject](ErrorObject.md)

## Example

```typescript
import type { CompleteTaskResponseDataItemResultsInner } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "subjectId": null,
  "status": null,
  "completionRecordId": null,
  "error": null,
} satisfies CompleteTaskResponseDataItemResultsInner

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as CompleteTaskResponseDataItemResultsInner
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



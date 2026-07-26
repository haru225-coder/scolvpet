
# CompleteTaskResponseData


## Properties

Name | Type
------------ | -------------
`task` | [CareTask](CareTask.md)
`itemResults` | [Array&lt;CompleteTaskResponseDataItemResultsInner&gt;](CompleteTaskResponseDataItemResultsInner.md)
`autoClosed` | boolean

## Example

```typescript
import type { CompleteTaskResponseData } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "task": null,
  "itemResults": null,
  "autoClosed": null,
} satisfies CompleteTaskResponseData

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as CompleteTaskResponseData
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)




# AssistantMessageListResponse


## Properties

Name | Type
------------ | -------------
`data` | [Array&lt;AssistantMessage&gt;](AssistantMessage.md)
`page` | { [key: string]: any; }
`meta` | [ResponseMeta](ResponseMeta.md)

## Example

```typescript
import type { AssistantMessageListResponse } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "data": null,
  "page": null,
  "meta": null,
} satisfies AssistantMessageListResponse

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as AssistantMessageListResponse
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)




# ImportRowResultListResponse


## Properties

Name | Type
------------ | -------------
`data` | [Array&lt;ImportRowResult&gt;](ImportRowResult.md)
`page` | [PageInfo](PageInfo.md)
`meta` | [ResponseMeta](ResponseMeta.md)

## Example

```typescript
import type { ImportRowResultListResponse } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "data": null,
  "page": null,
  "meta": null,
} satisfies ImportRowResultListResponse

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as ImportRowResultListResponse
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)




# UpsertWechatSubscriptionsRequest


## Properties

Name | Type
------------ | -------------
`templates` | { [key: string]: string; }
`page` | string

## Example

```typescript
import type { UpsertWechatSubscriptionsRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "templates": null,
  "page": null,
} satisfies UpsertWechatSubscriptionsRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as UpsertWechatSubscriptionsRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


# SendWechatSubscriptionRequest


## Properties

Name | Type
------------ | -------------
`templateId` | string
`page` | string
`data` | { [key: string]: string; }

## Example

```typescript
import type { SendWechatSubscriptionRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "templateId": null,
  "page": null,
  "data": null,
} satisfies SendWechatSubscriptionRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as SendWechatSubscriptionRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)

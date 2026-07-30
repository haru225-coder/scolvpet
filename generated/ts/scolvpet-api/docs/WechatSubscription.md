
# WechatSubscription


## Properties

Name | Type
------------ | -------------
`id` | string
`templateId` | string
`status` | string
`page` | string
`grantedAt` | Date
`lastSentAt` | Date
`version` | number

## Example

```typescript
import type { WechatSubscription } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "templateId": null,
  "status": null,
  "page": null,
  "grantedAt": null,
  "lastSentAt": null,
  "version": null,
} satisfies WechatSubscription

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as WechatSubscription
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



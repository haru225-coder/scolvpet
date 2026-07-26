
# CustomerWechatBindTicketResponseData


## Properties

Name | Type
------------ | -------------
`bindRequired` | boolean
`wechatTicket` | string

## Example

```typescript
import type { CustomerWechatBindTicketResponseData } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "bindRequired": true,
  "wechatTicket": null,
} satisfies CustomerWechatBindTicketResponseData

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as CustomerWechatBindTicketResponseData
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



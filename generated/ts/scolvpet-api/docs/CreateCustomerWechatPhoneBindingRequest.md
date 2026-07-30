
# CreateCustomerWechatPhoneBindingRequest


## Properties

Name | Type
------------ | -------------
`wechatTicket` | string
`phoneCode` | string

## Example

```typescript
import type { CreateCustomerWechatPhoneBindingRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "wechatTicket": null,
  "phoneCode": null,
} satisfies CreateCustomerWechatPhoneBindingRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as CreateCustomerWechatPhoneBindingRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)




# CreateCustomerSessionRequest


## Properties

Name | Type
------------ | -------------
`phone` | string
`verificationId` | string
`code` | string

## Example

```typescript
import type { CreateCustomerSessionRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "phone": null,
  "verificationId": null,
  "code": null,
} satisfies CreateCustomerSessionRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as CreateCustomerSessionRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



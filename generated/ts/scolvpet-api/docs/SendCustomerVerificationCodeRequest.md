
# SendCustomerVerificationCodeRequest


## Properties

Name | Type
------------ | -------------
`phone` | string
`purpose` | string

## Example

```typescript
import type { SendCustomerVerificationCodeRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "phone": +8613800138000,
  "purpose": null,
} satisfies SendCustomerVerificationCodeRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as SendCustomerVerificationCodeRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



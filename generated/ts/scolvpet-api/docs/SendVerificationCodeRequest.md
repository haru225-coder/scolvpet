
# SendVerificationCodeRequest


## Properties

Name | Type
------------ | -------------
`phone` | string
`purpose` | string

## Example

```typescript
import type { SendVerificationCodeRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "phone": null,
  "purpose": null,
} satisfies SendVerificationCodeRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as SendVerificationCodeRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



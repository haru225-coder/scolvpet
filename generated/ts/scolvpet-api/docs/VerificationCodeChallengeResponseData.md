
# VerificationCodeChallengeResponseData


## Properties

Name | Type
------------ | -------------
`verificationId` | string
`expiresInSeconds` | number
`retryAfterSeconds` | number

## Example

```typescript
import type { VerificationCodeChallengeResponseData } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "verificationId": null,
  "expiresInSeconds": null,
  "retryAfterSeconds": null,
} satisfies VerificationCodeChallengeResponseData

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as VerificationCodeChallengeResponseData
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



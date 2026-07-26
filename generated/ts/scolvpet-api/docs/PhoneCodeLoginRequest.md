
# PhoneCodeLoginRequest


## Properties

Name | Type
------------ | -------------
`phone` | string
`verificationId` | string
`code` | string
`device` | [DeviceInfo](DeviceInfo.md)

## Example

```typescript
import type { PhoneCodeLoginRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "phone": null,
  "verificationId": null,
  "code": null,
  "device": null,
} satisfies PhoneCodeLoginRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as PhoneCodeLoginRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



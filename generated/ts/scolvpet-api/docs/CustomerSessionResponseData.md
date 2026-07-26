
# CustomerSessionResponseData


## Properties

Name | Type
------------ | -------------
`tokenType` | string
`accessToken` | string
`expiresInSeconds` | number
`phone` | string

## Example

```typescript
import type { CustomerSessionResponseData } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "tokenType": Bearer,
  "accessToken": null,
  "expiresInSeconds": null,
  "phone": null,
} satisfies CustomerSessionResponseData

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as CustomerSessionResponseData
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



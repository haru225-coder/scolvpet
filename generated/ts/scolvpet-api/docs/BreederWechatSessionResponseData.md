
# BreederWechatSessionResponseData


## Properties

Name | Type
------------ | -------------
`bindRequired` | boolean
`wechatTicket` | string
`tokenType` | string
`accessToken` | string
`expiresInSeconds` | number
`refreshToken` | string
`account` | [Account](Account.md)
`currentOrganization` | [Organization](Organization.md)
`memberRole` | string
`capabilities` | Array&lt;string&gt;

## Example

```typescript
import type { BreederWechatSessionResponseData } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "bindRequired": null,
  "wechatTicket": null,
  "tokenType": null,
  "accessToken": null,
  "expiresInSeconds": null,
  "refreshToken": null,
  "account": null,
  "currentOrganization": null,
  "memberRole": null,
  "capabilities": null,
} satisfies BreederWechatSessionResponseData

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as BreederWechatSessionResponseData
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)

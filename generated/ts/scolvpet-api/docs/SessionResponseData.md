
# SessionResponseData


## Properties

Name | Type
------------ | -------------
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
import type { SessionResponseData } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "tokenType": null,
  "accessToken": null,
  "expiresInSeconds": null,
  "refreshToken": null,
  "account": null,
  "currentOrganization": null,
  "memberRole": null,
  "capabilities": null,
} satisfies SessionResponseData

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as SessionResponseData
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



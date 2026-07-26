
# UsageResponseDataEntitlement


## Properties

Name | Type
------------ | -------------
`planCode` | string
`enforcement` | string
`effectiveAt` | Date
`expiresAt` | Date

## Example

```typescript
import type { UsageResponseDataEntitlement } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "planCode": null,
  "enforcement": null,
  "effectiveAt": null,
  "expiresAt": null,
} satisfies UsageResponseDataEntitlement

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as UsageResponseDataEntitlement
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



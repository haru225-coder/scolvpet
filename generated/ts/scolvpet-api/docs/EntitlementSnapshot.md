
# EntitlementSnapshot


## Properties

Name | Type
------------ | -------------
`planCode` | string
`planTitle` | string
`enforcement` | string
`source` | string
`effectiveAt` | Date
`expiresAt` | Date
`features` | [Array&lt;EntitlementFeature&gt;](EntitlementFeature.md)
`limits` | [Array&lt;EntitlementLimit&gt;](EntitlementLimit.md)
`overLimit` | boolean
`paywallHint` | string

## Example

```typescript
import type { EntitlementSnapshot } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "planCode": null,
  "planTitle": null,
  "enforcement": null,
  "source": null,
  "effectiveAt": null,
  "expiresAt": null,
  "features": null,
  "limits": null,
  "overLimit": null,
  "paywallHint": null,
} satisfies EntitlementSnapshot

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as EntitlementSnapshot
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



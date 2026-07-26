
# EntitlementCheckResult


## Properties

Name | Type
------------ | -------------
`allowed` | boolean
`enforcement` | string
`planCode` | string
`reason` | string
`feature` | string
`metric` | string
`used` | number
`limit` | number

## Example

```typescript
import type { EntitlementCheckResult } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "allowed": null,
  "enforcement": null,
  "planCode": null,
  "reason": null,
  "feature": null,
  "metric": null,
  "used": null,
  "limit": null,
} satisfies EntitlementCheckResult

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as EntitlementCheckResult
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



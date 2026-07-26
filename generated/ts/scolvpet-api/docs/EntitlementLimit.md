
# EntitlementLimit


## Properties

Name | Type
------------ | -------------
`code` | string
`metric` | string
`title` | string
`limit` | number
`used` | number
`remaining` | number
`over` | boolean
`unit` | string

## Example

```typescript
import type { EntitlementLimit } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "code": null,
  "metric": null,
  "title": null,
  "limit": null,
  "used": null,
  "remaining": null,
  "over": null,
  "unit": null,
} satisfies EntitlementLimit

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as EntitlementLimit
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)




# PlanCatalogEntry


## Properties

Name | Type
------------ | -------------
`code` | string
`title` | string
`description` | string
`priceHint` | string
`features` | { [key: string]: boolean; }
`limits` | { [key: string]: number; }
`enforcement` | string
`highlight` | boolean

## Example

```typescript
import type { PlanCatalogEntry } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "code": null,
  "title": null,
  "description": null,
  "priceHint": null,
  "features": null,
  "limits": null,
  "enforcement": null,
  "highlight": null,
} satisfies PlanCatalogEntry

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as PlanCatalogEntry
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



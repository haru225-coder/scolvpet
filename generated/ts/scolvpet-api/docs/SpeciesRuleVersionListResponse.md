
# SpeciesRuleVersionListResponse


## Properties

Name | Type
------------ | -------------
`data` | [Array&lt;SpeciesRuleVersion&gt;](SpeciesRuleVersion.md)
`page` | [PageInfo](PageInfo.md)
`meta` | [ResponseMeta](ResponseMeta.md)

## Example

```typescript
import type { SpeciesRuleVersionListResponse } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "data": null,
  "page": null,
  "meta": null,
} satisfies SpeciesRuleVersionListResponse

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as SpeciesRuleVersionListResponse
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



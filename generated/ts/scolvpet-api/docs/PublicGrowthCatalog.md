
# PublicGrowthCatalog


## Properties

Name | Type
------------ | -------------
`site` | { [key: string]: any; }
`hamsters` | [Array&lt;GrowthPublicHamster&gt;](GrowthPublicHamster.md)
`campaign` | [GrowthCampaign](GrowthCampaign.md)

## Example

```typescript
import type { PublicGrowthCatalog } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "site": null,
  "hamsters": null,
  "campaign": null,
} satisfies PublicGrowthCatalog

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as PublicGrowthCatalog
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



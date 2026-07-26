
# GrowthPublicHamsterRequest


## Properties

Name | Type
------------ | -------------
`publicName` | string
`summary` | string
`traits` | Array&lt;string&gt;
`filmingStatus` | string
`published` | boolean
`consultable` | boolean
`ctaText` | string
`priceLabel` | string

## Example

```typescript
import type { GrowthPublicHamsterRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "publicName": null,
  "summary": null,
  "traits": null,
  "filmingStatus": null,
  "published": null,
  "consultable": null,
  "ctaText": null,
  "priceLabel": null,
} satisfies GrowthPublicHamsterRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as GrowthPublicHamsterRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



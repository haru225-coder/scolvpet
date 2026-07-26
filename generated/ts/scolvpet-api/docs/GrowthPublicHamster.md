
# GrowthPublicHamster


## Properties

Name | Type
------------ | -------------
`hamsterId` | string
`publicName` | string
`summary` | string
`traits` | Array&lt;string&gt;
`sex` | string
`variety` | string
`birthDate` | Date
`filmingStatus` | string
`published` | boolean
`consultable` | boolean
`reservable` | boolean
`ctaText` | string
`priceLabel` | string
`media` | [Array&lt;GrowthPublicMedia&gt;](GrowthPublicMedia.md)

## Example

```typescript
import type { GrowthPublicHamster } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "hamsterId": null,
  "publicName": null,
  "summary": null,
  "traits": null,
  "sex": null,
  "variety": null,
  "birthDate": null,
  "filmingStatus": null,
  "published": null,
  "consultable": null,
  "reservable": null,
  "ctaText": null,
  "priceLabel": null,
  "media": null,
} satisfies GrowthPublicHamster

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as GrowthPublicHamster
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



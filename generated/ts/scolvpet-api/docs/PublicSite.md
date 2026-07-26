
# PublicSite


## Properties

Name | Type
------------ | -------------
`id` | string
`slug` | string
`title` | string
`tagline` | string
`about` | string
`contactWechat` | string
`contactPhone` | string
`themeColor` | string
`showStats` | boolean
`showContact` | boolean
`published` | boolean
`publishedAt` | Date
`version` | number
`updatedAt` | Date
`publicUrlPath` | string

## Example

```typescript
import type { PublicSite } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "slug": null,
  "title": null,
  "tagline": null,
  "about": null,
  "contactWechat": null,
  "contactPhone": null,
  "themeColor": null,
  "showStats": null,
  "showContact": null,
  "published": null,
  "publishedAt": null,
  "version": null,
  "updatedAt": null,
  "publicUrlPath": /p/snow-cattery,
} satisfies PublicSite

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as PublicSite
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



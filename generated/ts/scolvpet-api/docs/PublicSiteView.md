
# PublicSiteView


## Properties

Name | Type
------------ | -------------
`slug` | string
`title` | string
`tagline` | string
`about` | string
`themeColor` | string
`contactWechat` | string
`contactPhone` | string
`stats` | { [key: string]: any; }
`organizationName` | string
`publishedAt` | Date

## Example

```typescript
import type { PublicSiteView } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "slug": null,
  "title": null,
  "tagline": null,
  "about": null,
  "themeColor": null,
  "contactWechat": null,
  "contactPhone": null,
  "stats": null,
  "organizationName": null,
  "publishedAt": null,
} satisfies PublicSiteView

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as PublicSiteView
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)




# UpsertPublicSiteRequest


## Properties

Name | Type
------------ | -------------
`slug` | string
`title` | string
`tagline` | string
`about` | string
`contactWechat` | string
`contactPhone` | string
`themeColor` | string
`showStats` | boolean
`showContact` | boolean

## Example

```typescript
import type { UpsertPublicSiteRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "slug": null,
  "title": null,
  "tagline": null,
  "about": null,
  "contactWechat": null,
  "contactPhone": null,
  "themeColor": null,
  "showStats": null,
  "showContact": null,
} satisfies UpsertPublicSiteRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as UpsertPublicSiteRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



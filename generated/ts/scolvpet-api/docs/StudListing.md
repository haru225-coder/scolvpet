
# StudListing


## Properties

Name | Type
------------ | -------------
`id` | string
`ownerId` | string
`sireLabel` | string
`title` | string
`feeCents` | number
`currency` | string
`notes` | string
`published` | boolean
`version` | number
`updatedAt` | Date
`catteryName` | string
`isMine` | boolean

## Example

```typescript
import type { StudListing } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "ownerId": null,
  "sireLabel": null,
  "title": null,
  "feeCents": null,
  "currency": null,
  "notes": null,
  "published": null,
  "version": null,
  "updatedAt": null,
  "catteryName": null,
  "isMine": null,
} satisfies StudListing

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as StudListing
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



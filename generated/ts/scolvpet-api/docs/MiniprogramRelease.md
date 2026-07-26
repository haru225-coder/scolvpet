
# MiniprogramRelease


## Properties

Name | Type
------------ | -------------
`id` | string
`versionLabel` | string
`status` | string
`title` | string
`summary` | string
`publicSlug` | string
`auditNote` | string
`submittedAt` | Date
`auditedAt` | Date
`publishedAt` | Date
`rolledBackAt` | Date
`version` | number
`createdAt` | Date
`updatedAt` | Date

## Example

```typescript
import type { MiniprogramRelease } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "versionLabel": null,
  "status": null,
  "title": null,
  "summary": null,
  "publicSlug": null,
  "auditNote": null,
  "submittedAt": null,
  "auditedAt": null,
  "publishedAt": null,
  "rolledBackAt": null,
  "version": null,
  "createdAt": null,
  "updatedAt": null,
} satisfies MiniprogramRelease

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as MiniprogramRelease
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



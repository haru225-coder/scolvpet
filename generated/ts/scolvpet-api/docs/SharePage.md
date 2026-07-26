
# SharePage


## Properties

Name | Type
------------ | -------------
`id` | string
`ownerId` | string
`subjectType` | string
`subjectId` | string
`status` | [ShareStatus](ShareStatus.md)
`fields` | [Set&lt;SharePublicField&gt;](SharePublicField.md)
`mediaIds` | Set&lt;string&gt;
`publicUrl` | string
`expiresAt` | Date
`revokedAt` | Date
`version` | number
`createdAt` | Date

## Example

```typescript
import type { SharePage } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "ownerId": null,
  "subjectType": null,
  "subjectId": null,
  "status": null,
  "fields": null,
  "mediaIds": null,
  "publicUrl": null,
  "expiresAt": null,
  "revokedAt": null,
  "version": null,
  "createdAt": null,
} satisfies SharePage

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as SharePage
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)




# Document


## Properties

Name | Type
------------ | -------------
`id` | string
`templateId` | string
`kind` | string
`contactId` | string
`handoverId` | string
`title` | string
`bodyFilled` | string
`amountCents` | number
`currency` | string
`status` | string
`issuedAt` | Date
`notes` | string
`version` | number
`contactName` | string
`publicToken` | string
`publicPath` | string
`publicUrl` | string

## Example

```typescript
import type { Document } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "templateId": null,
  "kind": null,
  "contactId": null,
  "handoverId": null,
  "title": null,
  "bodyFilled": null,
  "amountCents": null,
  "currency": null,
  "status": null,
  "issuedAt": null,
  "notes": null,
  "version": null,
  "contactName": null,
  "publicToken": null,
  "publicPath": null,
  "publicUrl": null,
} satisfies Document

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as Document
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



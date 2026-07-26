
# AccountingRecord


## Properties

Name | Type
------------ | -------------
`id` | string
`categoryId` | string
`entryType` | string
`amountCents` | number
`currency` | string
`title` | string
`notes` | string
`contactId` | string
`occurredAt` | Date
`version` | number
`categoryName` | string
`contactName` | string

## Example

```typescript
import type { AccountingRecord } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "categoryId": null,
  "entryType": null,
  "amountCents": null,
  "currency": null,
  "title": null,
  "notes": null,
  "contactId": null,
  "occurredAt": null,
  "version": null,
  "categoryName": null,
  "contactName": null,
} satisfies AccountingRecord

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as AccountingRecord
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



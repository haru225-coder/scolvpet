
# CreateAccountingRecordRequest


## Properties

Name | Type
------------ | -------------
`categoryId` | string
`entryType` | string
`amountCents` | number
`currency` | string
`title` | string
`notes` | string
`contactId` | string
`occurredAt` | Date

## Example

```typescript
import type { CreateAccountingRecordRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "categoryId": null,
  "entryType": null,
  "amountCents": null,
  "currency": null,
  "title": null,
  "notes": null,
  "contactId": null,
  "occurredAt": null,
} satisfies CreateAccountingRecordRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as CreateAccountingRecordRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



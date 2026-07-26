
# CreateReceiptRequest


## Properties

Name | Type
------------ | -------------
`templateId` | string
`contactId` | string
`handoverId` | string
`reservationId` | string
`title` | string
`amountCents` | number
`currency` | string
`notes` | string
`contactName` | string
`hamsterName` | string

## Example

```typescript
import type { CreateReceiptRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "templateId": null,
  "contactId": null,
  "handoverId": null,
  "reservationId": null,
  "title": null,
  "amountCents": null,
  "currency": null,
  "notes": null,
  "contactName": null,
  "hamsterName": null,
} satisfies CreateReceiptRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as CreateReceiptRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



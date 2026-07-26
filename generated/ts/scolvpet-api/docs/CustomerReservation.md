
# CustomerReservation


## Properties

Name | Type
------------ | -------------
`id` | string
`title` | string
`status` | string
`reservedAt` | Date
`holdExpiresAt` | Date
`updatedAt` | Date
`version` | number
`hamster` | [CustomerReservationHamster](CustomerReservationHamster.md)
`documents` | [Array&lt;CustomerReservationDocumentsInner&gt;](CustomerReservationDocumentsInner.md)

## Example

```typescript
import type { CustomerReservation } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "title": null,
  "status": null,
  "reservedAt": null,
  "holdExpiresAt": null,
  "updatedAt": null,
  "version": null,
  "hamster": null,
  "documents": null,
} satisfies CustomerReservation

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as CustomerReservation
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



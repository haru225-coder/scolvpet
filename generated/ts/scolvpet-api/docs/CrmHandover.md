
# CrmHandover


## Properties

Name | Type
------------ | -------------
`id` | string
`contactId` | string
`reservationId` | string
`hamsterId` | string
`status` | string
`scheduledAt` | Date
`completedAt` | Date
`notes` | string
`version` | number
`contactName` | string
`hamsterName` | string

## Example

```typescript
import type { CrmHandover } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "contactId": null,
  "reservationId": null,
  "hamsterId": null,
  "status": null,
  "scheduledAt": null,
  "completedAt": null,
  "notes": null,
  "version": null,
  "contactName": null,
  "hamsterName": null,
} satisfies CrmHandover

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as CrmHandover
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)




# CreateCrmHandoverRequest


## Properties

Name | Type
------------ | -------------
`contactId` | string
`reservationId` | string
`hamsterId` | string
`notes` | string
`scheduledAt` | Date

## Example

```typescript
import type { CreateCrmHandoverRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "contactId": null,
  "reservationId": null,
  "hamsterId": null,
  "notes": null,
  "scheduledAt": null,
} satisfies CreateCrmHandoverRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as CreateCrmHandoverRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)




# PublicGrowthReservationResponseData


## Properties

Name | Type
------------ | -------------
`reservationId` | string
`contactId` | string
`contactReused` | boolean
`hamsterId` | string
`status` | string
`title` | string
`siteId` | string

## Example

```typescript
import type { PublicGrowthReservationResponseData } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "reservationId": null,
  "contactId": null,
  "contactReused": null,
  "hamsterId": null,
  "status": null,
  "title": null,
  "siteId": null,
} satisfies PublicGrowthReservationResponseData

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as PublicGrowthReservationResponseData
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



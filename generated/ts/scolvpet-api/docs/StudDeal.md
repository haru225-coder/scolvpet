
# StudDeal


## Properties

Name | Type
------------ | -------------
`id` | string
`listingId` | string
`side` | string
`status` | string
`myHamsterLabel` | string
`partnerCatteryName` | string
`partnerContact` | string
`partnerAnimalLabel` | string
`feeCents` | number
`currency` | string
`notes` | string
`confirmedAt` | Date
`startedAt` | Date
`completedAt` | Date
`cancelledAt` | Date
`version` | number
`updatedAt` | Date

## Example

```typescript
import type { StudDeal } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "listingId": null,
  "side": null,
  "status": null,
  "myHamsterLabel": null,
  "partnerCatteryName": null,
  "partnerContact": null,
  "partnerAnimalLabel": null,
  "feeCents": null,
  "currency": null,
  "notes": null,
  "confirmedAt": null,
  "startedAt": null,
  "completedAt": null,
  "cancelledAt": null,
  "version": null,
  "updatedAt": null,
} satisfies StudDeal

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as StudDeal
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



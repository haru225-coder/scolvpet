
# CreateStudDealRequest


## Properties

Name | Type
------------ | -------------
`listingId` | string
`side` | string
`myHamsterLabel` | string
`partnerCatteryName` | string
`partnerContact` | string
`partnerAnimalLabel` | string
`feeCents` | number
`currency` | string
`notes` | string

## Example

```typescript
import type { CreateStudDealRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "listingId": null,
  "side": null,
  "myHamsterLabel": null,
  "partnerCatteryName": null,
  "partnerContact": null,
  "partnerAnimalLabel": null,
  "feeCents": null,
  "currency": null,
  "notes": null,
} satisfies CreateStudDealRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as CreateStudDealRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



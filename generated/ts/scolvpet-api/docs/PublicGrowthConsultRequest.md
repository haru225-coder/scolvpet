
# PublicGrowthConsultRequest


## Properties

Name | Type
------------ | -------------
`message` | string
`sessionToken` | string
`campaignCode` | string
`interestedHamsterId` | string
`landingPath` | string

## Example

```typescript
import type { PublicGrowthConsultRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "message": null,
  "sessionToken": null,
  "campaignCode": null,
  "interestedHamsterId": null,
  "landingPath": null,
} satisfies PublicGrowthConsultRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as PublicGrowthConsultRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



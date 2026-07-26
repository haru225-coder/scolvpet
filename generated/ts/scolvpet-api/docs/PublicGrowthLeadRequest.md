
# PublicGrowthLeadRequest

手机号和微信至少填写一个。

## Properties

Name | Type
------------ | -------------
`name` | string
`phone` | string
`wechat` | string
`campaignCode` | string
`consultationToken` | string
`interestedHamsterId` | string
`intentSummary` | string
`landingPath` | string

## Example

```typescript
import type { PublicGrowthLeadRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "name": null,
  "phone": null,
  "wechat": null,
  "campaignCode": null,
  "consultationToken": null,
  "interestedHamsterId": null,
  "intentSummary": null,
  "landingPath": null,
} satisfies PublicGrowthLeadRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as PublicGrowthLeadRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)




# GrowthLead


## Properties

Name | Type
------------ | -------------
`id` | string
`contactId` | string
`name` | string
`phone` | string
`wechat` | string
`campaignId` | string
`campaignCode` | string
`campaignTitle` | string
`consultationId` | string
`sourceChannel` | string
`landingPath` | string
`interestHamsterId` | string
`interestHamsterName` | string
`intentSummary` | string
`createdAt` | Date

## Example

```typescript
import type { GrowthLead } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "contactId": null,
  "name": null,
  "phone": null,
  "wechat": null,
  "campaignId": null,
  "campaignCode": null,
  "campaignTitle": null,
  "consultationId": null,
  "sourceChannel": null,
  "landingPath": null,
  "interestHamsterId": null,
  "interestHamsterName": null,
  "intentSummary": null,
  "createdAt": null,
} satisfies GrowthLead

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as GrowthLead
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



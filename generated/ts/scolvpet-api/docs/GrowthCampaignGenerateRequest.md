
# GrowthCampaignGenerateRequest


## Properties

Name | Type
------------ | -------------
`campaignType` | string
`platform` | string
`goal` | string
`durationSeconds` | number
`tone` | string
`cta` | string
`hamsterId` | string

## Example

```typescript
import type { GrowthCampaignGenerateRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "campaignType": null,
  "platform": null,
  "goal": null,
  "durationSeconds": null,
  "tone": null,
  "cta": null,
  "hamsterId": null,
} satisfies GrowthCampaignGenerateRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as GrowthCampaignGenerateRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



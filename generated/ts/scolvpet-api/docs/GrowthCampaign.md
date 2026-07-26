
# GrowthCampaign


## Properties

Name | Type
------------ | -------------
`id` | string
`campaignCode` | string
`campaignType` | string
`platform` | string
`status` | string
`subjectType` | string
`subjectId` | string
`title` | string
`goal` | string
`durationSeconds` | number
`tone` | string
`cta` | string
`factsSnapshot` | { [key: string]: any; }
`script` | [GrowthScript](GrowthScript.md)
`modelName` | string
`promptVersion` | string
`publishedAt` | Date
`version` | number
`publicUrlPath` | string
`createdAt` | Date
`updatedAt` | Date

## Example

```typescript
import type { GrowthCampaign } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "campaignCode": null,
  "campaignType": null,
  "platform": null,
  "status": null,
  "subjectType": null,
  "subjectId": null,
  "title": null,
  "goal": null,
  "durationSeconds": null,
  "tone": null,
  "cta": null,
  "factsSnapshot": null,
  "script": null,
  "modelName": null,
  "promptVersion": null,
  "publishedAt": null,
  "version": null,
  "publicUrlPath": null,
  "createdAt": null,
  "updatedAt": null,
} satisfies GrowthCampaign

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as GrowthCampaign
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)




# PublicGrowthConsultResponseData


## Properties

Name | Type
------------ | -------------
`sessionToken` | string
`consultationId` | string
`answer` | string
`recommendations` | Array&lt;{ [key: string]: any; }&gt;
`facts` | [Array&lt;GrowthPublicFact&gt;](GrowthPublicFact.md)
`handoffSuggested` | boolean

## Example

```typescript
import type { PublicGrowthConsultResponseData } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "sessionToken": null,
  "consultationId": null,
  "answer": null,
  "recommendations": null,
  "facts": null,
  "handoffSuggested": null,
} satisfies PublicGrowthConsultResponseData

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as PublicGrowthConsultResponseData
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



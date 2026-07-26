
# UpsertMiniprogramConfigRequest


## Properties

Name | Type
------------ | -------------
`displayName` | string
`appId` | string
`boundPublicSlug` | string
`enabled` | boolean

## Example

```typescript
import type { UpsertMiniprogramConfigRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "displayName": null,
  "appId": null,
  "boundPublicSlug": null,
  "enabled": null,
} satisfies UpsertMiniprogramConfigRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as UpsertMiniprogramConfigRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



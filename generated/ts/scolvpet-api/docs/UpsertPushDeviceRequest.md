
# UpsertPushDeviceRequest


## Properties

Name | Type
------------ | -------------
`platform` | string
`provider` | string
`token` | string
`deviceName` | string
`appVersion` | string

## Example

```typescript
import type { UpsertPushDeviceRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "platform": null,
  "provider": null,
  "token": null,
  "deviceName": null,
  "appVersion": null,
} satisfies UpsertPushDeviceRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as UpsertPushDeviceRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



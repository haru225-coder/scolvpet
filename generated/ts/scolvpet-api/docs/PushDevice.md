
# PushDevice


## Properties

Name | Type
------------ | -------------
`id` | string
`platform` | string
`provider` | string
`token` | string
`deviceName` | string
`appVersion` | string
`enabled` | boolean
`lastSeenAt` | Date
`version` | number

## Example

```typescript
import type { PushDevice } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "platform": null,
  "provider": null,
  "token": null,
  "deviceName": null,
  "appVersion": null,
  "enabled": null,
  "lastSeenAt": null,
  "version": null,
} satisfies PushDevice

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as PushDevice
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



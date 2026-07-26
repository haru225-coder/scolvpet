
# PushMessage


## Properties

Name | Type
------------ | -------------
`id` | string
`title` | string
`body` | string
`data` | { [key: string]: any; }
`status` | string
`targetDeviceId` | string
`provider` | string
`providerMessageId` | string
`attemptCount` | number
`lastError` | string
`sentAt` | Date
`version` | number
`createdAt` | Date

## Example

```typescript
import type { PushMessage } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "title": null,
  "body": null,
  "data": null,
  "status": null,
  "targetDeviceId": null,
  "provider": null,
  "providerMessageId": null,
  "attemptCount": null,
  "lastError": null,
  "sentAt": null,
  "version": null,
  "createdAt": null,
} satisfies PushMessage

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as PushMessage
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)




# Reminder


## Properties

Name | Type
------------ | -------------
`id` | string
`ruleCode` | string
`ruleVersion` | string
`baseEventId` | string
`targetType` | string
`targetId` | string
`scheduledAt` | Date
`state` | [ReminderState](ReminderState.md)
`supersededBy` | string
`channelStatuses` | [Array&lt;ReminderDelivery&gt;](ReminderDelivery.md)

## Example

```typescript
import type { Reminder } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "ruleCode": null,
  "ruleVersion": null,
  "baseEventId": null,
  "targetType": null,
  "targetId": null,
  "scheduledAt": null,
  "state": null,
  "supersededBy": null,
  "channelStatuses": null,
} satisfies Reminder

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as Reminder
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



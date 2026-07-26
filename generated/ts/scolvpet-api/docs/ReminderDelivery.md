
# ReminderDelivery


## Properties

Name | Type
------------ | -------------
`channel` | string
`status` | string
`dedupeKey` | string
`attemptedAt` | Date
`deliveredAt` | Date
`failureCode` | string

## Example

```typescript
import type { ReminderDelivery } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "channel": null,
  "status": null,
  "dedupeKey": null,
  "attemptedAt": null,
  "deliveredAt": null,
  "failureCode": null,
} satisfies ReminderDelivery

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as ReminderDelivery
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



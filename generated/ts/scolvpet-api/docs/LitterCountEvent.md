
# LitterCountEvent


## Properties

Name | Type
------------ | -------------
`id` | string
`litterId` | string
`eventType` | string
`delta` | number
`occurredAt` | Date
`reason` | string

## Example

```typescript
import type { LitterCountEvent } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "litterId": null,
  "eventType": null,
  "delta": null,
  "occurredAt": null,
  "reason": null,
} satisfies LitterCountEvent

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as LitterCountEvent
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



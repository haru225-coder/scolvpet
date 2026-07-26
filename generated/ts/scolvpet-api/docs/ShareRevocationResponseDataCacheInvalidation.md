
# ShareRevocationResponseDataCacheInvalidation


## Properties

Name | Type
------------ | -------------
`status` | string
`outboxEventId` | string
`queuedAt` | Date
`maxEdgeTtlSeconds` | number

## Example

```typescript
import type { ShareRevocationResponseDataCacheInvalidation } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "status": null,
  "outboxEventId": null,
  "queuedAt": null,
  "maxEdgeTtlSeconds": null,
} satisfies ShareRevocationResponseDataCacheInvalidation

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as ShareRevocationResponseDataCacheInvalidation
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



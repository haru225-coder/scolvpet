
# PairingAttemptListResponse


## Properties

Name | Type
------------ | -------------
`data` | [Array&lt;PairingAttempt&gt;](PairingAttempt.md)
`page` | [PageInfo](PageInfo.md)
`meta` | [ResponseMeta](ResponseMeta.md)

## Example

```typescript
import type { PairingAttemptListResponse } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "data": null,
  "page": null,
  "meta": null,
} satisfies PairingAttemptListResponse

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as PairingAttemptListResponse
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



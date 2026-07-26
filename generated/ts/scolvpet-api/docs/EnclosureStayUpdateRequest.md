
# EnclosureStayUpdateRequest


## Properties

Name | Type
------------ | -------------
`endedAt` | Date
`reason` | string
`correctionReason` | string

## Example

```typescript
import type { EnclosureStayUpdateRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "endedAt": null,
  "reason": null,
  "correctionReason": null,
} satisfies EnclosureStayUpdateRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as EnclosureStayUpdateRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



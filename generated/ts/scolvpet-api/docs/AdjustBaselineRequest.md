
# AdjustBaselineRequest


## Properties

Name | Type
------------ | -------------
`newBaselineAt` | Date
`reason` | string
`timezone` | string

## Example

```typescript
import type { AdjustBaselineRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "newBaselineAt": null,
  "reason": null,
  "timezone": null,
} satisfies AdjustBaselineRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as AdjustBaselineRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



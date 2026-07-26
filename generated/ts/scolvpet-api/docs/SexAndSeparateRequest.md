
# SexAndSeparateRequest


## Properties

Name | Type
------------ | -------------
`separatedAt` | Date
`timezone` | string
`items` | [Array&lt;SexAndSeparateRequestItemsInner&gt;](SexAndSeparateRequestItemsInner.md)

## Example

```typescript
import type { SexAndSeparateRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "separatedAt": null,
  "timezone": null,
  "items": null,
} satisfies SexAndSeparateRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as SexAndSeparateRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



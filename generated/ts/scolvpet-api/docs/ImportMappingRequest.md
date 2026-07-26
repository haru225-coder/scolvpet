
# ImportMappingRequest


## Properties

Name | Type
------------ | -------------
`timezone` | string
`mappings` | [Array&lt;ImportMappingRequestMappingsInner&gt;](ImportMappingRequestMappingsInner.md)

## Example

```typescript
import type { ImportMappingRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "timezone": null,
  "mappings": null,
} satisfies ImportMappingRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as ImportMappingRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



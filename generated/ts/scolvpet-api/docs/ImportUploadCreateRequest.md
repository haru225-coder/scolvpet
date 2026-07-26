
# ImportUploadCreateRequest


## Properties

Name | Type
------------ | -------------
`fileName` | string
`sizeBytes` | number
`sha256` | string

## Example

```typescript
import type { ImportUploadCreateRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "fileName": null,
  "sizeBytes": null,
  "sha256": null,
} satisfies ImportUploadCreateRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as ImportUploadCreateRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



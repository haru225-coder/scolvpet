
# MediaUploadCompleteRequest


## Properties

Name | Type
------------ | -------------
`objectEtag` | string
`sizeBytes` | number
`sha256` | string
`capturedAt` | Date
`timezone` | string

## Example

```typescript
import type { MediaUploadCompleteRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "objectEtag": null,
  "sizeBytes": null,
  "sha256": null,
  "capturedAt": null,
  "timezone": null,
} satisfies MediaUploadCompleteRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as MediaUploadCompleteRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)




# ImportJobCreateRequest


## Properties

Name | Type
------------ | -------------
`uploadId` | string
`templateType` | [ImportTemplateType](ImportTemplateType.md)
`templateVersion` | string
`sourceEncoding` | string
`timezone` | string

## Example

```typescript
import type { ImportJobCreateRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "uploadId": null,
  "templateType": null,
  "templateVersion": null,
  "sourceEncoding": null,
  "timezone": null,
} satisfies ImportJobCreateRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as ImportJobCreateRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



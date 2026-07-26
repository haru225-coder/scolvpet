
# BackupJobCreateRequest


## Properties

Name | Type
------------ | -------------
`includeMediaManifest` | boolean
`includeChecksums` | boolean
`timezone` | string
`encryptionHint` | string

## Example

```typescript
import type { BackupJobCreateRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "includeMediaManifest": null,
  "includeChecksums": null,
  "timezone": null,
  "encryptionHint": null,
} satisfies BackupJobCreateRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as BackupJobCreateRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



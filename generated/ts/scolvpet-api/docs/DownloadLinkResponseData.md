
# DownloadLinkResponseData


## Properties

Name | Type
------------ | -------------
`downloadUrl` | string
`expiresAt` | Date
`fileName` | string
`sizeBytes` | number
`sha256` | string

## Example

```typescript
import type { DownloadLinkResponseData } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "downloadUrl": null,
  "expiresAt": null,
  "fileName": null,
  "sizeBytes": null,
  "sha256": null,
} satisfies DownloadLinkResponseData

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as DownloadLinkResponseData
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



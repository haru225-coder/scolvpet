
# UploadSession


## Properties

Name | Type
------------ | -------------
`id` | string
`uploadUrl` | string
`method` | string
`headers` | { [key: string]: string; }
`objectKey` | string
`expiresAt` | Date
`version` | number

## Example

```typescript
import type { UploadSession } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "uploadUrl": null,
  "method": null,
  "headers": null,
  "objectKey": null,
  "expiresAt": null,
  "version": null,
} satisfies UploadSession

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as UploadSession
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



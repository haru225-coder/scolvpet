
# MediaAsset


## Properties

Name | Type
------------ | -------------
`id` | string
`ownerId` | string
`mediaType` | string
`contentType` | string
`sizeBytes` | number
`sha256` | string
`status` | string
`originalUrl` | string
`coverVariantId` | string
`variants` | [Array&lt;MediaVariant&gt;](MediaVariant.md)
`version` | number
`createdAt` | Date
`updatedAt` | Date

## Example

```typescript
import type { MediaAsset } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "ownerId": null,
  "mediaType": null,
  "contentType": null,
  "sizeBytes": null,
  "sha256": null,
  "status": null,
  "originalUrl": null,
  "coverVariantId": null,
  "variants": null,
  "version": null,
  "createdAt": null,
  "updatedAt": null,
} satisfies MediaAsset

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as MediaAsset
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



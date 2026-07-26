
# MediaVariant


## Properties

Name | Type
------------ | -------------
`id` | string
`kind` | string
`status` | string
`url` | string
`width` | number
`height` | number
`durationSeconds` | number

## Example

```typescript
import type { MediaVariant } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "kind": null,
  "status": null,
  "url": null,
  "width": null,
  "height": null,
  "durationSeconds": null,
} satisfies MediaVariant

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as MediaVariant
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)




# ImportTemplateResponseData


## Properties

Name | Type
------------ | -------------
`templateType` | [ImportTemplateType](ImportTemplateType.md)
`version` | string
`downloadUrl` | string
`expiresAt` | Date
`columns` | [Array&lt;ImportTemplateResponseDataColumnsInner&gt;](ImportTemplateResponseDataColumnsInner.md)

## Example

```typescript
import type { ImportTemplateResponseData } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "templateType": null,
  "version": null,
  "downloadUrl": null,
  "expiresAt": null,
  "columns": null,
} satisfies ImportTemplateResponseData

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as ImportTemplateResponseData
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



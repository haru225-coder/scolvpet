
# DocumentTemplate


## Properties

Name | Type
------------ | -------------
`id` | string
`kind` | string
`name` | string
`bodyText` | string
`version` | number

## Example

```typescript
import type { DocumentTemplate } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "kind": null,
  "name": null,
  "bodyText": null,
  "version": null,
} satisfies DocumentTemplate

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as DocumentTemplate
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



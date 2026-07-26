
# ImportIssue


## Properties

Name | Type
------------ | -------------
`rowNumber` | number
`columnName` | string
`code` | string
`message` | string
`severity` | string
`originalValue` | [ImportTemplateResponseDataColumnsInnerExample](ImportTemplateResponseDataColumnsInnerExample.md)
`suggestion` | string

## Example

```typescript
import type { ImportIssue } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "rowNumber": null,
  "columnName": null,
  "code": null,
  "message": null,
  "severity": null,
  "originalValue": null,
  "suggestion": null,
} satisfies ImportIssue

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as ImportIssue
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



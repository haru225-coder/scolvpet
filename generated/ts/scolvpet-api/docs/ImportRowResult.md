
# ImportRowResult


## Properties

Name | Type
------------ | -------------
`rowNumber` | number
`status` | [ImportRowStatus](ImportRowStatus.md)
`mappedValues` | { [key: string]: any; }
`resourceId` | string
`issues` | [Array&lt;ImportIssue&gt;](ImportIssue.md)

## Example

```typescript
import type { ImportRowResult } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "rowNumber": null,
  "status": null,
  "mappedValues": null,
  "resourceId": null,
  "issues": null,
} satisfies ImportRowResult

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as ImportRowResult
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



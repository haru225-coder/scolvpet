
# ActionItemResult


## Properties

Name | Type
------------ | -------------
`pupIdentityId` | string
`status` | [BatchItemStatus](BatchItemStatus.md)
`enclosureStayId` | string
`error` | [ErrorObject](ErrorObject.md)

## Example

```typescript
import type { ActionItemResult } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "pupIdentityId": null,
  "status": null,
  "enclosureStayId": null,
  "error": null,
} satisfies ActionItemResult

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as ActionItemResult
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



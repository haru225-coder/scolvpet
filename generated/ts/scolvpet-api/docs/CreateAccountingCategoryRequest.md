
# CreateAccountingCategoryRequest


## Properties

Name | Type
------------ | -------------
`entryType` | string
`name` | string
`sortOrder` | number

## Example

```typescript
import type { CreateAccountingCategoryRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "entryType": null,
  "name": null,
  "sortOrder": null,
} satisfies CreateAccountingCategoryRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as CreateAccountingCategoryRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



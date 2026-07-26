
# MediaEditRecipeRequest


## Properties

Name | Type
------------ | -------------
`operations` | [Array&lt;MediaEditRecipeRequestOperationsInner&gt;](MediaEditRecipeRequestOperationsInner.md)
`outputFormat` | string

## Example

```typescript
import type { MediaEditRecipeRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "operations": null,
  "outputFormat": null,
} satisfies MediaEditRecipeRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as MediaEditRecipeRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



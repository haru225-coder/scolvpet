
# CustomerSessionResponse


## Properties

Name | Type
------------ | -------------
`data` | [CustomerSessionResponseData](CustomerSessionResponseData.md)
`meta` | { [key: string]: any; }

## Example

```typescript
import type { CustomerSessionResponse } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "data": null,
  "meta": null,
} satisfies CustomerSessionResponse

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as CustomerSessionResponse
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



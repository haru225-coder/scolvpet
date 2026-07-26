
# EnclosureDimensions


## Properties

Name | Type
------------ | -------------
`length` | number
`width` | number
`height` | number
`unit` | string

## Example

```typescript
import type { EnclosureDimensions } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "length": null,
  "width": null,
  "height": null,
  "unit": null,
} satisfies EnclosureDimensions

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as EnclosureDimensions
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



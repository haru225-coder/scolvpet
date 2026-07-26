
# EnclosureUpdateRequest


## Properties

Name | Type
------------ | -------------
`code` | string
`rackCode` | string
`levelCode` | string
`dimensions` | [EnclosureDimensions](EnclosureDimensions.md)
`capacity` | number
`equipment` | Array&lt;string&gt;

## Example

```typescript
import type { EnclosureUpdateRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "code": null,
  "rackCode": null,
  "levelCode": null,
  "dimensions": null,
  "capacity": null,
  "equipment": null,
} satisfies EnclosureUpdateRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as EnclosureUpdateRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



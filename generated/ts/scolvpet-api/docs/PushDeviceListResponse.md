
# PushDeviceListResponse


## Properties

Name | Type
------------ | -------------
`data` | [Array&lt;PushDevice&gt;](PushDevice.md)
`meta` | [ResponseMeta](ResponseMeta.md)

## Example

```typescript
import type { PushDeviceListResponse } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "data": null,
  "meta": null,
} satisfies PushDeviceListResponse

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as PushDeviceListResponse
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



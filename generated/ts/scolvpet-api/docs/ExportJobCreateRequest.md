
# ExportJobCreateRequest


## Properties

Name | Type
------------ | -------------
`datasets` | Set&lt;string&gt;
`format` | string
`timezone` | string
`filters` | { [key: string]: any; }

## Example

```typescript
import type { ExportJobCreateRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "datasets": null,
  "format": null,
  "timezone": null,
  "filters": null,
} satisfies ExportJobCreateRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as ExportJobCreateRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



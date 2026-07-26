
# UsageSnapshot


## Properties

Name | Type
------------ | -------------
`id` | string
`periodStart` | Date
`periodEnd` | Date
`metrics` | [Array&lt;UsageMetric&gt;](UsageMetric.md)
`createdAt` | Date

## Example

```typescript
import type { UsageSnapshot } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "periodStart": null,
  "periodEnd": null,
  "metrics": null,
  "createdAt": null,
} satisfies UsageSnapshot

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as UsageSnapshot
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



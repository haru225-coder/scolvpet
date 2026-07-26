
# KinshipCheck


## Properties

Name | Type
------------ | -------------
`checkedAt` | Date
`commonAncestorCount` | number
`riskLevel` | string
`coefficient` | number
`ruleVersion` | string
`warnings` | Array&lt;string&gt;

## Example

```typescript
import type { KinshipCheck } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "checkedAt": null,
  "commonAncestorCount": null,
  "riskLevel": null,
  "coefficient": null,
  "ruleVersion": null,
  "warnings": null,
} satisfies KinshipCheck

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as KinshipCheck
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



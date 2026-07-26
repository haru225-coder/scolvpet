
# CompleteBreedingPlanRequest


## Properties

Name | Type
------------ | -------------
`completedAt` | Date
`timezone` | string
`notes` | string

## Example

```typescript
import type { CompleteBreedingPlanRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "completedAt": null,
  "timezone": null,
  "notes": null,
} satisfies CompleteBreedingPlanRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as CompleteBreedingPlanRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)




# StartGestationResponseData


## Properties

Name | Type
------------ | -------------
`breedingPlan` | [BreedingPlan](BreedingPlan.md)
`createdReminders` | [Array&lt;Reminder&gt;](Reminder.md)

## Example

```typescript
import type { StartGestationResponseData } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "breedingPlan": null,
  "createdReminders": null,
} satisfies StartGestationResponseData

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as StartGestationResponseData
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



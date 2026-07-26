
# CareTaskUpdateRequest


## Properties

Name | Type
------------ | -------------
`title` | string
`scheduledAt` | Date
`priority` | [TaskPriority](TaskPriority.md)
`notes` | string

## Example

```typescript
import type { CareTaskUpdateRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "title": null,
  "scheduledAt": null,
  "priority": null,
  "notes": null,
} satisfies CareTaskUpdateRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as CareTaskUpdateRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)




# CareTaskCreateRequest


## Properties

Name | Type
------------ | -------------
`taskType` | string
`targetType` | string
`targetId` | string
`title` | string
`scheduledAt` | Date
`priority` | [TaskPriority](TaskPriority.md)
`subjectIds` | Array&lt;string&gt;
`notes` | string

## Example

```typescript
import type { CareTaskCreateRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "taskType": null,
  "targetType": null,
  "targetId": null,
  "title": null,
  "scheduledAt": null,
  "priority": null,
  "subjectIds": null,
  "notes": null,
} satisfies CareTaskCreateRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as CareTaskCreateRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



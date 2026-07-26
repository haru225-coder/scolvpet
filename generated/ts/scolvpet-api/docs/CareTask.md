
# CareTask


## Properties

Name | Type
------------ | -------------
`id` | string
`taskType` | string
`targetType` | string
`targetId` | string
`title` | string
`scheduledAt` | Date
`priority` | [TaskPriority](TaskPriority.md)
`state` | [TaskState](TaskState.md)
`subjectIds` | Array&lt;string&gt;
`completedSubjectIds` | Array&lt;string&gt;
`stageTotal` | number
`stageDone` | number
`sourceEventId` | string
`notes` | string
`version` | number

## Example

```typescript
import type { CareTask } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "taskType": null,
  "targetType": null,
  "targetId": null,
  "title": null,
  "scheduledAt": null,
  "priority": null,
  "state": null,
  "subjectIds": null,
  "completedSubjectIds": null,
  "stageTotal": null,
  "stageDone": null,
  "sourceEventId": null,
  "notes": null,
  "version": null,
} satisfies CareTask

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as CareTask
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)




# AssistantMessage


## Properties

Name | Type
------------ | -------------
`id` | string
`ownerId` | string
`sessionId` | string
`role` | string
`content` | string
`mode` | string
`factsJson` | Array&lt;any&gt;
`createdAt` | Date

## Example

```typescript
import type { AssistantMessage } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "ownerId": null,
  "sessionId": null,
  "role": null,
  "content": null,
  "mode": null,
  "factsJson": null,
  "createdAt": null,
} satisfies AssistantMessage

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as AssistantMessage
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



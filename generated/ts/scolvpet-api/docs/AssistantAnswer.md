
# AssistantAnswer


## Properties

Name | Type
------------ | -------------
`answer` | string
`intent` | string
`mode` | string
`facts` | [Array&lt;AssistantFact&gt;](AssistantFact.md)
`disclaimer` | string

## Example

```typescript
import type { AssistantAnswer } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "answer": null,
  "intent": null,
  "mode": null,
  "facts": null,
  "disclaimer": null,
} satisfies AssistantAnswer

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as AssistantAnswer
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



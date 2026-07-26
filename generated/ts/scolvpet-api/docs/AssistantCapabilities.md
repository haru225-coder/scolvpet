
# AssistantCapabilities


## Properties

Name | Type
------------ | -------------
`intents` | Array&lt;string&gt;
`modeDefault` | string
`llmAvailable` | boolean
`disclaimer` | string

## Example

```typescript
import type { AssistantCapabilities } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "intents": null,
  "modeDefault": null,
  "llmAvailable": null,
  "disclaimer": null,
} satisfies AssistantCapabilities

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as AssistantCapabilities
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)




# AssistantActionConfirmResult


## Properties

Name | Type
------------ | -------------
`actionId` | string
`type` | string
`status` | string
`result` | { [key: string]: any; }

## Example

```typescript
import type { AssistantActionConfirmResult } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "actionId": null,
  "type": null,
  "status": null,
  "result": null,
} satisfies AssistantActionConfirmResult

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as AssistantActionConfirmResult
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)




# ErrorObject


## Properties

Name | Type
------------ | -------------
`code` | string
`message` | string
`fieldErrors` | [Array&lt;FieldError&gt;](FieldError.md)
`currentVersion` | number
`recoveryActions` | [Array&lt;RecoveryAction&gt;](RecoveryAction.md)
`details` | { [key: string]: any; }

## Example

```typescript
import type { ErrorObject } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "code": null,
  "message": null,
  "fieldErrors": null,
  "currentVersion": null,
  "recoveryActions": null,
  "details": null,
} satisfies ErrorObject

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as ErrorObject
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



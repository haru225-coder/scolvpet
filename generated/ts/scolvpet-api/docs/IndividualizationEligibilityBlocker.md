
# IndividualizationEligibilityBlocker


## Properties

Name | Type
------------ | -------------
`code` | string
`message` | string
`pupIdentityIds` | Set&lt;string&gt;
`recoveryActions` | [Array&lt;RecoveryAction&gt;](RecoveryAction.md)

## Example

```typescript
import type { IndividualizationEligibilityBlocker } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "code": null,
  "message": null,
  "pupIdentityIds": null,
  "recoveryActions": null,
} satisfies IndividualizationEligibilityBlocker

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as IndividualizationEligibilityBlocker
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



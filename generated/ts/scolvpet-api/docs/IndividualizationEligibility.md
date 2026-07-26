
# IndividualizationEligibility


## Properties

Name | Type
------------ | -------------
`litterId` | string
`litterVersion` | number
`eligibleSetToken` | string
`eligiblePupIdentityIds` | Set&lt;string&gt;
`eligibleCount` | number
`blockers` | [Array&lt;IndividualizationEligibilityBlocker&gt;](IndividualizationEligibilityBlocker.md)
`canIndividualize` | boolean
`computedAt` | Date

## Example

```typescript
import type { IndividualizationEligibility } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "litterId": null,
  "litterVersion": null,
  "eligibleSetToken": null,
  "eligiblePupIdentityIds": null,
  "eligibleCount": null,
  "blockers": null,
  "canIndividualize": null,
  "computedAt": null,
} satisfies IndividualizationEligibility

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as IndividualizationEligibility
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



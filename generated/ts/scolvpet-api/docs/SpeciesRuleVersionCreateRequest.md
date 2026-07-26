
# SpeciesRuleVersionCreateRequest


## Properties

Name | Type
------------ | -------------
`sourceTemplateId` | string
`speciesCode` | string
`varietyScope` | Array&lt;string&gt;
`gestationMinDays` | number
`gestationMaxDays` | number
`pairingMaxMinutes` | number
`weaningTargetDays` | number
`sexingTargetDays` | number
`separationTargetDays` | number
`postBreedingRestDays` | number
`profileCreationDeadlineDays` | number
`weightReference` | { [key: string]: any; }
`sourceNote` | string
`effectiveAt` | Date

## Example

```typescript
import type { SpeciesRuleVersionCreateRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "sourceTemplateId": null,
  "speciesCode": null,
  "varietyScope": null,
  "gestationMinDays": null,
  "gestationMaxDays": null,
  "pairingMaxMinutes": null,
  "weaningTargetDays": null,
  "sexingTargetDays": null,
  "separationTargetDays": null,
  "postBreedingRestDays": null,
  "profileCreationDeadlineDays": null,
  "weightReference": null,
  "sourceNote": null,
  "effectiveAt": null,
} satisfies SpeciesRuleVersionCreateRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as SpeciesRuleVersionCreateRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



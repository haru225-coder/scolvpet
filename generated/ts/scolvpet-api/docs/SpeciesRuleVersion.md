
# SpeciesRuleVersion


## Properties

Name | Type
------------ | -------------
`id` | string
`ownerId` | string
`scope` | string
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
`version` | number
`effectiveAt` | Date
`frozen` | boolean

## Example

```typescript
import type { SpeciesRuleVersion } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "ownerId": null,
  "scope": null,
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
  "version": null,
  "effectiveAt": null,
  "frozen": null,
} satisfies SpeciesRuleVersion

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as SpeciesRuleVersion
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



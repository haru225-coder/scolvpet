
# PupIdentity


## Properties

Name | Type
------------ | -------------
`id` | string
`litterId` | string
`temporaryCode` | string
`sex` | [Sex](Sex.md)
`sexConfidence` | number
`phenotypeSummary` | { [key: string]: any; }
`destination` | string
`currentEnclosureId` | string
`hamsterId` | string
`outcomeStatus` | [PupOutcomeStatus](PupOutcomeStatus.md)
`profileStatus` | [PupProfileStatus](PupProfileStatus.md)
`version` | number

## Example

```typescript
import type { PupIdentity } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "litterId": null,
  "temporaryCode": null,
  "sex": null,
  "sexConfidence": null,
  "phenotypeSummary": null,
  "destination": null,
  "currentEnclosureId": null,
  "hamsterId": null,
  "outcomeStatus": null,
  "profileStatus": null,
  "version": null,
} satisfies PupIdentity

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as PupIdentity
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



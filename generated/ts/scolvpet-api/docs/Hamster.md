
# Hamster


## Properties

Name | Type
------------ | -------------
`id` | string
`ownerId` | string
`internalCode` | string
`name` | string
`speciesRuleVersionId` | string
`varietyCode` | string
`sex` | [Sex](Sex.md)
`sexConfidence` | number
`birthDate` | Date
`litterId` | string
`sourceType` | [HamsterSourceType](HamsterSourceType.md)
`lifecycleStatus` | [HamsterLifecycleStatus](HamsterLifecycleStatus.md)
`breedingStatus` | [HamsterBreedingStatus](HamsterBreedingStatus.md)
`currentEnclosureId` | string
`coverMediaId` | string
`notes` | string
`version` | number
`createdAt` | Date
`updatedAt` | Date

## Example

```typescript
import type { Hamster } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "ownerId": null,
  "internalCode": null,
  "name": null,
  "speciesRuleVersionId": null,
  "varietyCode": null,
  "sex": null,
  "sexConfidence": null,
  "birthDate": null,
  "litterId": null,
  "sourceType": null,
  "lifecycleStatus": null,
  "breedingStatus": null,
  "currentEnclosureId": null,
  "coverMediaId": null,
  "notes": null,
  "version": null,
  "createdAt": null,
  "updatedAt": null,
} satisfies Hamster

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as Hamster
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



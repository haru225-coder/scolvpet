
# Enclosure


## Properties

Name | Type
------------ | -------------
`id` | string
`ownerId` | string
`code` | string
`rackCode` | string
`levelCode` | string
`dimensions` | [EnclosureDimensions](EnclosureDimensions.md)
`state` | [EnclosureState](EnclosureState.md)
`cleanlinessState` | [CleanlinessState](CleanlinessState.md)
`capacity` | number
`equipment` | Array&lt;string&gt;
`lastCleanedAt` | Date
`currentStays` | [Array&lt;EnclosureStay&gt;](EnclosureStay.md)
`version` | number
`createdAt` | Date
`updatedAt` | Date

## Example

```typescript
import type { Enclosure } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "ownerId": null,
  "code": null,
  "rackCode": null,
  "levelCode": null,
  "dimensions": null,
  "state": null,
  "cleanlinessState": null,
  "capacity": null,
  "equipment": null,
  "lastCleanedAt": null,
  "currentStays": null,
  "version": null,
  "createdAt": null,
  "updatedAt": null,
} satisfies Enclosure

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as Enclosure
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



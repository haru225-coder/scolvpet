
# WeanLitterRequestItemsInner


## Properties

Name | Type
------------ | -------------
`pupIdentityId` | string
`outcomeStatus` | [PupOutcomeStatus](PupOutcomeStatus.md)
`destinationEnclosureId` | string
`notes` | string

## Example

```typescript
import type { WeanLitterRequestItemsInner } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "pupIdentityId": null,
  "outcomeStatus": null,
  "destinationEnclosureId": null,
  "notes": null,
} satisfies WeanLitterRequestItemsInner

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as WeanLitterRequestItemsInner
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



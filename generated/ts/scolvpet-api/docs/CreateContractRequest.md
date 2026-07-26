
# CreateContractRequest


## Properties

Name | Type
------------ | -------------
`templateId` | string
`contactId` | string
`handoverId` | string
`reservationId` | string
`title` | string
`notes` | string
`contactName` | string
`hamsterName` | string

## Example

```typescript
import type { CreateContractRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "templateId": null,
  "contactId": null,
  "handoverId": null,
  "reservationId": null,
  "title": null,
  "notes": null,
  "contactName": null,
  "hamsterName": null,
} satisfies CreateContractRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as CreateContractRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



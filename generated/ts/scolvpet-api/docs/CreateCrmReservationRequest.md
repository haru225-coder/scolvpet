
# CreateCrmReservationRequest


## Properties

Name | Type
------------ | -------------
`contactId` | string
`hamsterId` | string
`title` | string
`notes` | string

## Example

```typescript
import type { CreateCrmReservationRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "contactId": null,
  "hamsterId": null,
  "title": null,
  "notes": null,
} satisfies CreateCrmReservationRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as CreateCrmReservationRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



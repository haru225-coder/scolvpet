
# CustomerReservationDocumentsInner


## Properties

Name | Type
------------ | -------------
`id` | string
`docType` | string
`status` | string
`publicToken` | string
`webPath` | string

## Example

```typescript
import type { CustomerReservationDocumentsInner } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "docType": null,
  "status": null,
  "publicToken": null,
  "webPath": null,
} satisfies CustomerReservationDocumentsInner

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as CustomerReservationDocumentsInner
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



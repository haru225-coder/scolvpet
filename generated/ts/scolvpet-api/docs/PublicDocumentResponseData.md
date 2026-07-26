
# PublicDocumentResponseData


## Properties

Name | Type
------------ | -------------
`kind` | string
`kindLabel` | string
`title` | string
`bodyFilled` | string
`contactName` | string
`currency` | string
`amountCents` | number
`amountLabel` | string
`issuedAt` | Date
`status` | string

## Example

```typescript
import type { PublicDocumentResponseData } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "kind": null,
  "kindLabel": null,
  "title": null,
  "bodyFilled": null,
  "contactName": null,
  "currency": null,
  "amountCents": null,
  "amountLabel": null,
  "issuedAt": null,
  "status": null,
} satisfies PublicDocumentResponseData

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as PublicDocumentResponseData
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)




# PublicShareResponseData


## Properties

Name | Type
------------ | -------------
`shareId` | string
`subjectType` | string
`display` | { [key: string]: any; }
`media` | [Array&lt;MediaVariant&gt;](MediaVariant.md)
`expiresAt` | Date

## Example

```typescript
import type { PublicShareResponseData } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "shareId": null,
  "subjectType": null,
  "display": null,
  "media": null,
  "expiresAt": null,
} satisfies PublicShareResponseData

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as PublicShareResponseData
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



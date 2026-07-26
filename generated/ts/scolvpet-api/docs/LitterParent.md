
# LitterParent


## Properties

Name | Type
------------ | -------------
`id` | string
`litterId` | string
`hamsterId` | string
`role` | string
`evidenceType` | string
`confidence` | number
`version` | number
`createdAt` | Date

## Example

```typescript
import type { LitterParent } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "litterId": null,
  "hamsterId": null,
  "role": null,
  "evidenceType": null,
  "confidence": null,
  "version": null,
  "createdAt": null,
} satisfies LitterParent

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as LitterParent
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



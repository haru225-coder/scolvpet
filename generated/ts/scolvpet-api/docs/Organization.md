
# Organization


## Properties

Name | Type
------------ | -------------
`id` | string
`ownerId` | string
`name` | string
`mode` | string
`timezone` | string
`weightUnit` | string
`version` | number
`createdAt` | Date
`updatedAt` | Date

## Example

```typescript
import type { Organization } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "ownerId": null,
  "name": null,
  "mode": null,
  "timezone": null,
  "weightUnit": null,
  "version": null,
  "createdAt": null,
  "updatedAt": null,
} satisfies Organization

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as Organization
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



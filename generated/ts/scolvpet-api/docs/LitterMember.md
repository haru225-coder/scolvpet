
# LitterMember


## Properties

Name | Type
------------ | -------------
`id` | string
`litterId` | string
`memberType` | string
`pupIdentityId` | string
`hamsterId` | string
`role` | string
`joinedAt` | Date
`leftAt` | Date
`version` | number

## Example

```typescript
import type { LitterMember } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "litterId": null,
  "memberType": null,
  "pupIdentityId": null,
  "hamsterId": null,
  "role": null,
  "joinedAt": null,
  "leftAt": null,
  "version": null,
} satisfies LitterMember

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as LitterMember
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



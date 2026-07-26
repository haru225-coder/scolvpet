
# OrganizationMember


## Properties

Name | Type
------------ | -------------
`id` | string
`organizationId` | string
`accountId` | string
`phone` | string
`displayName` | string
`role` | string
`status` | string
`invitedAt` | Date
`acceptedAt` | Date
`revokedAt` | Date
`version` | number

## Example

```typescript
import type { OrganizationMember } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "organizationId": null,
  "accountId": null,
  "phone": null,
  "displayName": null,
  "role": null,
  "status": null,
  "invitedAt": null,
  "acceptedAt": null,
  "revokedAt": null,
  "version": null,
} satisfies OrganizationMember

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as OrganizationMember
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



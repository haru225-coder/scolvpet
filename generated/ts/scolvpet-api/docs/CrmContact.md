
# CrmContact


## Properties

Name | Type
------------ | -------------
`id` | string
`name` | string
`phone` | string
`wechat` | string
`notes` | string
`status` | string
`version` | number

## Example

```typescript
import type { CrmContact } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "name": null,
  "phone": null,
  "wechat": null,
  "notes": null,
  "status": null,
  "version": null,
} satisfies CrmContact

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as CrmContact
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



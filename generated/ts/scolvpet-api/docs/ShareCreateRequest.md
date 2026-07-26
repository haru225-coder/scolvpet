
# ShareCreateRequest


## Properties

Name | Type
------------ | -------------
`subjectType` | string
`subjectId` | string
`fields` | [Set&lt;SharePublicField&gt;](SharePublicField.md)
`mediaIds` | Set&lt;string&gt;
`expiresAt` | Date

## Example

```typescript
import type { ShareCreateRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "subjectType": null,
  "subjectId": null,
  "fields": null,
  "mediaIds": null,
  "expiresAt": null,
} satisfies ShareCreateRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as ShareCreateRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



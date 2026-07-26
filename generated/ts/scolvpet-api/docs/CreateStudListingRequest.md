
# CreateStudListingRequest


## Properties

Name | Type
------------ | -------------
`sireLabel` | string
`title` | string
`feeCents` | number
`currency` | string
`notes` | string
`published` | boolean

## Example

```typescript
import type { CreateStudListingRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "sireLabel": null,
  "title": null,
  "feeCents": null,
  "currency": null,
  "notes": null,
  "published": null,
} satisfies CreateStudListingRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as CreateStudListingRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



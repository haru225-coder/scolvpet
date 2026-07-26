
# PostPublicSiteSimulateRequest


## Properties

Name | Type
------------ | -------------
`sireHamsterId` | string
`damHamsterId` | string
`series` | string
`sirePhenotype` | string
`damPhenotype` | string

## Example

```typescript
import type { PostPublicSiteSimulateRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "sireHamsterId": null,
  "damHamsterId": null,
  "series": null,
  "sirePhenotype": null,
  "damPhenotype": null,
} satisfies PostPublicSiteSimulateRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as PostPublicSiteSimulateRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



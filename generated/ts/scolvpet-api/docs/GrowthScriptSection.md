
# GrowthScriptSection


## Properties

Name | Type
------------ | -------------
`order` | number
`durationSeconds` | number
`shot` | string
`voiceover` | string
`overlay` | string

## Example

```typescript
import type { GrowthScriptSection } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "order": null,
  "durationSeconds": null,
  "shot": null,
  "voiceover": null,
  "overlay": null,
} satisfies GrowthScriptSection

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as GrowthScriptSection
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



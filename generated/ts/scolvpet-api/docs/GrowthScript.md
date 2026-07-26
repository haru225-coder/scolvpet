
# GrowthScript


## Properties

Name | Type
------------ | -------------
`title` | string
`hook` | string
`coverText` | string
`sections` | [Array&lt;GrowthScriptSection&gt;](GrowthScriptSection.md)
`caption` | string
`hashtags` | Array&lt;string&gt;
`cta` | string
`facts` | [Array&lt;GrowthPublicFact&gt;](GrowthPublicFact.md)

## Example

```typescript
import type { GrowthScript } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "title": null,
  "hook": null,
  "coverText": null,
  "sections": null,
  "caption": null,
  "hashtags": null,
  "cta": null,
  "facts": null,
} satisfies GrowthScript

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as GrowthScript
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



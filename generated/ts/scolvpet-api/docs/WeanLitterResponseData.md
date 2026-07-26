
# WeanLitterResponseData


## Properties

Name | Type
------------ | -------------
`litterId` | string
`litterState` | [LitterState](LitterState.md)
`weanedAt` | Date
`processedCount` | number
`itemResults` | [Array&lt;ActionItemResult&gt;](ActionItemResult.md)
`createdTaskIds` | Array&lt;string&gt;
`version` | number

## Example

```typescript
import type { WeanLitterResponseData } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "litterId": null,
  "litterState": null,
  "weanedAt": null,
  "processedCount": null,
  "itemResults": null,
  "createdTaskIds": null,
  "version": null,
} satisfies WeanLitterResponseData

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as WeanLitterResponseData
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



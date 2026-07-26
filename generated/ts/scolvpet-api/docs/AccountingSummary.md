
# AccountingSummary


## Properties

Name | Type
------------ | -------------
`from` | Date
`to` | Date
`incomeCents` | number
`expenseCents` | number
`netCents` | number
`currency` | string
`recordCount` | number
`byCategory` | [Array&lt;AccountingCategorySummary&gt;](AccountingCategorySummary.md)

## Example

```typescript
import type { AccountingSummary } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "from": null,
  "to": null,
  "incomeCents": null,
  "expenseCents": null,
  "netCents": null,
  "currency": null,
  "recordCount": null,
  "byCategory": null,
} satisfies AccountingSummary

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as AccountingSummary
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



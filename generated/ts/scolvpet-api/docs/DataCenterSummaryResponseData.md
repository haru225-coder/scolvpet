
# DataCenterSummaryResponseData


## Properties

Name | Type
------------ | -------------
`recentImports` | [Array&lt;ImportJob&gt;](ImportJob.md)
`recentExports` | [Array&lt;ExportJob&gt;](ExportJob.md)
`recentBackups` | [Array&lt;BackupJob&gt;](BackupJob.md)
`usage` | [Array&lt;UsageMetric&gt;](UsageMetric.md)
`usageStatus` | string

## Example

```typescript
import type { DataCenterSummaryResponseData } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "recentImports": null,
  "recentExports": null,
  "recentBackups": null,
  "usage": null,
  "usageStatus": null,
} satisfies DataCenterSummaryResponseData

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as DataCenterSummaryResponseData
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



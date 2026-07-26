
# HealthRecord


## Properties

Name | Type
------------ | -------------
`id` | string
`hamsterId` | string
`litterId` | string
`type` | [HealthRecordType](HealthRecordType.md)
`observedAt` | Date
`structuredChecks` | { [key: string]: any; }
`severity` | [Severity](Severity.md)
`medication` | { [key: string]: any; }
`mediaIds` | Array&lt;string&gt;
`followUpAt` | Date
`notes` | string
`version` | number
`createdAt` | Date
`updatedAt` | Date

## Example

```typescript
import type { HealthRecord } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "hamsterId": null,
  "litterId": null,
  "type": null,
  "observedAt": null,
  "structuredChecks": null,
  "severity": null,
  "medication": null,
  "mediaIds": null,
  "followUpAt": null,
  "notes": null,
  "version": null,
  "createdAt": null,
  "updatedAt": null,
} satisfies HealthRecord

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as HealthRecord
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



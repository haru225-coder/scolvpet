
# HealthRecordCreateRequest


## Properties

Name | Type
------------ | -------------
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

## Example

```typescript
import type { HealthRecordCreateRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
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
} satisfies HealthRecordCreateRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as HealthRecordCreateRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



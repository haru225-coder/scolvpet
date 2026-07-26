
# ImportJob


## Properties

Name | Type
------------ | -------------
`id` | string
`jobType` | string
`status` | [JobStatus](JobStatus.md)
`progressPercent` | number
`currentStep` | string
`error` | [ErrorObject](ErrorObject.md)
`retryable` | boolean
`attempt` | number
`result` | { [key: string]: any; }
`expiresAt` | Date
`version` | number
`createdAt` | Date
`updatedAt` | Date
`templateType` | [ImportTemplateType](ImportTemplateType.md)
`phase` | string
`sourceEncoding` | string
`sourceColumns` | Array&lt;string&gt;
`mapping` | { [key: string]: string; }
`preflightVersion` | number
`totalRows` | number
`validRows` | number
`warningRows` | number
`invalidRows` | number
`importedRows` | number
`historicalLittersToCreate` | number
`relationshipAssertionsToCreate` | number
`blockingIssueCount` | number

## Example

```typescript
import type { ImportJob } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "jobType": null,
  "status": null,
  "progressPercent": null,
  "currentStep": null,
  "error": null,
  "retryable": null,
  "attempt": null,
  "result": null,
  "expiresAt": null,
  "version": null,
  "createdAt": null,
  "updatedAt": null,
  "templateType": null,
  "phase": null,
  "sourceEncoding": null,
  "sourceColumns": null,
  "mapping": null,
  "preflightVersion": null,
  "totalRows": null,
  "validRows": null,
  "warningRows": null,
  "invalidRows": null,
  "importedRows": null,
  "historicalLittersToCreate": null,
  "relationshipAssertionsToCreate": null,
  "blockingIssueCount": null,
} satisfies ImportJob

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as ImportJob
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



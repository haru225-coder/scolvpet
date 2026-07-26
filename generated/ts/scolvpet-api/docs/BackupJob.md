
# BackupJob


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
`includesStructuredData` | boolean
`includesMediaManifest` | boolean
`includesChecksums` | boolean
`sizeBytes` | number
`sha256` | string
`integrityStatus` | string
`restoreReadiness` | string
`verifiedAt` | Date

## Example

```typescript
import type { BackupJob } from '@scolvpet/scolvpet-api'

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
  "includesStructuredData": null,
  "includesMediaManifest": null,
  "includesChecksums": null,
  "sizeBytes": null,
  "sha256": null,
  "integrityStatus": null,
  "restoreReadiness": null,
  "verifiedAt": null,
} satisfies BackupJob

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as BackupJob
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



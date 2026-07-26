
# PublicGrowthReservationRequest

手机号和微信至少填写一个；品种/毛色由 Backend 关联 hamster 继承。

## Properties

Name | Type
------------ | -------------
`hamsterId` | string
`name` | string
`phone` | string
`wechat` | string
`notes` | string

## Example

```typescript
import type { PublicGrowthReservationRequest } from '@scolvpet/scolvpet-api'

// TODO: Update the object below with actual values
const example = {
  "hamsterId": null,
  "name": null,
  "phone": null,
  "wechat": null,
  "notes": null,
} satisfies PublicGrowthReservationRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as PublicGrowthReservationRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)



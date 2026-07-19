# scolvpet_api.api.GeneticApi

## Load the API package
```dart
import 'package:scolvpet_api/api.dart';
```

All URIs are relative to *https://api.scolvpet.cn/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**compareGeneticActual**](GeneticApi.md#comparegeneticactual) | **POST** /v1/genetic/compare-actual | Compare actual litter phenotype counts to core table expectation
[**listGeneticFeedbackSummary**](GeneticApi.md#listgeneticfeedbacksummary) | **GET** /v1/genetic/feedback-summary | Summarize historical phenotype prediction feedback
[**listGeneticPhenotypeCatalog**](GeneticApi.md#listgeneticphenotypecatalog) | **GET** /v1/genetic/phenotype-catalog | List phenotype series catalog from authority table
[**listGeneticTargetCrosses**](GeneticApi.md#listgenetictargetcrosses) | **GET** /v1/genetic/target-crosses | Rank parent pairs that can produce a target phenotype


# **compareGeneticActual**
> Map<String, Object> compareGeneticActual(requestBody)

Compare actual litter phenotype counts to core table expectation

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getGeneticApi();
final Map<String, Object> requestBody = Object; // Map<String, Object> |

try {
    final response = api.compareGeneticActual(requestBody);
    print(response);
} on DioException catch (e) {
    print('Exception when calling GeneticApi->compareGeneticActual: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **requestBody** | [**Map&lt;String, Object&gt;**](Object.md)|  |

### Return type

**Map&lt;String, Object&gt;**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listGeneticFeedbackSummary**
> Map<String, Object> listGeneticFeedbackSummary()

Summarize historical phenotype prediction feedback

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getGeneticApi();

try {
    final response = api.listGeneticFeedbackSummary();
    print(response);
} on DioException catch (e) {
    print('Exception when calling GeneticApi->listGeneticFeedbackSummary: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

**Map&lt;String, Object&gt;**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listGeneticPhenotypeCatalog**
> Map<String, Object> listGeneticPhenotypeCatalog()

List phenotype series catalog from authority table

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getGeneticApi();

try {
    final response = api.listGeneticPhenotypeCatalog();
    print(response);
} on DioException catch (e) {
    print('Exception when calling GeneticApi->listGeneticPhenotypeCatalog: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

**Map&lt;String, Object&gt;**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listGeneticTargetCrosses**
> Map<String, Object> listGeneticTargetCrosses(series, phenotype)

Rank parent pairs that can produce a target phenotype

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getGeneticApi();
final String series = series_example; // String |
final String phenotype = phenotype_example; // String |

try {
    final response = api.listGeneticTargetCrosses(series, phenotype);
    print(response);
} on DioException catch (e) {
    print('Exception when calling GeneticApi->listGeneticTargetCrosses: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **series** | **String**|  |
 **phenotype** | **String**|  |

### Return type

**Map&lt;String, Object&gt;**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

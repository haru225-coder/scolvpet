//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

// ignore: unused_import
import 'dart:convert';
import 'package:scolvpet_api/src/deserialize.dart';
import 'package:dio/dio.dart';

import 'package:scolvpet_api/src/model/error_response.dart';
import 'package:scolvpet_api/src/model/public_document_response.dart';

class PublicDocumentsApi {

  final Dio _dio;

  const PublicDocumentsApi(this._dio);

  /// 客户只读查看已签发合同/回执
  /// 能力令牌访问；仅 status&#x3D;issued 的单据可见。 不暴露 owner_id、内部 ID 与未签发草稿。
  ///
  /// Parameters:
  /// * [token]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [PublicDocumentResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<PublicDocumentResponse>> getPublicDocument({
    required String token,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/public/documents/{token}'.replaceAll('{' r'token' '}', token.toString());
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    PublicDocumentResponse? _responseData;

    try {
final rawData = _response.data;
_responseData = rawData == null ? null : deserialize<PublicDocumentResponse, PublicDocumentResponse>(rawData, 'PublicDocumentResponse', growable: true);

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<PublicDocumentResponse>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

}

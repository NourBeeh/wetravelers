import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'api_client.dart';
import 'api_error.dart';
import 'api_result.dart';

class HttpApiClient implements ApiClient {
  /// Compile-time override (e.g. `--dart-define=API_BASE_URL=http://x:3000`).
  static const String _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

  @override
  String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl;
    }
    // Android emulators reach the host machine via 10.0.2.2; desktop/Linux
    // (and iOS simulators) use localhost. Kept overridable via API_BASE_URL.
    return Platform.isAndroid
        ? 'http://10.0.2.2:3000'
        : 'http://localhost:3000';
  }

  @override
  Duration get defaultTimeout => const Duration(seconds: 30);

  @override
  Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  final HttpClient _client = HttpClient();

  @override
  Future<ApiResult<T>> get<T>(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    return _request<T>('GET', path, queryParameters: queryParameters, headers: headers, timeout: timeout);
  }

  @override
  Future<ApiResult<T>> post<T>(
    String path, {
    Object? body,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    return _request<T>('POST', path, body: body, headers: headers, timeout: timeout);
  }

  @override
  Future<ApiResult<T>> put<T>(
    String path, {
    Object? body,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    return _request<T>('PUT', path, body: body, headers: headers, timeout: timeout);
  }

  @override
  Future<ApiResult<T>> patch<T>(
    String path, {
    Object? body,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    return _request<T>('PATCH', path, body: body, headers: headers, timeout: timeout);
  }

  @override
  Future<ApiResult<T>> delete<T>(
    String path, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    return _request<T>('DELETE', path, headers: headers, timeout: timeout);
  }

  @override
  ApiResult<T> mapError<T>(Object error, {StackTrace? stackTrace}) {
    return ApiResult.failure(ApiNetworkError(message: error.toString(), cause: error));
  }

  Future<ApiResult<T>> _request<T>(
    String method,
    String path, {
    Map<String, String>? queryParameters,
    Object? body,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    try {
      final uri = Uri.parse(baseUrl).resolve(path);
      final finalUri = queryParameters != null
          ? uri.replace(queryParameters: {...uri.queryParameters, ...queryParameters})
          : uri;

      final request = await _client.openUrl(method, finalUri);
      final mergedHeaders = {...defaultHeaders, ...?headers};
      mergedHeaders.forEach((k, v) => request.headers.set(k, v));

      if (body != null) {
        final encoded = jsonEncode(body);
        request.add(utf8.encode(encoded));
      }

      late HttpClientResponse response;
      try {
        response = await request.close().timeout(timeout ?? defaultTimeout);
      } on TimeoutException catch (e) {
        return ApiResult.failure(ApiTimeoutError(message: 'Request timed out', cause: e));
      }

      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        dynamic data;
        try {
          data = jsonDecode(responseBody);
        } catch (_) {
          return ApiResult.failure(ApiParseError(message: 'Invalid JSON response', cause: responseBody));
        }
        return ApiResult.success(data as T);
      } else {
        final code = response.statusCode;
        if (code == 401 || code == 403) {
          return ApiResult.failure(ApiUnauthorizedError(message: responseBody, statusCode: code));
        }
        if (code == 429) {
          return ApiResult.failure(ApiServerError(message: responseBody, statusCode: code));
        }
        if (code >= 500) {
          return ApiResult.failure(ApiServerError(message: responseBody, statusCode: code));
        }
        return ApiResult.failure(ApiClientError(message: responseBody, statusCode: code));
      }
    } catch (e, st) {
      if (e is SocketException || e is HttpException) {
        return ApiResult.failure(ApiNetworkError(message: e.toString(), cause: e));
      }
      return mapError(e, stackTrace: st);
    }
  }
}

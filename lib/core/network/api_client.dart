import 'api_error.dart';
import 'api_result.dart';

/// Common envelope for every server response.
///
/// `data` holds the decoded payload; `meta` can carry pagination, timestamps or
/// other non-domain metadata. This convention keeps a consistent contract for
/// all future endpoints.
class ApiResponse<T> {
  const ApiResponse({required this.data, this.meta});

  final T data;
  final Map<String, dynamic>? meta;
}

/// A generic network client contract.
///
/// Phase 1 defines the abstraction only — no concrete HTTP client or Provider
/// is wired yet. Implementations translate platform errors into [ApiError] and
/// always return an [ApiResult].
abstract interface class ApiClient {
  /// Base URL all relative paths are resolved against.
  String get baseUrl;

  /// Default timeout applied when [timeout] is not supplied.
  Duration get defaultTimeout;

  /// Headers merged into every request (e.g. auth or content-type).
  Map<String, String> get defaultHeaders;

  Future<ApiResult<T>> get<T>(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
  });

  Future<ApiResult<T>> post<T>(
    String path, {
    Object? body,
    Map<String, String>? headers,
    Duration? timeout,
  });

  Future<ApiResult<T>> put<T>(
    String path, {
    Object? body,
    Map<String, String>? headers,
    Duration? timeout,
  });

  Future<ApiResult<T>> patch<T>(
    String path, {
    Object? body,
    Map<String, String>? headers,
    Duration? timeout,
  });

  Future<ApiResult<T>> delete<T>(
    String path, {
    Map<String, String>? headers,
    Duration? timeout,
  });

  /// Translates an arbitrary thrown error into the closest [ApiError].
  ApiResult<T> mapError<T>(Object error, {StackTrace? stackTrace});
}
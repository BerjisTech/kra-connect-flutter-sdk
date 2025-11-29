import 'kra_exception.dart';

/// Exception thrown for general API errors.
///
/// This exception includes the HTTP status code and response body.
///
/// Example:
/// ```dart
/// try {
///   await client.verifyPin(pin);
/// } on ApiException catch (e) {
///   if (e.isClientError) {
///     print('Client error: ${e.message}');
///   } else if (e.isServerError) {
///     print('Server error: ${e.message}');
///   }
/// }
/// ```
final class ApiException extends KraException {
  /// The API endpoint that failed
  final String endpoint;

  /// The response body from the API
  final String? responseBody;

  const ApiException(
    super.message,
    super.statusCode,
    this.endpoint, {
    this.responseBody,
    super.details,
  });

  /// Returns true if this is a client error (4xx)
  bool get isClientError => statusCode != null && statusCode! >= 400 && statusCode! < 500;

  /// Returns true if this is a server error (5xx)
  bool get isServerError => statusCode != null && statusCode! >= 500 && statusCode! < 600;

  @override
  String toString() {
    final buffer = StringBuffer('ApiException ($statusCode): $message');
    if (endpoint.isNotEmpty) {
      buffer.write(' [Endpoint: $endpoint]');
    }
    return buffer.toString();
  }
}

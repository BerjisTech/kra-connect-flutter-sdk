import 'kra_exception.dart';

/// Exception thrown for network-related errors.
///
/// This includes connection failures, DNS resolution errors, etc.
///
/// Example:
/// ```dart
/// try {
///   await client.verifyPin(pin);
/// } on NetworkException catch (e) {
///   print('Network error: ${e.message}');
///   // Show "Check your internet connection" message
/// }
/// ```
final class NetworkException extends KraException {
  /// The endpoint that failed
  final String endpoint;

  /// The underlying error
  final Object? cause;

  const NetworkException(
    super.message,
    this.endpoint, {
    this.cause,
    super.details,
  });

  @override
  String toString() {
    final buffer = StringBuffer('NetworkException: $message');
    if (endpoint.isNotEmpty) {
      buffer.write(' [Endpoint: $endpoint]');
    }
    if (cause != null) {
      buffer.write(' [Cause: $cause]');
    }
    return buffer.toString();
  }
}

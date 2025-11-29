import 'kra_exception.dart';

/// Exception thrown when an API request times out.
///
/// Example:
/// ```dart
/// try {
///   await client.verifyPin(pin);
/// } on TimeoutException catch (e) {
///   print('Request timed out after ${e.timeout.inSeconds}s');
///   // Retry with longer timeout or show error to user
/// }
/// ```
final class TimeoutException extends KraException {
  /// The endpoint that timed out
  final String endpoint;

  /// The timeout duration
  final Duration timeout;

  /// The attempt number when timeout occurred
  final int attemptNumber;

  const TimeoutException(
    super.message,
    this.endpoint,
    this.timeout,
    this.attemptNumber, {
    super.details,
  }) : super(statusCode: 408);

  @override
  String toString() =>
      'TimeoutException: Request to $endpoint timed out after ${timeout.inSeconds}s (attempt $attemptNumber)';
}

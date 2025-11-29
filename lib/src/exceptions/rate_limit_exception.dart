import 'kra_exception.dart';

/// Exception thrown when API rate limit is exceeded.
///
/// Contains information about when to retry the request.
///
/// Example:
/// ```dart
/// try {
///   await client.verifyPin(pin);
/// } on RateLimitException catch (e) {
///   print('Rate limited. Retry after ${e.retryAfter.inSeconds} seconds');
///   await Future.delayed(e.retryAfter);
///   // Retry the request
/// }
/// ```
final class RateLimitException extends KraException {
  /// Duration to wait before retrying
  final Duration retryAfter;

  /// Maximum number of requests allowed
  final int? limit;

  /// Time window for the rate limit
  final Duration? window;

  const RateLimitException(
    super.message,
    this.retryAfter, {
    this.limit,
    this.window,
    super.details,
  }) : super(statusCode: 429);

  @override
  String toString() {
    final parts = ['RateLimitException: $message'];
    if (limit != null && window != null) {
      parts.add('(Limit: $limit requests per ${window!.inSeconds}s)');
    }
    parts.add('Retry after: ${retryAfter.inSeconds}s');
    return parts.join(' ');
  }
}

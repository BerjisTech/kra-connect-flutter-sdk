/// Base exception class for all KRA Connect SDK errors.
///
/// This is a sealed class that all other exceptions extend from.
/// Use pattern matching to handle specific error types.
///
/// Example:
/// ```dart
/// try {
///   await client.verifyPin(pin);
/// } on KraException catch (e) {
///   print('Error: ${e.message}');
/// }
/// ```
sealed class KraException implements Exception {
  /// Human-readable error message
  final String message;

  /// Additional details about the error
  final Map<String, dynamic>? details;

  /// HTTP status code if applicable
  final int? statusCode;

  const KraException(this.message, {this.details, this.statusCode});

  @override
  String toString() {
    if (details != null && details!.isNotEmpty) {
      return 'KraException: $message (Details: $details)';
    }
    return 'KraException: $message';
  }
}

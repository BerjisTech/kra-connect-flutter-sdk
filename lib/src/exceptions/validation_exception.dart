import 'kra_exception.dart';

/// Exception thrown when input validation fails.
///
/// This exception is thrown when the provided input doesn't meet
/// the expected format or constraints.
///
/// Example:
/// ```dart
/// try {
///   await client.verifyPin('INVALID');
/// } on ValidationException catch (e) {
///   print('Invalid ${e.field}: ${e.message}');
/// }
/// ```
final class ValidationException extends KraException {
  /// The field that failed validation
  final String field;

  const ValidationException(
    super.message,
    this.field, {
    super.details,
  });

  @override
  String toString() => 'ValidationException: $message (Field: $field)';
}

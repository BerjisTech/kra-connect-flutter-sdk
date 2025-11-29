import 'kra_exception.dart';

/// Exception thrown when API authentication fails.
///
/// This typically means the API key is invalid, expired, or missing.
///
/// Example:
/// ```dart
/// try {
///   await client.verifyPin(pin);
/// } on AuthenticationException catch (e) {
///   print('Auth failed: ${e.message}');
///   // Redirect to API key configuration
/// }
/// ```
final class AuthenticationException extends KraException {
  const AuthenticationException(
    super.message, {
    super.details,
  }) : super(statusCode: 401);

  @override
  String toString() => 'AuthenticationException: $message';
}

import 'kra_exception.dart';

/// Exception thrown for cache operation errors.
///
/// This is typically non-fatal and the operation can proceed without cache.
///
/// Example:
/// ```dart
/// try {
///   // Cache operations
/// } on CacheException catch (e) {
///   print('Cache error: ${e.message}');
///   // Continue without cache
/// }
/// ```
final class CacheException extends KraException {
  /// The cache operation that failed
  final String operation;

  /// The cache key involved
  final String key;

  const CacheException(
    super.message,
    this.operation,
    this.key, {
    super.details,
  });

  @override
  String toString() => 'CacheException: $operation failed for key "$key" - $message';
}

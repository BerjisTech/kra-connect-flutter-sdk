/// Official Flutter/Dart SDK for Kenya Revenue Authority's GavaConnect API.
///
/// This library provides a comprehensive, type-safe interface for interacting
/// with the KRA GavaConnect API for tax compliance and verification in Kenya.
///
/// ## Features
///
/// - PIN Verification - Verify KRA PIN numbers
/// - TCC Verification - Check Tax Compliance Certificates
/// - e-Slip Validation - Validate electronic payment slips
/// - NIL Returns - File NIL returns programmatically
/// - Taxpayer Details - Retrieve taxpayer information
/// - Batch Operations - Process multiple requests concurrently
/// - Type Safety - Full Dart null safety support
/// - Async/Await - Modern asynchronous API
/// - Retry Logic - Automatic retry with exponential backoff
/// - Caching - Response caching with TTL
/// - Rate Limiting - Built-in rate limiter
/// - Cross-Platform - Works on all Flutter platforms
///
/// ## Quick Start
///
/// ```dart
/// import 'package:kra_connect/kra_connect.dart';
///
/// void main() async {
///   final client = KraClient(apiKey: 'your-api-key');
///
///   try {
///     final result = await client.verifyPin('P051234567A');
///     if (result.isValid) {
///       print('Valid PIN: ${result.taxpayerName}');
///     }
///   } finally {
///     client.dispose();
///   }
/// }
/// ```
///
/// ## Configuration
///
/// ```dart
/// final client = KraClient(
///   apiKey: 'your-api-key',
///   config: KraConfig(
///     timeout: Duration(seconds: 30),
///     maxRetries: 3,
///     enableCache: true,
///     debugMode: false,
///   ),
/// );
/// ```
///
/// ## Error Handling
///
/// ```dart
/// try {
///   final result = await client.verifyPin('P051234567A');
/// } on ValidationException catch (e) {
///   print('Validation error: ${e.message}');
/// } on AuthenticationException catch (e) {
///   print('Auth error: ${e.message}');
/// } on KraException catch (e) {
///   print('KRA error: ${e.message}');
/// }
/// ```
library kra_connect;

// Core client
export 'src/kra_client.dart';

// Configuration
export 'src/config/kra_config.dart';

// Models
export 'src/models/pin_verification_result.dart';
export 'src/models/tcc_verification_result.dart';
export 'src/models/eslip_validation_result.dart';
export 'src/models/nil_return_request.dart';
export 'src/models/nil_return_result.dart';
export 'src/models/taxpayer_details.dart';
export 'src/models/tax_obligation.dart';

// Exceptions
export 'src/exceptions/kra_exception.dart';
export 'src/exceptions/validation_exception.dart';
export 'src/exceptions/authentication_exception.dart';
export 'src/exceptions/rate_limit_exception.dart';
export 'src/exceptions/timeout_exception.dart';
export 'src/exceptions/api_exception.dart';
export 'src/exceptions/network_exception.dart';
export 'src/exceptions/cache_exception.dart';

// Utilities
export 'src/utils/validators.dart';

// Services (for advanced use cases)
export 'src/services/cache_manager.dart';
export 'src/services/http_client.dart';
export 'src/services/rate_limiter.dart';
export 'src/services/retry_handler.dart';

import 'config/kra_config.dart';
import 'models/eslip_validation_result.dart';
import 'models/nil_return_request.dart';
import 'models/nil_return_result.dart';
import 'models/pin_verification_result.dart';
import 'models/taxpayer_details.dart';
import 'models/tcc_verification_result.dart';
import 'services/cache_manager.dart';
import 'services/http_client.dart';
import 'services/rate_limiter.dart';
import 'services/retry_handler.dart';
import 'utils/validators.dart';

/// Main client for interacting with the KRA GavaConnect API.
///
/// Example:
/// ```dart
/// final client = KraClient(
///   config: KraConfig(apiKey: 'your-api-key'),
/// );
///
/// // Verify PIN
/// final pinResult = await client.verifyPin('P051234567A');
/// if (pinResult.isValid) {
///   print('PIN is valid: ${pinResult.taxpayerName}');
/// }
///
/// // Verify TCC
/// final tccResult = await client.verifyTcc('TCC123456');
/// if (tccResult.isValid) {
///   print('TCC expires on: ${tccResult.expiryDate}');
/// }
///
/// // Don't forget to close the client
/// client.close();
/// ```
class KraClient {
  final KraConfig config;
  final HttpClient _httpClient;
  final CacheManager _cache;
  final RateLimiter _rateLimiter;
  final RetryHandler _retryHandler;

  KraClient({
    required this.config,
    CacheManager? cache,
    RateLimiter? rateLimiter,
    RetryHandler? retryHandler,
    HttpClient? httpClient,
  })  : _cache = cache ??
            CacheManager(
              maxSize: config.maxCacheSize,
              defaultTtl: config.cacheTtl,
            ),
        _rateLimiter = rateLimiter ??
            RateLimiter(
              maxRequestsPerSecond: config.maxRequestsPerSecond,
              enabled: config.enableRateLimit,
            ),
        _retryHandler = retryHandler ??
            RetryHandler(
              maxRetries: config.maxRetries,
              initialDelay: config.retryDelay,
              maxDelay: config.maxRetryDelay,
              retryStatusCodes: config.retryStatusCodes,
            ),
        _httpClient = httpClient ??
            HttpClient(
              config: config,
              cache: cache ??
                  CacheManager(
                    maxSize: config.maxCacheSize,
                    defaultTtl: config.cacheTtl,
                  ),
              rateLimiter: rateLimiter ??
                  RateLimiter(
                    maxRequestsPerSecond: config.maxRequestsPerSecond,
                    enabled: config.enableRateLimit,
                  ),
              retryHandler: retryHandler ??
                  RetryHandler(
                    maxRetries: config.maxRetries,
                    initialDelay: config.retryDelay,
                    maxDelay: config.maxRetryDelay,
                    retryStatusCodes: config.retryStatusCodes,
                  ),
            );

  /// Verifies a KRA PIN number.
  ///
  /// Example:
  /// ```dart
  /// final result = await client.verifyPin('P051234567A');
  /// if (result.isValid) {
  ///   print('Valid PIN for: ${result.taxpayerName}');
  /// }
  /// ```
  Future<PinVerificationResult> verifyPin(String pin) async {
    Validators.validatePin(pin);

    final response = await _httpClient.post(
      '/checker/v1/pinbypin',
      body: {'KRAPIN': pin.trim().toUpperCase()},
    );

    return PinVerificationResult.fromJson(response);
  }

  /// Verifies multiple KRA PIN numbers in batch.
  ///
  /// Example:
  /// ```dart
  /// final results = await client.verifyPinBatch([
  ///   'P051234567A',
  ///   'P059876543B',
  /// ]);
  ///
  /// for (final result in results) {
  ///   print('${result.pinNumber}: ${result.isValid}');
  /// }
  /// ```
  Future<List<PinVerificationResult>> verifyPinBatch(
    List<String> pins,
  ) async {
    // Validate all PINs
    for (final pin in pins) {
      Validators.validatePin(pin);
    }

    // Verify each PIN individually using the correct endpoint
    final results = <PinVerificationResult>[];
    for (final pin in pins) {
      try {
        final result = await verifyPin(pin);
        results.add(result);
      } catch (e) {
        results.add(PinVerificationResult(
          pinNumber: pin,
          isValid: false,
          errorMessage: e.toString(),
        ));
      }
    }
    return results;
  }

  /// Verifies a Tax Compliance Certificate (TCC) number.
  ///
  /// Example:
  /// ```dart
  /// final result = await client.verifyTcc('TCC123456', 'P051234567A');
  /// if (result.isValid && !result.isExpired) {
  ///   print('Valid TCC, expires on: ${result.expiryDate}');
  /// }
  /// ```
  Future<TccVerificationResult> verifyTcc(String tcc, String kraPIN) async {
    Validators.validateTcc(tcc);
    Validators.validatePin(kraPIN);

    final response = await _httpClient.post(
      '/v1/kra-tcc/validate',
      body: {
        'kraPIN': kraPIN.trim().toUpperCase(),
        'tccNumber': tcc.trim().toUpperCase(),
      },
    );

    return TccVerificationResult.fromJson(response);
  }

  /// Verifies multiple TCC numbers in batch.
  ///
  /// Note: Each TCC requires an associated PIN for verification.
  ///
  /// Example:
  /// ```dart
  /// final results = await client.verifyTccBatch([
  ///   {'tcc': 'TCC123456', 'pin': 'P051234567A'},
  ///   {'tcc': 'TCC789012', 'pin': 'P059876543B'},
  /// ]);
  ///
  /// for (final result in results) {
  ///   print('${result.tccNumber}: Valid=${result.isValid}');
  /// }
  /// ```
  Future<List<TccVerificationResult>> verifyTccBatch(
    List<Map<String, String>> tccRequests,
  ) async {
    // Validate all TCCs and PINs
    for (final request in tccRequests) {
      Validators.validateTcc(request['tcc']!);
      Validators.validatePin(request['pin']!);
    }

    // Verify each TCC individually using the correct endpoint
    final results = <TccVerificationResult>[];
    for (final request in tccRequests) {
      try {
        final result = await verifyTcc(request['tcc']!, request['pin']!);
        results.add(result);
      } catch (e) {
        results.add(TccVerificationResult(
          tccNumber: request['tcc']!,
          isValid: false,
          errorMessage: e.toString(),
        ));
      }
    }
    return results;
  }

  /// Validates an e-slip number.
  ///
  /// Example:
  /// ```dart
  /// final result = await client.validateEslip('ABC1234567890');
  /// if (result.isValid && result.isPaid) {
  ///   print('E-slip is valid and paid');
  ///   print('Amount: ${result.amount} ${result.currency}');
  /// }
  /// ```
  Future<EslipValidationResult> validateEslip(String eslip) async {
    Validators.validateEslip(eslip);

    final response = await _httpClient.post(
      '/payment/checker/v1/eslip',
      body: {'EslipNumber': eslip.trim().toUpperCase()},
    );

    return EslipValidationResult.fromJson(response);
  }

  /// Validates multiple e-slip numbers in batch.
  ///
  /// Example:
  /// ```dart
  /// final results = await client.validateEslipBatch([
  ///   'ABC1234567890',
  ///   'DEF0987654321',
  /// ]);
  ///
  /// for (final result in results) {
  ///   print('${result.eslipNumber}: ${result.status}');
  /// }
  /// ```
  Future<List<EslipValidationResult>> validateEslipBatch(
    List<String> eslips,
  ) async {
    // Validate all e-slips
    for (final eslip in eslips) {
      Validators.validateEslip(eslip);
    }

    // Validate each e-slip individually using the correct endpoint
    final results = <EslipValidationResult>[];
    for (final eslip in eslips) {
      try {
        final result = await validateEslip(eslip);
        results.add(result);
      } catch (e) {
        results.add(EslipValidationResult(
          eslipNumber: eslip,
          isValid: false,
          errorMessage: e.toString(),
        ));
      }
    }
    return results;
  }

  /// Files a NIL return for a specified tax period.
  ///
  /// Example:
  /// ```dart
  /// final request = NilReturnRequest(
  ///   pinNumber: 'P051234567A',
  ///   obligationCode: 1,
  ///   month: 1,
  ///   year: 2024,
  /// );
  ///
  /// final result = await client.fileNilReturn(request);
  /// if (result.isAccepted) {
  ///   print('NIL return accepted: ${result.referenceNumber}');
  /// }
  /// ```
  Future<NilReturnResult> fileNilReturn(NilReturnRequest request) async {
    // Validate request
    if (!request.isValid()) {
      throw ArgumentError('Invalid NIL return request');
    }

    final response = await _httpClient.post(
      '/dtd/return/v1/nil',
      body: {
        'TAXPAYERDETAILS': {
          'TaxpayerPIN': request.pinNumber.trim().toUpperCase(),
          'ObligationCode': request.obligationCode,
          'Month': request.month,
          'Year': request.year,
        },
      },
    );

    return NilReturnResult.fromJson(response);
  }

  /// Gets detailed taxpayer information by PIN.
  ///
  /// Example:
  /// ```dart
  /// final details = await client.getTaxpayerDetails('P051234567A');
  /// print('Name: ${details.taxpayerName}');
  /// print('Type: ${details.taxpayerType}');
  /// print('Obligations: ${details.obligationCount}');
  ///
  /// if (details.hasObligations) {
  ///   for (final obligation in details.obligations!) {
  ///     print('${obligation.obligationType}: ${obligation.status}');
  ///   }
  /// }
  /// ```
  Future<TaxpayerDetails> getTaxpayerDetails(String pin) async {
    Validators.validatePin(pin);
    final normalizedPin = pin.trim().toUpperCase();

    // Make API requests to GavaConnect endpoints (profile + obligations)
    final profileResponse = await _httpClient.post(
      '/checker/v1/pinbypin',
      body: {'KRAPIN': normalizedPin},
    );

    final obligationsResponse = await _httpClient.post(
      '/dtd/checker/v1/obligation',
      body: {'taxPayerPin': normalizedPin},
    );

    // Combine profile and obligations data
    final combinedResponse = Map<String, dynamic>.from(profileResponse);
    combinedResponse['obligations'] = obligationsResponse['obligations'] ?? [];

    return TaxpayerDetails.fromJson(combinedResponse);
  }

  /// Clears all cached data.
  ///
  /// Example:
  /// ```dart
  /// client.clearCache();
  /// ```
  void clearCache() {
    _cache.clear();
  }

  /// Removes a specific entry from the cache.
  ///
  /// Example:
  /// ```dart
  /// client.removeCacheEntry('GET:/verify-pin?pin=P051234567A');
  /// ```
  void removeCacheEntry(String key) {
    _cache.remove(key);
  }

  /// Gets cache statistics.
  ///
  /// Example:
  /// ```dart
  /// final stats = client.getCacheStats();
  /// print('Cache size: ${stats['size']}');
  /// print('Cache utilization: ${stats['utilization']}%');
  /// ```
  Map<String, dynamic> getCacheStats() {
    return _cache.getStats();
  }

  /// Gets rate limiter statistics.
  ///
  /// Example:
  /// ```dart
  /// final stats = client.getRateLimiterStats();
  /// print('Available tokens: ${stats['available_tokens']}');
  /// print('Has available token: ${stats['has_available_token']}');
  /// ```
  Map<String, dynamic> getRateLimiterStats() {
    return _rateLimiter.getStats();
  }

  /// Resets the rate limiter.
  ///
  /// Example:
  /// ```dart
  /// client.resetRateLimiter();
  /// ```
  void resetRateLimiter() {
    _rateLimiter.reset();
  }

  /// Gets client statistics.
  ///
  /// Example:
  /// ```dart
  /// final stats = client.getStats();
  /// print('Cache stats: ${stats['cache']}');
  /// print('Rate limiter stats: ${stats['rate_limiter']}');
  /// ```
  Map<String, dynamic> getStats() {
    return {
      'cache': _cache.getStats(),
      'rate_limiter': _rateLimiter.getStats(),
      'config': {
        'base_url': config.baseUrl,
        'timeout_seconds': config.timeout.inSeconds,
        'enable_cache': config.enableCache,
        'enable_rate_limit': config.enableRateLimit,
        'max_retries': config.maxRetries,
      },
    };
  }

  /// Closes the client and releases resources.
  ///
  /// Always call this method when you're done using the client.
  ///
  /// Example:
  /// ```dart
  /// final client = KraClient(config: config);
  /// try {
  ///   // Use client...
  /// } finally {
  ///   client.close();
  /// }
  /// ```
  void close() {
    _httpClient.close();
  }
}

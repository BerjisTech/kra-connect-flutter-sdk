import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/kra_config.dart';
import '../exceptions/api_exception.dart';
import '../exceptions/authentication_exception.dart';
import '../exceptions/network_exception.dart';
import '../exceptions/timeout_exception.dart';
import 'cache_manager.dart';
import 'rate_limiter.dart';
import 'retry_handler.dart';

/// HTTP client for making requests to the KRA API.
class HttpClient {
  final KraConfig config;
  final CacheManager cache;
  final RateLimiter rateLimiter;
  final RetryHandler retryHandler;
  final http.Client _client;

  HttpClient({
    required this.config,
    required this.cache,
    required this.rateLimiter,
    required this.retryHandler,
    http.Client? client,
  }) : _client = client ?? http.Client() {
    config.validate();
  }

  /// Makes a GET request to the API.
  ///
  /// Example:
  /// ```dart
  /// final response = await httpClient.get(
  ///   '/verify-pin',
  ///   queryParams: {'pin': 'P051234567A'},
  /// );
  /// ```
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
    bool useCache = true,
  }) async {
    final uri = _buildUri(endpoint, queryParams);
    final cacheKey = 'GET:$uri';

    // Check cache
    if (useCache && config.enableCache) {
      final cached = cache.get<Map<String, dynamic>>(cacheKey);
      if (cached != null) {
        _log('Cache hit for $cacheKey');
        return cached;
      }
    }

    // Make request
    final response = await _executeRequest(
      () async {
        // Rate limiting
        if (config.enableRateLimit) {
          await rateLimiter.waitAndAcquire();
        }

        _log('GET $uri');

        final httpResponse = await _client
            .get(
              uri,
              headers: _buildHeaders(),
            )
            .timeout(config.timeout);

        return httpResponse;
      },
      endpoint: endpoint,
    );

    final data = _parseResponse(response, endpoint);

    // Store in cache
    if (useCache && config.enableCache) {
      cache.set(cacheKey, data, ttl: config.cacheTtl);
    }

    return data;
  }

  /// Makes a POST request to the API.
  ///
  /// Example:
  /// ```dart
  /// final response = await httpClient.post(
  ///   '/file-nil-return',
  ///   body: {
  ///     'pin': 'P051234567A',
  ///     'period': '2024-01',
  ///   },
  /// );
  /// ```
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final uri = _buildUri(endpoint);

    // Make request
    final response = await _executeRequest(
      () async {
        // Rate limiting
        if (config.enableRateLimit) {
          await rateLimiter.waitAndAcquire();
        }

        _log('POST $uri');

        final httpResponse = await _client
            .post(
              uri,
              headers: _buildHeaders(),
              body: body != null ? jsonEncode(body) : null,
            )
            .timeout(config.timeout);

        return httpResponse;
      },
      endpoint: endpoint,
    );

    return _parseResponse(response, endpoint);
  }

  /// Makes a PUT request to the API.
  ///
  /// Example:
  /// ```dart
  /// final response = await httpClient.put(
  ///   '/update-details',
  ///   body: {'email': 'new@example.com'},
  /// );
  /// ```
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final uri = _buildUri(endpoint);

    // Make request
    final response = await _executeRequest(
      () async {
        // Rate limiting
        if (config.enableRateLimit) {
          await rateLimiter.waitAndAcquire();
        }

        _log('PUT $uri');

        final httpResponse = await _client
            .put(
              uri,
              headers: _buildHeaders(),
              body: body != null ? jsonEncode(body) : null,
            )
            .timeout(config.timeout);

        return httpResponse;
      },
      endpoint: endpoint,
    );

    return _parseResponse(response, endpoint);
  }

  /// Makes a DELETE request to the API.
  ///
  /// Example:
  /// ```dart
  /// final response = await httpClient.delete('/resource/123');
  /// ```
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    final uri = _buildUri(endpoint, queryParams);

    // Make request
    final response = await _executeRequest(
      () async {
        // Rate limiting
        if (config.enableRateLimit) {
          await rateLimiter.waitAndAcquire();
        }

        _log('DELETE $uri');

        final httpResponse = await _client
            .delete(
              uri,
              headers: _buildHeaders(),
            )
            .timeout(config.timeout);

        return httpResponse;
      },
      endpoint: endpoint,
    );

    return _parseResponse(response, endpoint);
  }

  /// Executes a request with retry logic.
  Future<http.Response> _executeRequest(
    Future<http.Response> Function() operation, {
    required String endpoint,
  }) async {
    return await retryHandler.executeWithTimeout(
      operation,
      timeout: config.timeout,
      operationName: endpoint,
      shouldRetry: (error) {
        // Don't retry authentication errors
        if (error is AuthenticationException) return false;

        // Retry network and timeout errors
        if (error is NetworkException) return true;
        if (error is TimeoutException) return true;

        return true;
      },
    );
  }

  /// Builds the complete URI for a request.
  Uri _buildUri(String endpoint, [Map<String, String>? queryParams]) {
    final baseUrl = config.baseUrl.endsWith('/')
        ? config.baseUrl.substring(0, config.baseUrl.length - 1)
        : config.baseUrl;

    final path = endpoint.startsWith('/') ? endpoint : '/$endpoint';

    return Uri.parse('$baseUrl$path').replace(queryParameters: queryParams);
  }

  /// Builds request headers.
  Map<String, String> _buildHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${config.apiKey}',
      'User-Agent': config.userAgent,
    };

    // Add custom headers
    if (config.customHeaders != null) {
      headers.addAll(config.customHeaders!);
    }

    return headers;
  }

  /// Parses an HTTP response into a Map.
  Map<String, dynamic> _parseResponse(
    http.Response response,
    String endpoint,
  ) {
    // Handle authentication errors
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw AuthenticationException(
        response.statusCode == 401
            ? 'Invalid API key or authentication failed'
            : 'Access forbidden',
        response.statusCode,
        endpoint,
      );
    }

    // Handle timeout
    if (response.statusCode == 408) {
      throw TimeoutException(
        'Request timed out',
        endpoint,
        config.timeout,
        1,
      );
    }

    // Handle rate limiting
    if (response.statusCode == 429) {
      final retryAfter = _parseRetryAfter(response.headers);
      throw ApiException(
        'Rate limit exceeded',
        429,
        endpoint,
        responseBody: response.body,
        details: {'retry_after_seconds': retryAfter.inSeconds},
      );
    }

    // Handle client errors (4xx)
    if (response.statusCode >= 400 && response.statusCode < 500) {
      throw ApiException(
        _extractErrorMessage(response.body) ?? 'Client error',
        response.statusCode,
        endpoint,
        responseBody: response.body,
      );
    }

    // Handle server errors (5xx)
    if (response.statusCode >= 500) {
      throw ApiException(
        _extractErrorMessage(response.body) ?? 'Server error',
        response.statusCode,
        endpoint,
        responseBody: response.body,
      );
    }

    // Parse successful response
    if (response.body.isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {'data': decoded};
    } catch (e) {
      throw ApiException(
        'Failed to parse response JSON',
        response.statusCode,
        endpoint,
        responseBody: response.body,
        details: {'parse_error': e.toString()},
      );
    }
  }

  /// Extracts error message from response body.
  String? _extractErrorMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded['message'] ?? decoded['error'] ?? decoded['detail'];
      }
    } catch (_) {
      // Ignore parse errors
    }
    return null;
  }

  /// Parses the Retry-After header.
  Duration _parseRetryAfter(Map<String, String> headers) {
    final retryAfter = headers['retry-after'] ?? headers['Retry-After'];

    if (retryAfter == null) {
      return const Duration(seconds: 60);
    }

    // Try parsing as seconds
    final seconds = int.tryParse(retryAfter);
    if (seconds != null) {
      return Duration(seconds: seconds);
    }

    // Try parsing as HTTP date
    try {
      final date = HttpDate.parse(retryAfter);
      final duration = date.difference(DateTime.now());
      return duration.isNegative ? Duration.zero : duration;
    } catch (_) {
      return const Duration(seconds: 60);
    }
  }

  /// Logs a message if debug logging is enabled.
  void _log(String message) {
    if (config.enableDebugLogging) {
      print('[KRA HTTP Client] $message');
    }
  }

  /// Closes the HTTP client and releases resources.
  void close() {
    _client.close();
  }
}

import 'package:meta/meta.dart';

/// Configuration for the KRA Connect client.
@immutable
class KraConfig {
  /// GavaConnect API key
  final String apiKey;

  /// Base URL for the KRA API
  final String baseUrl;

  /// Request timeout duration
  final Duration timeout;

  /// Whether to enable response caching
  final bool enableCache;

  /// Cache Time-To-Live duration
  final Duration cacheTtl;

  /// Maximum number of cache entries
  final int maxCacheSize;

  /// Whether to enable rate limiting
  final bool enableRateLimit;

  /// Maximum requests per second
  final int maxRequestsPerSecond;

  /// Maximum retry attempts for failed requests
  final int maxRetries;

  /// Initial delay for exponential backoff
  final Duration retryDelay;

  /// Maximum delay between retries
  final Duration maxRetryDelay;

  /// HTTP status codes that should trigger a retry
  final List<int> retryStatusCodes;

  /// Whether to enable debug logging
  final bool enableDebugLogging;

  /// Custom headers to include in all requests
  final Map<String, String>? customHeaders;

  /// User agent string
  final String userAgent;

  const KraConfig({
    required this.apiKey,
    this.baseUrl = 'https://api.kra.go.ke/gavaconnect',
    this.timeout = const Duration(seconds: 30),
    this.enableCache = true,
    this.cacheTtl = const Duration(hours: 1),
    this.maxCacheSize = 100,
    this.enableRateLimit = true,
    this.maxRequestsPerSecond = 10,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
    this.maxRetryDelay = const Duration(seconds: 30),
    this.retryStatusCodes = const [408, 429, 500, 502, 503, 504],
    this.enableDebugLogging = false,
    this.customHeaders,
    this.userAgent = 'kra-connect-flutter/0.1.0',
  });

  /// Creates a copy of this config with optional overrides
  KraConfig copyWith({
    String? apiKey,
    String? baseUrl,
    Duration? timeout,
    bool? enableCache,
    Duration? cacheTtl,
    int? maxCacheSize,
    bool? enableRateLimit,
    int? maxRequestsPerSecond,
    int? maxRetries,
    Duration? retryDelay,
    Duration? maxRetryDelay,
    List<int>? retryStatusCodes,
    bool? enableDebugLogging,
    Map<String, String>? customHeaders,
    String? userAgent,
  }) {
    return KraConfig(
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      timeout: timeout ?? this.timeout,
      enableCache: enableCache ?? this.enableCache,
      cacheTtl: cacheTtl ?? this.cacheTtl,
      maxCacheSize: maxCacheSize ?? this.maxCacheSize,
      enableRateLimit: enableRateLimit ?? this.enableRateLimit,
      maxRequestsPerSecond: maxRequestsPerSecond ?? this.maxRequestsPerSecond,
      maxRetries: maxRetries ?? this.maxRetries,
      retryDelay: retryDelay ?? this.retryDelay,
      maxRetryDelay: maxRetryDelay ?? this.maxRetryDelay,
      retryStatusCodes: retryStatusCodes ?? this.retryStatusCodes,
      enableDebugLogging: enableDebugLogging ?? this.enableDebugLogging,
      customHeaders: customHeaders ?? this.customHeaders,
      userAgent: userAgent ?? this.userAgent,
    );
  }

  /// Validates the configuration
  void validate() {
    if (apiKey.isEmpty) {
      throw ArgumentError('API key cannot be empty');
    }

    if (baseUrl.isEmpty) {
      throw ArgumentError('Base URL cannot be empty');
    }

    if (!baseUrl.startsWith('http://') && !baseUrl.startsWith('https://')) {
      throw ArgumentError('Base URL must start with http:// or https://');
    }

    if (timeout.inMilliseconds <= 0) {
      throw ArgumentError('Timeout must be greater than 0');
    }

    if (maxRetries < 0) {
      throw ArgumentError('Max retries cannot be negative');
    }

    if (maxRetries > 10) {
      throw ArgumentError('Max retries cannot exceed 10');
    }

    if (maxRequestsPerSecond <= 0) {
      throw ArgumentError('Max requests per second must be greater than 0');
    }

    if (maxCacheSize < 0) {
      throw ArgumentError('Max cache size cannot be negative');
    }

    if (cacheTtl.inSeconds <= 0) {
      throw ArgumentError('Cache TTL must be greater than 0');
    }
  }

  /// Creates a [KraConfig] from JSON
  factory KraConfig.fromJson(Map<String, dynamic> json) {
    return KraConfig(
      apiKey: json['api_key'] as String,
      baseUrl: json['base_url'] as String? ??
          'https://api.kra.go.ke/gavaconnect',
      timeout: Duration(
        milliseconds:
            json['timeout_ms'] as int? ?? const Duration(seconds: 30).inMilliseconds,
      ),
      enableCache: json['enable_cache'] as bool? ?? true,
      cacheTtl: Duration(
        seconds:
            json['cache_ttl_seconds'] as int? ?? const Duration(hours: 1).inSeconds,
      ),
      maxCacheSize: json['max_cache_size'] as int? ?? 100,
      enableRateLimit: json['enable_rate_limit'] as bool? ?? true,
      maxRequestsPerSecond: json['max_requests_per_second'] as int? ?? 10,
      maxRetries: json['max_retries'] as int? ?? 3,
      retryDelay: Duration(
        milliseconds: json['retry_delay_ms'] as int? ??
            const Duration(seconds: 1).inMilliseconds,
      ),
      maxRetryDelay: Duration(
        milliseconds: json['max_retry_delay_ms'] as int? ??
            const Duration(seconds: 30).inMilliseconds,
      ),
      retryStatusCodes: json['retry_status_codes'] != null
          ? List<int>.from(json['retry_status_codes'] as List)
          : const [408, 429, 500, 502, 503, 504],
      enableDebugLogging: json['enable_debug_logging'] as bool? ?? false,
      customHeaders: json['custom_headers'] != null
          ? Map<String, String>.from(json['custom_headers'] as Map)
          : null,
      userAgent: json['user_agent'] as String? ?? 'kra-connect-flutter/0.1.0',
    );
  }

  /// Converts this [KraConfig] to JSON
  Map<String, dynamic> toJson() {
    return {
      'api_key': apiKey,
      'base_url': baseUrl,
      'timeout_ms': timeout.inMilliseconds,
      'enable_cache': enableCache,
      'cache_ttl_seconds': cacheTtl.inSeconds,
      'max_cache_size': maxCacheSize,
      'enable_rate_limit': enableRateLimit,
      'max_requests_per_second': maxRequestsPerSecond,
      'max_retries': maxRetries,
      'retry_delay_ms': retryDelay.inMilliseconds,
      'max_retry_delay_ms': maxRetryDelay.inMilliseconds,
      'retry_status_codes': retryStatusCodes,
      'enable_debug_logging': enableDebugLogging,
      if (customHeaders != null) 'custom_headers': customHeaders,
      'user_agent': userAgent,
    };
  }

  @override
  String toString() => 'KraConfig('
      'baseUrl: $baseUrl, '
      'timeout: ${timeout.inSeconds}s, '
      'enableCache: $enableCache, '
      'enableRateLimit: $enableRateLimit, '
      'maxRetries: $maxRetries)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KraConfig &&
          runtimeType == other.runtimeType &&
          apiKey == other.apiKey &&
          baseUrl == other.baseUrl &&
          timeout == other.timeout &&
          enableCache == other.enableCache &&
          cacheTtl == other.cacheTtl &&
          maxCacheSize == other.maxCacheSize &&
          enableRateLimit == other.enableRateLimit &&
          maxRequestsPerSecond == other.maxRequestsPerSecond &&
          maxRetries == other.maxRetries &&
          retryDelay == other.retryDelay &&
          maxRetryDelay == other.maxRetryDelay &&
          enableDebugLogging == other.enableDebugLogging &&
          userAgent == other.userAgent;

  @override
  int get hashCode =>
      apiKey.hashCode ^
      baseUrl.hashCode ^
      timeout.hashCode ^
      enableCache.hashCode ^
      cacheTtl.hashCode ^
      maxCacheSize.hashCode ^
      enableRateLimit.hashCode ^
      maxRequestsPerSecond.hashCode ^
      maxRetries.hashCode ^
      retryDelay.hashCode ^
      maxRetryDelay.hashCode ^
      enableDebugLogging.hashCode ^
      userAgent.hashCode;
}

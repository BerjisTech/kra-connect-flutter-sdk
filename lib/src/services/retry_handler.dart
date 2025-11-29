import 'dart:math' as math;
import '../exceptions/timeout_exception.dart' as kra_timeout;

/// Handles retry logic with exponential backoff.
class RetryHandler {
  final int maxRetries;
  final Duration initialDelay;
  final Duration maxDelay;
  final List<int> retryStatusCodes;
  final bool enableJitter;

  const RetryHandler({
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 30),
    this.retryStatusCodes = const [408, 429, 500, 502, 503, 504],
    this.enableJitter = true,
  });

  /// Executes a function with retry logic.
  ///
  /// The function will be retried up to [maxRetries] times if it throws
  /// an exception that is retryable.
  ///
  /// Example:
  /// ```dart
  /// final result = await retryHandler.execute(
  ///   () async {
  ///     final response = await http.get(url);
  ///     if (response.statusCode == 500) {
  ///       throw Exception('Server error');
  ///     }
  ///     return response;
  ///   },
  ///   operationName: 'API request',
  /// );
  /// ```
  Future<T> execute<T>(
    Future<T> Function() operation, {
    String operationName = 'operation',
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempt = 0;
    dynamic lastError;

    while (attempt <= maxRetries) {
      try {
        return await operation();
      } catch (error) {
        lastError = error;
        attempt++;

        // Check if we should retry
        if (attempt > maxRetries) {
          rethrow;
        }

        if (shouldRetry != null && !shouldRetry(error)) {
          rethrow;
        }

        if (!_isRetryable(error)) {
          rethrow;
        }

        // Calculate delay with exponential backoff
        final delay = _calculateDelay(attempt);

        // Wait before retrying
        await Future.delayed(delay);
      }
    }

    // If we get here, we've exhausted all retries
    throw lastError;
  }

  /// Executes a function with retry logic and a timeout.
  ///
  /// Example:
  /// ```dart
  /// final result = await retryHandler.executeWithTimeout(
  ///   () async {
  ///     return await apiClient.get(url);
  ///   },
  ///   timeout: Duration(seconds: 30),
  ///   operationName: 'API request',
  /// );
  /// ```
  Future<T> executeWithTimeout<T>(
    Future<T> Function() operation, {
    required Duration timeout,
    String operationName = 'operation',
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempt = 0;
    dynamic lastError;

    while (attempt <= maxRetries) {
      try {
        return await operation().timeout(
          timeout,
          onTimeout: () {
            throw kra_timeout.TimeoutException(
              'Operation timed out after ${timeout.inSeconds} seconds',
              operationName,
              timeout,
              attempt + 1,
            );
          },
        );
      } catch (error) {
        lastError = error;
        attempt++;

        // Check if we should retry
        if (attempt > maxRetries) {
          rethrow;
        }

        if (shouldRetry != null && !shouldRetry(error)) {
          rethrow;
        }

        if (!_isRetryable(error)) {
          rethrow;
        }

        // Calculate delay with exponential backoff
        final delay = _calculateDelay(attempt);

        // Wait before retrying
        await Future.delayed(delay);
      }
    }

    // If we get here, we've exhausted all retries
    throw lastError;
  }

  /// Calculates the delay for a given attempt using exponential backoff.
  ///
  /// Formula: initialDelay * (2 ^ (attempt - 1))
  ///
  /// Example:
  /// - Attempt 1: 1s
  /// - Attempt 2: 2s
  /// - Attempt 3: 4s
  /// - Attempt 4: 8s
  ///
  /// With jitter, a random value between 0-10% of the delay is added.
  Duration _calculateDelay(int attempt) {
    // Exponential backoff: initialDelay * 2^(attempt-1)
    final exponent = attempt - 1;
    final baseDelayMs = initialDelay.inMilliseconds * math.pow(2, exponent);

    // Cap at max delay
    final cappedDelayMs = math.min(baseDelayMs, maxDelay.inMilliseconds.toDouble());

    // Add jitter if enabled (0-10% of the delay)
    double finalDelayMs = cappedDelayMs;
    if (enableJitter) {
      final jitterRange = cappedDelayMs * 0.1;
      final jitter = math.Random().nextDouble() * jitterRange;
      finalDelayMs = cappedDelayMs + jitter;
    }

    return Duration(milliseconds: finalDelayMs.toInt());
  }

  /// Determines if an error is retryable.
  bool _isRetryable(dynamic error) {
    // Timeout exceptions are retryable
    if (error is kra_timeout.TimeoutException) {
      return true;
    }

    // Check error message for common retryable patterns
    final errorMessage = error.toString().toLowerCase();

    if (errorMessage.contains('timeout')) return true;
    if (errorMessage.contains('connection')) return true;
    if (errorMessage.contains('network')) return true;
    if (errorMessage.contains('socket')) return true;
    if (errorMessage.contains('failed host lookup')) return true;

    // Check for HTTP status codes if available
    if (error is Exception) {
      final message = error.toString();
      for (final code in retryStatusCodes) {
        if (message.contains(code.toString())) {
          return true;
        }
      }
    }

    return false;
  }

  /// Returns retry statistics for a given attempt.
  ///
  /// Example:
  /// ```dart
  /// final stats = retryHandler.getRetryStats(attempt: 2);
  /// print('Next delay: ${stats['next_delay_ms']}ms');
  /// print('Attempts remaining: ${stats['attempts_remaining']}');
  /// ```
  Map<String, dynamic> getRetryStats({required int attempt}) {
    final nextDelay = attempt <= maxRetries ? _calculateDelay(attempt) : null;

    return {
      'max_retries': maxRetries,
      'current_attempt': attempt,
      'attempts_remaining': math.max(0, maxRetries - attempt + 1),
      'next_delay_ms': nextDelay?.inMilliseconds,
      'next_delay_seconds': nextDelay?.inSeconds,
      'enable_jitter': enableJitter,
    };
  }

  /// Creates a copy of this handler with optional overrides.
  RetryHandler copyWith({
    int? maxRetries,
    Duration? initialDelay,
    Duration? maxDelay,
    List<int>? retryStatusCodes,
    bool? enableJitter,
  }) {
    return RetryHandler(
      maxRetries: maxRetries ?? this.maxRetries,
      initialDelay: initialDelay ?? this.initialDelay,
      maxDelay: maxDelay ?? this.maxDelay,
      retryStatusCodes: retryStatusCodes ?? this.retryStatusCodes,
      enableJitter: enableJitter ?? this.enableJitter,
    );
  }
}

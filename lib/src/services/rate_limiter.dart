import '../exceptions/rate_limit_exception.dart';

/// Token bucket rate limiter for controlling request rates.
class RateLimiter {
  final int maxRequestsPerSecond;
  final bool enabled;

  double _tokens;
  DateTime _lastRefill;

  RateLimiter({
    required this.maxRequestsPerSecond,
    this.enabled = true,
  })  : _tokens = maxRequestsPerSecond.toDouble(),
        _lastRefill = DateTime.now();

  /// Waits for a token to become available.
  ///
  /// Throws [RateLimitException] if rate limit is exceeded and no tokens are available.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await rateLimiter.acquire();
  ///   // Make API request
  /// } catch (e) {
  ///   if (e is RateLimitException) {
  ///     print('Rate limit exceeded, retry after ${e.retryAfter}');
  ///   }
  /// }
  /// ```
  Future<void> acquire() async {
    if (!enabled) {
      return;
    }

    _refill();

    if (_tokens >= 1.0) {
      _tokens -= 1.0;
      return;
    }

    // Calculate wait time
    final waitTime = _calculateWaitTime();

    throw RateLimitException(
      'Rate limit exceeded. Please retry after ${waitTime.inSeconds} seconds',
      maxRequestsPerSecond,
      waitTime,
    );
  }

  /// Tries to acquire a token without throwing an exception.
  ///
  /// Returns `true` if a token was acquired, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// if (await rateLimiter.tryAcquire()) {
  ///   // Make API request
  /// } else {
  ///   print('Rate limit exceeded');
  /// }
  /// ```
  Future<bool> tryAcquire() async {
    if (!enabled) {
      return true;
    }

    _refill();

    if (_tokens >= 1.0) {
      _tokens -= 1.0;
      return true;
    }

    return false;
  }

  /// Waits until a token is available and acquires it.
  ///
  /// This method will delay execution until a token becomes available.
  ///
  /// Example:
  /// ```dart
  /// await rateLimiter.waitAndAcquire();
  /// // Token acquired, proceed with request
  /// ```
  Future<void> waitAndAcquire() async {
    if (!enabled) {
      return;
    }

    _refill();

    if (_tokens >= 1.0) {
      _tokens -= 1.0;
      return;
    }

    // Calculate wait time and delay
    final waitTime = _calculateWaitTime();
    await Future.delayed(waitTime);

    // Refill after waiting
    _refill();
    _tokens -= 1.0;
  }

  /// Estimates the wait time until a token becomes available.
  ///
  /// Returns [Duration.zero] if a token is currently available.
  ///
  /// Example:
  /// ```dart
  /// final waitTime = rateLimiter.estimateWaitTime();
  /// print('Wait time: ${waitTime.inSeconds}s');
  /// ```
  Duration estimateWaitTime() {
    if (!enabled) {
      return Duration.zero;
    }

    _refill();

    if (_tokens >= 1.0) {
      return Duration.zero;
    }

    return _calculateWaitTime();
  }

  /// Refills the token bucket based on elapsed time.
  void _refill() {
    final now = DateTime.now();
    final elapsed = now.difference(_lastRefill);
    final elapsedSeconds = elapsed.inMilliseconds / 1000.0;

    // Calculate tokens to add based on rate
    final tokensToAdd = elapsedSeconds * maxRequestsPerSecond;

    if (tokensToAdd > 0) {
      _tokens = (_tokens + tokensToAdd).clamp(0.0, maxRequestsPerSecond.toDouble());
      _lastRefill = now;
    }
  }

  /// Calculates the wait time needed to acquire a token.
  Duration _calculateWaitTime() {
    // Time needed to generate one token
    final secondsPerToken = 1.0 / maxRequestsPerSecond;

    // Tokens needed
    final tokensNeeded = 1.0 - _tokens;

    // Calculate wait time in milliseconds
    final waitMilliseconds = (tokensNeeded * secondsPerToken * 1000).ceil();

    // Add a small buffer to ensure token is available
    return Duration(milliseconds: waitMilliseconds + 10);
  }

  /// Returns the current number of available tokens.
  double get availableTokens {
    _refill();
    return _tokens;
  }

  /// Returns true if a token is currently available.
  bool get hasAvailableToken {
    _refill();
    return _tokens >= 1.0;
  }

  /// Returns rate limiter statistics.
  ///
  /// Example:
  /// ```dart
  /// final stats = rateLimiter.getStats();
  /// print('Available tokens: ${stats['available_tokens']}');
  /// print('Utilization: ${stats['utilization']}%');
  /// ```
  Map<String, dynamic> getStats() {
    _refill();

    return {
      'enabled': enabled,
      'max_requests_per_second': maxRequestsPerSecond,
      'available_tokens': _tokens.toStringAsFixed(2),
      'utilization': ((1 - (_tokens / maxRequestsPerSecond)) * 100).toStringAsFixed(2),
      'has_available_token': hasAvailableToken,
      'estimated_wait_ms': estimateWaitTime().inMilliseconds,
    };
  }

  /// Resets the rate limiter to its initial state.
  ///
  /// Example:
  /// ```dart
  /// rateLimiter.reset();
  /// ```
  void reset() {
    _tokens = maxRequestsPerSecond.toDouble();
    _lastRefill = DateTime.now();
  }
}

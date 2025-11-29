import 'dart:collection';
import '../exceptions/cache_exception.dart';

/// Entry in the cache with expiry time.
class _CacheEntry<T> {
  final T value;
  final DateTime expiresAt;
  DateTime lastAccessed;

  _CacheEntry(this.value, this.expiresAt) : lastAccessed = DateTime.now();

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  void touch() {
    lastAccessed = DateTime.now();
  }
}

/// Manages response caching with LRU eviction policy.
class CacheManager {
  final int maxSize;
  final Duration defaultTtl;
  final LinkedHashMap<String, _CacheEntry<dynamic>> _cache;

  CacheManager({
    this.maxSize = 100,
    this.defaultTtl = const Duration(hours: 1),
  }) : _cache = LinkedHashMap<String, _CacheEntry<dynamic>>();

  /// Gets a value from the cache.
  ///
  /// Returns `null` if the key doesn't exist or the entry has expired.
  ///
  /// Example:
  /// ```dart
  /// final result = cache.get<PinVerificationResult>('pin:P051234567A');
  /// if (result != null) {
  ///   print('Cache hit!');
  /// }
  /// ```
  T? get<T>(String key) {
    try {
      final entry = _cache[key];

      if (entry == null) {
        return null;
      }

      if (entry.isExpired) {
        _cache.remove(key);
        return null;
      }

      entry.touch();
      _moveToEnd(key);

      return entry.value as T;
    } catch (e) {
      throw CacheException(
        'Failed to retrieve value from cache',
        'get',
        key,
        details: {'error': e.toString()},
      );
    }
  }

  /// Sets a value in the cache.
  ///
  /// If [ttl] is not provided, [defaultTtl] is used.
  ///
  /// Example:
  /// ```dart
  /// cache.set('pin:P051234567A', result, ttl: Duration(minutes: 30));
  /// ```
  void set<T>(String key, T value, {Duration? ttl}) {
    try {
      final effectiveTtl = ttl ?? defaultTtl;
      final expiresAt = DateTime.now().add(effectiveTtl);

      _cache[key] = _CacheEntry<T>(value, expiresAt);
      _moveToEnd(key);

      if (_cache.length > maxSize) {
        _evictLru();
      }
    } catch (e) {
      throw CacheException(
        'Failed to store value in cache',
        'set',
        key,
        details: {'error': e.toString()},
      );
    }
  }

  /// Checks if a key exists in the cache and is not expired.
  ///
  /// Example:
  /// ```dart
  /// if (cache.has('pin:P051234567A')) {
  ///   print('Key exists in cache');
  /// }
  /// ```
  bool has(String key) {
    final entry = _cache[key];

    if (entry == null) {
      return false;
    }

    if (entry.isExpired) {
      _cache.remove(key);
      return false;
    }

    return true;
  }

  /// Removes a value from the cache.
  ///
  /// Example:
  /// ```dart
  /// cache.remove('pin:P051234567A');
  /// ```
  void remove(String key) {
    try {
      _cache.remove(key);
    } catch (e) {
      throw CacheException(
        'Failed to remove value from cache',
        'remove',
        key,
        details: {'error': e.toString()},
      );
    }
  }

  /// Clears all entries from the cache.
  ///
  /// Example:
  /// ```dart
  /// cache.clear();
  /// ```
  void clear() {
    try {
      _cache.clear();
    } catch (e) {
      throw const CacheException(
        'Failed to clear cache',
        'clear',
        'all',
      );
    }
  }

  /// Removes all expired entries from the cache.
  ///
  /// Example:
  /// ```dart
  /// cache.cleanUp();
  /// ```
  int cleanUp() {
    try {
      final keysToRemove = <String>[];

      for (final entry in _cache.entries) {
        if (entry.value.isExpired) {
          keysToRemove.add(entry.key);
        }
      }

      for (final key in keysToRemove) {
        _cache.remove(key);
      }

      return keysToRemove.length;
    } catch (e) {
      throw const CacheException(
        'Failed to clean up cache',
        'cleanUp',
        'all',
      );
    }
  }

  /// Returns the number of entries in the cache.
  int get size => _cache.length;

  /// Returns true if the cache is empty.
  bool get isEmpty => _cache.isEmpty;

  /// Returns true if the cache is at capacity.
  bool get isFull => _cache.length >= maxSize;

  /// Returns cache statistics.
  ///
  /// Example:
  /// ```dart
  /// final stats = cache.getStats();
  /// print('Cache size: ${stats['size']}');
  /// print('Cache utilization: ${stats['utilization']}%');
  /// ```
  Map<String, dynamic> getStats() {
    final now = DateTime.now();
    int expiredCount = 0;

    for (final entry in _cache.values) {
      if (entry.isExpired) {
        expiredCount++;
      }
    }

    return {
      'size': _cache.length,
      'max_size': maxSize,
      'utilization': (_cache.length / maxSize * 100).toStringAsFixed(2),
      'expired_entries': expiredCount,
      'valid_entries': _cache.length - expiredCount,
    };
  }

  /// Returns all cache keys.
  List<String> getKeys() {
    return _cache.keys.toList();
  }

  /// Returns all valid (non-expired) cache keys.
  List<String> getValidKeys() {
    final validKeys = <String>[];

    for (final entry in _cache.entries) {
      if (!entry.value.isExpired) {
        validKeys.add(entry.key);
      }
    }

    return validKeys;
  }

  /// Removes keys matching a pattern.
  ///
  /// Example:
  /// ```dart
  /// // Remove all PIN verification results
  /// cache.removePattern(RegExp(r'^pin:'));
  /// ```
  int removePattern(RegExp pattern) {
    try {
      final keysToRemove = <String>[];

      for (final key in _cache.keys) {
        if (pattern.hasMatch(key)) {
          keysToRemove.add(key);
        }
      }

      for (final key in keysToRemove) {
        _cache.remove(key);
      }

      return keysToRemove.length;
    } catch (e) {
      throw CacheException(
        'Failed to remove keys by pattern',
        'removePattern',
        pattern.pattern,
        details: {'error': e.toString()},
      );
    }
  }

  /// Moves a key to the end of the cache (most recently used).
  void _moveToEnd(String key) {
    final entry = _cache.remove(key);
    if (entry != null) {
      _cache[key] = entry;
    }
  }

  /// Evicts the least recently used entry from the cache.
  void _evictLru() {
    if (_cache.isEmpty) {
      return;
    }

    // First key is the least recently used
    final firstKey = _cache.keys.first;
    _cache.remove(firstKey);
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:kra_connect/kra_connect.dart';

void main() {
  group('CacheManager', () {
    late CacheManager cache;

    setUp(() {
      cache = CacheManager(
        maxSize: 3,
        defaultTtl: const Duration(milliseconds: 100),
      );
    });

    test('should store and retrieve values', () {
      cache.set('key1', 'value1');
      expect(cache.get<String>('key1'), 'value1');
    });

    test('should return null for non-existent keys', () {
      expect(cache.get<String>('non-existent'), null);
    });

    test('should handle different value types', () {
      cache.set('string', 'value');
      cache.set('int', 42);
      cache.set('map', {'key': 'value'});

      expect(cache.get<String>('string'), 'value');
      expect(cache.get<int>('int'), 42);
      expect(cache.get<Map<String, String>>('map'), {'key': 'value'});
    });

    test('should respect TTL and expire entries', () async {
      cache.set('key1', 'value1', ttl: const Duration(milliseconds: 50));

      // Should exist immediately
      expect(cache.has('key1'), true);
      expect(cache.get<String>('key1'), 'value1');

      // Wait for expiry
      await Future.delayed(const Duration(milliseconds: 100));

      // Should be expired
      expect(cache.has('key1'), false);
      expect(cache.get<String>('key1'), null);
    });

    test('should evict LRU entry when cache is full', () {
      cache.set('key1', 'value1');
      cache.set('key2', 'value2');
      cache.set('key3', 'value3');

      // Cache is now full (maxSize = 3)
      expect(cache.size, 3);

      // Access key1 to make it more recently used
      cache.get<String>('key1');

      // Add key4, should evict key2 (least recently used)
      cache.set('key4', 'value4');

      expect(cache.size, 3);
      expect(cache.has('key1'), true);  // Accessed recently
      expect(cache.has('key2'), false); // Evicted (LRU)
      expect(cache.has('key3'), true);
      expect(cache.has('key4'), true);
    });

    test('should clear all entries', () {
      cache.set('key1', 'value1');
      cache.set('key2', 'value2');

      expect(cache.size, 2);

      cache.clear();

      expect(cache.size, 0);
      expect(cache.isEmpty, true);
      expect(cache.has('key1'), false);
      expect(cache.has('key2'), false);
    });

    test('should remove specific entry', () {
      cache.set('key1', 'value1');
      cache.set('key2', 'value2');

      cache.remove('key1');

      expect(cache.has('key1'), false);
      expect(cache.has('key2'), true);
      expect(cache.size, 1);
    });

    test('should clean up expired entries', () async {
      cache.set('key1', 'value1', ttl: const Duration(milliseconds: 50));
      cache.set('key2', 'value2', ttl: const Duration(seconds: 10));
      cache.set('key3', 'value3', ttl: const Duration(milliseconds: 50));

      expect(cache.size, 3);

      // Wait for some entries to expire
      await Future.delayed(const Duration(milliseconds: 100));

      final removedCount = cache.cleanUp();

      expect(removedCount, 2); // key1 and key3 expired
      expect(cache.size, 1);
      expect(cache.has('key2'), true);
    });

    test('should return cache statistics', () {
      cache.set('key1', 'value1');
      cache.set('key2', 'value2');

      final stats = cache.getStats();

      expect(stats['size'], 2);
      expect(stats['max_size'], 3);
      expect(stats['utilization'], contains('66.67'));
    });

    test('should return all keys', () {
      cache.set('key1', 'value1');
      cache.set('key2', 'value2');
      cache.set('key3', 'value3');

      final keys = cache.getKeys();

      expect(keys.length, 3);
      expect(keys, contains('key1'));
      expect(keys, contains('key2'));
      expect(keys, contains('key3'));
    });

    test('should return only valid keys', () async {
      cache.set('key1', 'value1', ttl: const Duration(milliseconds: 50));
      cache.set('key2', 'value2', ttl: const Duration(seconds: 10));

      await Future.delayed(const Duration(milliseconds: 100));

      final validKeys = cache.getValidKeys();

      expect(validKeys.length, 1);
      expect(validKeys, contains('key2'));
      expect(validKeys, isNot(contains('key1')));
    });

    test('should remove keys matching pattern', () {
      cache.set('pin:P051234567A', 'value1');
      cache.set('pin:P059876543B', 'value2');
      cache.set('tcc:TCC123456', 'value3');

      final removedCount = cache.removePattern(RegExp(r'^pin:'));

      expect(removedCount, 2);
      expect(cache.size, 1);
      expect(cache.has('tcc:TCC123456'), true);
    });

    test('isFull should return correct status', () {
      expect(cache.isFull, false);

      cache.set('key1', 'value1');
      cache.set('key2', 'value2');
      cache.set('key3', 'value3');

      expect(cache.isFull, true);
    });
  });
}

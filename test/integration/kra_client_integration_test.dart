import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:kra_connect/kra_connect.dart';

void main() {
  group('KraClient Integration Tests (Mocked)', () {
    late KraClient client;
    late MockClient mockHttpClient;

    setUp(() {
      // Create mock HTTP client
      mockHttpClient = MockClient((request) async {
        // Mock PIN verification
        if (request.url.path.contains('/verify-pin')) {
          final pin = request.url.queryParameters['pin'];

          if (pin == 'P051234567A') {
            return http.Response(
              jsonEncode({
                'pin_number': pin,
                'is_valid': true,
                'taxpayer_name': 'John Doe',
                'taxpayer_type': 'individual',
                'status': 'active',
                'verified_at': DateTime.now().toIso8601String(),
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          } else {
            return http.Response(
              jsonEncode({
                'pin_number': pin,
                'is_valid': false,
                'verified_at': DateTime.now().toIso8601String(),
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }
        }

        // Mock TCC verification
        if (request.url.path.contains('/verify-tcc')) {
          final tcc = request.url.queryParameters['tcc'];

          return http.Response(
            jsonEncode({
              'tcc_number': tcc,
              'is_valid': true,
              'pin_number': 'P051234567A',
              'taxpayer_name': 'John Doe',
              'issue_date': '2024-01-01',
              'expiry_date': '2024-12-31',
              'verified_at': DateTime.now().toIso8601String(),
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        // Mock e-slip validation
        if (request.url.path.contains('/validate-eslip')) {
          final eslip = request.url.queryParameters['eslip'];

          return http.Response(
            jsonEncode({
              'eslip_number': eslip,
              'is_valid': true,
              'taxpayer_pin': 'P051234567A',
              'taxpayer_name': 'John Doe',
              'amount': 10000.0,
              'currency': 'KES',
              'status': 'paid',
              'validated_at': DateTime.now().toIso8601String(),
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        // Mock batch PIN verification
        if (request.url.path.contains('/verify-pin-batch')) {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          final pins = body['pins'] as List;

          final results = pins.map((pin) => {
            'pin_number': pin,
            'is_valid': true,
            'taxpayer_name': 'Test User',
            'status': 'active',
            'verified_at': DateTime.now().toIso8601String(),
          }).toList();

          return http.Response(
            jsonEncode({'results': results}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        // Mock NIL return filing
        if (request.url.path.contains('/file-nil-return')) {
          final body = jsonDecode(request.body) as Map<String, dynamic>;

          return http.Response(
            jsonEncode({
              'pin_number': body['pin_number'],
              'obligation_type': body['obligation_type'],
              'tax_period': body['tax_period'],
              'is_accepted': true,
              'reference_number': 'REF123456',
              'acknowledgement_number': 'ACK789012',
              'status': 'accepted',
              'filed_at': DateTime.now().toIso8601String(),
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        // Mock taxpayer details
        if (request.url.path.contains('/taxpayer-details')) {
          final pin = request.url.queryParameters['pin'];

          return http.Response(
            jsonEncode({
              'pin_number': pin,
              'taxpayer_name': 'John Doe',
              'taxpayer_type': 'individual',
              'is_active': true,
              'retrieved_at': DateTime.now().toIso8601String(),
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        return http.Response('Not Found', 404);
      });

      // Create client with mocked HTTP client
      final config = KraConfig(apiKey: 'test-api-key');
      final cache = CacheManager(maxSize: 100, defaultTtl: const Duration(hours: 1));
      final rateLimiter = RateLimiter(maxRequestsPerSecond: 10, enabled: false);
      final retryHandler = const RetryHandler(maxRetries: 0);

      final httpClient = HttpClient(
        config: config,
        cache: cache,
        rateLimiter: rateLimiter,
        retryHandler: retryHandler,
        client: mockHttpClient,
      );

      client = KraClient(
        config: config,
        cache: cache,
        rateLimiter: rateLimiter,
        retryHandler: retryHandler,
        httpClient: httpClient,
      );
    });

    tearDown(() {
      client.close();
      mockHttpClient.close();
    });

    test('should verify valid PIN', () async {
      final result = await client.verifyPin('P051234567A');

      expect(result.isValid, true);
      expect(result.pinNumber, 'P051234567A');
      expect(result.taxpayerName, 'John Doe');
      expect(result.isActive, true);
    });

    test('should verify invalid PIN', () async {
      final result = await client.verifyPin('P999999999Z');

      expect(result.isValid, false);
      expect(result.pinNumber, 'P999999999Z');
    });

    test('should verify TCC', () async {
      final result = await client.verifyTcc('TCC123456');

      expect(result.isValid, true);
      expect(result.tccNumber, 'TCC123456');
      expect(result.pinNumber, 'P051234567A');
    });

    test('should validate e-slip', () async {
      final result = await client.validateEslip('ABC1234567890');

      expect(result.isValid, true);
      expect(result.eslipNumber, 'ABC1234567890');
      expect(result.isPaid, true);
      expect(result.amount, 10000.0);
    });

    test('should verify batch of PINs', () async {
      final results = await client.verifyPinBatch([
        'P051234567A',
        'P059876543B',
        'P051111111C',
      ]);

      expect(results.length, 3);
      expect(results.every((r) => r.isValid), true);
    });

    test('should file NIL return', () async {
      final request = NilReturnRequest(
        pinNumber: 'P051234567A',
        obligationType: 'VAT',
        taxPeriod: '2024-01',
        reason: 'No business activity',
        declaration: true,
      );

      final result = await client.fileNilReturn(request);

      expect(result.isAccepted, true);
      expect(result.pinNumber, 'P051234567A');
      expect(result.hasReferenceNumber, true);
    });

    test('should get taxpayer details', () async {
      final details = await client.getTaxpayerDetails('P051234567A');

      expect(details.pinNumber, 'P051234567A');
      expect(details.taxpayerName, 'John Doe');
      expect(details.isActive, true);
    });

    test('should throw ValidationException for invalid PIN format', () async {
      expect(
        () => client.verifyPin('INVALID'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('should throw ValidationException for invalid TCC format', () async {
      expect(
        () => client.verifyTcc('INVALID'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('should use cache for repeated requests', () async {
      // First request
      final result1 = await client.verifyPin('P051234567A');

      // Second request (should hit cache)
      final result2 = await client.verifyPin('P051234567A');

      expect(result1.pinNumber, result2.pinNumber);
      expect(result1.taxpayerName, result2.taxpayerName);

      // Check cache stats
      final stats = client.getCacheStats();
      expect(stats['size'], greaterThan(0));
    });

    test('should clear cache', () async {
      // Make a request to populate cache
      await client.verifyPin('P051234567A');

      expect(client.getCacheStats()['size'], greaterThan(0));

      // Clear cache
      client.clearCache();

      expect(client.getCacheStats()['size'], 0);
    });

    test('should return client statistics', () {
      final stats = client.getStats();

      expect(stats, contains('cache'));
      expect(stats, contains('rate_limiter'));
      expect(stats, contains('config'));
    });
  });
}

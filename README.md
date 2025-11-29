# KRA-Connect Flutter/Dart SDK

> Official Flutter/Dart SDK for Kenya Revenue Authority's GavaConnect API

[![Pub Version](https://img.shields.io/pub/v/kra_connect.svg?style=flat-square)](https://pub.dev/packages/kra_connect)
[![Dart SDK](https://img.shields.io/badge/Dart-3.0%2B-blue.svg?style=flat-square)](https://dart.dev)
[![Flutter](https://img.shields.io/badge/Flutter-3.10%2B-blue.svg?style=flat-square)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg?style=flat-square)](https://opensource.org/licenses/MIT)
[![Tests](https://img.shields.io/github/actions/workflow/status/kra-connect/flutter-sdk/tests.yml?branch=main&label=tests&style=flat-square)](https://github.com/kra-connect/flutter-sdk/actions)

## Features

- ✅ **PIN Verification** - Verify KRA PIN numbers
- ✅ **TCC Verification** - Check Tax Compliance Certificates
- ✅ **e-Slip Validation** - Validate electronic payment slips
- ✅ **NIL Returns** - File NIL returns programmatically
- ✅ **Taxpayer Details** - Retrieve taxpayer information
- ✅ **Type Safety** - Full Dart type safety with null safety
- ✅ **Async/Await** - Modern asynchronous API
- ✅ **Retry Logic** - Automatic retry with exponential backoff
- ✅ **Caching** - Response caching with TTL
- ✅ **Rate Limiting** - Built-in rate limiter
- ✅ **Cross-Platform** - Works on Android, iOS, Web, Desktop
- ✅ **Zero UI Dependencies** - Pure Dart package

## Requirements

- Dart 3.0 or higher
- Flutter 3.10 or higher

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  kra_connect: ^0.1.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

```dart
import 'package:kra_connect/kra_connect.dart';

void main() async {
  // Create client
  final client = KraClient(
    config: KraConfig(apiKey: 'your-api-key-here'),
  );

  try {
    // Verify PIN
    final result = await client.verifyPin('P051234567A');

    if (result.isValid) {
      print('Valid PIN: ${result.taxpayerName}');
      print('Status: ${result.status}');
    }
  } on KraException catch (e) {
    print('Error: ${e.message}');
  } finally {
    client.close();
  }
}
```

## Usage Examples

### PIN Verification

```dart
final client = KraClient(
  config: KraConfig(apiKey: 'your-api-key'),
);

try {
  final result = await client.verifyPin('P051234567A');

  print('Valid: ${result.isValid}');
  print('Name: ${result.taxpayerName}');
  print('Type: ${result.taxpayerType}');
  print('Status: ${result.status}');

  // Helper methods
  if (result.isActive) {
    print('PIN is active');
  }

  if (result.isCompany) {
    print('Taxpayer is a company');
  }
} on ValidationException catch (e) {
  print('Invalid PIN format: ${e.message}');
} on ApiException catch (e) {
  print('API error: ${e.message}');
}
```

### TCC Verification

```dart
final result = await client.verifyTcc('TCC123456');

if (result.isValid && !result.isExpired) {
  print('TCC valid until: ${result.expiryDate}');
  print('Days remaining: ${result.daysUntilExpiry}');

  if (result.isExpiringSoon(30)) {
    print('TCC expires within 30 days!');
  }
}
```

### E-slip Validation

```dart
final result = await client.validateEslip('1234567890');

if (result.isPaid) {
  print('Payment confirmed: ${result.currency} ${result.amount}');
  print('Payment date: ${result.paymentDate}');
} else if (result.isPending) {
  print('Payment pending');
}
```

### NIL Return Filing

```dart
final result = await client.fileNilReturn(
  NilReturnRequest(
    pinNumber: 'P051234567A',
    obligationId: 'OBL123456',
    period: '202401',
  ),
);

if (result.isAccepted) {
  print('Reference: ${result.referenceNumber}');
  print('Acknowledgement: ${result.acknowledgementNumber}');
}
```

### Taxpayer Details

```dart
final details = await client.getTaxpayerDetails('P051234567A');

print('Name: ${details.displayName}');
print('Type: ${details.taxpayerType}');
print('Email: ${details.emailAddress}');
print('Phone: ${details.phoneNumber}');

// Check obligations
if (details.hasObligation('VAT')) {
  print('Taxpayer has VAT obligation');
}

// Check obligations status
for (final obligation in details.obligations) {
  if (obligation.isFilingOverdue) {
    print('Overdue: ${obligation.description}');
  } else if (obligation.isFilingDueSoon(7)) {
    print('Due soon: ${obligation.description}');
  }
}
```

### Batch Operations

```dart
// Verify multiple PINs concurrently
final pins = ['P051234567A', 'P051234567B', 'P051234567C'];
final results = await client.verifyPinBatch(pins);

for (final result in results) {
  print('${result.pinNumber}: ${result.isValid}');
}

// Verify multiple TCCs concurrently
final tccs = ['TCC123456', 'TCC123457'];
final tccResults = await client.verifyTccBatch(tccs);
```

### Configuration

```dart
final client = KraClient(
  config: KraConfig(
    apiKey: 'your-api-key',
    baseUrl: 'https://api.kra.go.ke/gavaconnect',
    timeout: Duration(seconds: 30),

    // Retry configuration
    maxRetries: 3,
    retryDelay: Duration(seconds: 1),
    maxRetryDelay: Duration(seconds: 30),

    // Rate limiting
    enableRateLimit: true,
    maxRequestsPerSecond: 10,

    // Caching
    enableCache: true,
    cacheTtl: Duration(hours: 1),
    maxCacheSize: 100,

    // Debug mode
    enableDebugLogging: false,
  ),
);
```

### Error Handling

```dart
try {
  final result = await client.verifyPin('P051234567A');
  print('Valid: ${result.isValid}');
} on ValidationException catch (e) {
  // Input validation error
  print('Validation error: ${e.message}');
  print('Field: ${e.field}');
} on AuthenticationException catch (e) {
  // API key invalid
  print('Authentication failed: ${e.message}');
} on RateLimitException catch (e) {
  // Rate limit exceeded
  print('Rate limited. Retry after: ${e.retryAfter}');
} on TimeoutException catch (e) {
  // Request timed out
  print('Request timed out: ${e.message}');
} on ApiException catch (e) {
  // General API error
  print('API error (${e.statusCode}): ${e.message}');
} on KraException catch (e) {
  // Base exception
  print('Error: ${e.message}');
} catch (e) {
  // Unexpected error
  print('Unexpected error: $e');
}
```

### Using with Flutter Widgets

```dart
class PinVerificationWidget extends StatefulWidget {
  @override
  _PinVerificationWidgetState createState() => _PinVerificationWidgetState();
}

class _PinVerificationWidgetState extends State<PinVerificationWidget> {
  final _client = KraClient(
    config: KraConfig(apiKey: 'your-api-key'),
  );
  final _pinController = TextEditingController();
  PinVerificationResult? _result;
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _client.close();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _verifyPin() async {
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });

    try {
      final result = await _client.verifyPin(_pinController.text);
      setState(() {
        _result = result;
        _loading = false;
      });
    } on KraException catch (e) {
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _pinController,
          decoration: InputDecoration(
            labelText: 'KRA PIN',
            hintText: 'P051234567A',
          ),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _verifyPin,
          child: _loading
              ? CircularProgressIndicator()
              : Text('Verify PIN'),
        ),
        if (_result != null)
          Card(
            child: ListTile(
              title: Text(_result!.taxpayerName ?? 'Unknown'),
              subtitle: Text('Status: ${_result!.status}'),
              leading: Icon(
                _result!.isValid ? Icons.check_circle : Icons.error,
                color: _result!.isValid ? Colors.green : Colors.red,
              ),
            ),
          ),
        if (_error != null)
          Text(_error!, style: TextStyle(color: Colors.red)),
      ],
    );
  }
}
```

### Future/FutureBuilder Pattern

```dart
class TaxpayerDetailsScreen extends StatelessWidget {
  final String pin;
  final KraClient client;

  const TaxpayerDetailsScreen({
    required this.pin,
    required this.client,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TaxpayerDetails>(
      future: client.getTaxpayerDetails(pin),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final details = snapshot.data!;
        return ListView(
          children: [
            ListTile(
              title: Text('Name'),
              subtitle: Text(details.displayName),
            ),
            ListTile(
              title: Text('Type'),
              subtitle: Text(details.taxpayerType ?? 'Unknown'),
            ),
            ListTile(
              title: Text('Status'),
              subtitle: Text(details.status ?? 'Unknown'),
            ),
            // ... more details
          ],
        );
      },
    );
  }
}
```

### Stream Pattern (for real-time updates)

```dart
class BatchVerificationService {
  final KraClient _client;
  final _resultsController = StreamController<PinVerificationResult>();

  Stream<PinVerificationResult> get resultsStream => _resultsController.stream;

  BatchVerificationService(this._client);

  Future<void> verifyPins(List<String> pins) async {
    for (final pin in pins) {
      try {
        final result = await _client.verifyPin(pin);
        _resultsController.add(result);
      } catch (e) {
        // Handle error
      }
    }
  }

  void dispose() {
    _resultsController.close();
    _client.close();
  }
}
```

## API Reference

### KraClient

Main client class for interacting with KRA API.

```dart
class KraClient {
  KraClient({
    required KraConfig config,
  });

  Future<PinVerificationResult> verifyPin(String pin);
  Future<TccVerificationResult> verifyTcc(String tcc);
  Future<EslipValidationResult> validateEslip(String eslipNumber);
  Future<NilReturnResult> fileNilReturn(NilReturnRequest request);
  Future<TaxpayerDetails> getTaxpayerDetails(String pin);

  Future<List<PinVerificationResult>> verifyPinBatch(List<String> pins);
  Future<List<TccVerificationResult>> verifyTccBatch(List<String> tccs);
  Future<List<EslipValidationResult>> validateEslipBatch(List<String> eslips);

  void clearCache();
  void removeCacheEntry(String key);
  Map<String, dynamic> getCacheStats();
  Map<String, dynamic> getRateLimiterStats();
  void resetRateLimiter();
  Map<String, dynamic> getStats();
  void close();
}
```

### Configuration Options

```dart
class KraConfig {
  final String apiKey;
  final String baseUrl;
  final Duration timeout;

  final int maxRetries;
  final Duration retryDelay;
  final Duration maxRetryDelay;
  final List<int> retryStatusCodes;

  final bool enableRateLimit;
  final int maxRequestsPerSecond;

  final bool enableCache;
  final Duration cacheTtl;
  final int maxCacheSize;

  final bool enableDebugLogging;
  final Map<String, String>? customHeaders;
  final String userAgent;
}
```

## Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/kra_client_test.dart
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

## License

MIT License - see [LICENSE](LICENSE) for details.

## Support

- Issues: https://github.com/kra-connect/flutter-sdk/issues
- Documentation: https://pub.dev/packages/kra_connect
- Examples: [example/](example/)

## Related SDKs

- [Python SDK](https://github.com/kra-connect/python-sdk)
- [Node.js SDK](https://github.com/kra-connect/node-sdk)
- [PHP SDK](https://github.com/kra-connect/php-sdk)
- [Go SDK](https://github.com/kra-connect/go-sdk)

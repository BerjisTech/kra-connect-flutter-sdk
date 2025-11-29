import 'package:kra_connect/kra_connect.dart';

/// Example demonstrating batch operations for processing multiple requests.
void main() async {
  final client = KraClient(
    config: KraConfig(
      apiKey: 'your-api-key-here',
      maxRequestsPerSecond: 10,
      enableCache: true,
    ),
  );

  try {
    // Example 1: Batch PIN Verification
    print('=== Batch PIN Verification ===');
    final pins = [
      'P051234567A',
      'P059876543B',
      'P051111111C',
      'P052222222D',
      'P053333333E',
    ];

    print('Verifying ${pins.length} PINs...\n');

    final pinResults = await client.verifyPinBatch(pins);

    print('Results:');
    for (final result in pinResults) {
      final status = result.isValid ? '✓' : '✗';
      print('$status ${result.pinNumber}: ${result.taxpayerName ?? "Invalid"}');

      if (result.isValid) {
        print('   Type: ${result.taxpayerType}');
        print('   Status: ${result.status}');
      }
    }

    // Summary statistics
    final validCount = pinResults.where((r) => r.isValid).length;
    final invalidCount = pinResults.length - validCount;

    print('\nSummary:');
    print('  Total: ${pinResults.length}');
    print('  Valid: $validCount');
    print('  Invalid: $invalidCount');
    print('  Success Rate: ${(validCount / pinResults.length * 100).toStringAsFixed(1)}%');

    print('');

    // Example 2: Batch TCC Verification
    print('=== Batch TCC Verification ===');
    final tccs = [
      'TCC123456',
      'TCC789012',
      'TCC345678',
    ];

    print('Verifying ${tccs.length} TCCs...\n');

    final tccResults = await client.verifyTccBatch(tccs);

    print('Results:');
    for (final result in tccResults) {
      final status = result.isValid ? '✓' : '✗';
      print('$status ${result.tccNumber}');

      if (result.isValid) {
        print('   PIN: ${result.pinNumber}');
        print('   Taxpayer: ${result.taxpayerName}');
        print('   Expires: ${result.expiryDate}');

        if (result.isExpired) {
          print('   ⚠ EXPIRED');
        } else if (result.isExpiringSoon(30)) {
          print('   ⚠ Expires in ${result.daysUntilExpiry} days');
        }
      }
    }

    // Check for expiring TCCs
    final expiringTccs = tccResults.where((r) => r.isValid && r.isExpiringSoon(30)).toList();

    if (expiringTccs.isNotEmpty) {
      print('\n⚠ Warning: ${expiringTccs.length} TCC(s) expiring soon:');
      for (final tcc in expiringTccs) {
        print('  ${tcc.tccNumber} - ${tcc.daysUntilExpiry} days remaining');
      }
    }

    print('');

    // Example 3: Batch E-slip Validation
    print('=== Batch E-slip Validation ===');
    final eslips = [
      'ABC1234567890',
      'DEF0987654321',
      'GHI1122334455',
    ];

    print('Validating ${eslips.length} e-slips...\n');

    final eslipResults = await client.validateEslipBatch(eslips);

    double totalAmount = 0.0;
    int paidCount = 0;

    print('Results:');
    for (final result in eslipResults) {
      final status = result.isValid ? '✓' : '✗';
      print('$status ${result.eslipNumber}');

      if (result.isValid) {
        print('   Taxpayer: ${result.taxpayerName}');
        print('   Amount: ${result.amount} ${result.currency}');
        print('   Status: ${result.status}');

        if (result.isPaid) {
          print('   ✓ PAID');
          totalAmount += result.amount ?? 0.0;
          paidCount++;
        } else if (result.isPending) {
          print('   ⏳ PENDING');
        }
      }
    }

    print('\nPayment Summary:');
    print('  Total E-slips: ${eslipResults.length}');
    print('  Paid: $paidCount');
    print('  Total Amount: KSh ${totalAmount.toStringAsFixed(2)}');

    print('');

    // Example 4: Parallel Processing with Error Handling
    print('=== Parallel Processing with Error Handling ===');

    final mixedPins = [
      'P051234567A', // Valid format
      'INVALID_PIN', // Invalid format
      'P059876543B', // Valid format
      'P052222222D', // Valid format
    ];

    final results = <String, dynamic>{};

    for (final pin in mixedPins) {
      try {
        final result = await client.verifyPin(pin);
        results[pin] = {'success': true, 'result': result};
      } on ValidationException catch (e) {
        results[pin] = {'success': false, 'error': 'Validation error: ${e.message}'};
      } catch (e) {
        results[pin] = {'success': false, 'error': 'Unexpected error: $e'};
      }
    }

    print('Processing Results:');
    for (final entry in results.entries) {
      if (entry.value['success']) {
        final result = entry.value['result'] as PinVerificationResult;
        print('✓ ${entry.key}: ${result.taxpayerName}');
      } else {
        print('✗ ${entry.key}: ${entry.value['error']}');
      }
    }

    final successCount = results.values.where((v) => v['success']).length;
    print('\nProcessed: ${results.length} requests');
    print('Successful: $successCount');
    print('Failed: ${results.length - successCount}');

    print('');

    // Example 5: Supplier Verification Workflow
    print('=== Supplier Verification Workflow ===');

    final suppliers = [
      {'name': 'Supplier A', 'pin': 'P051234567A', 'tcc': 'TCC123456'},
      {'name': 'Supplier B', 'pin': 'P059876543B', 'tcc': 'TCC789012'},
      {'name': 'Supplier C', 'pin': 'P051111111C', 'tcc': 'TCC345678'},
    ];

    final verifiedSuppliers = <Map<String, dynamic>>[];
    final failedSuppliers = <Map<String, dynamic>>[];

    for (final supplier in suppliers) {
      print('\nVerifying ${supplier['name']}...');

      try {
        // Verify PIN
        final pinResult = await client.verifyPin(supplier['pin'] as String);

        if (!pinResult.isValid) {
          print('  ✗ Invalid PIN');
          failedSuppliers.add({
            ...supplier,
            'reason': 'Invalid PIN',
          });
          continue;
        }

        print('  ✓ PIN valid: ${pinResult.taxpayerName}');

        // Verify TCC
        final tccResult = await client.verifyTcc(supplier['tcc'] as String);

        if (!tccResult.isValid) {
          print('  ✗ Invalid TCC');
          failedSuppliers.add({
            ...supplier,
            'reason': 'Invalid TCC',
          });
          continue;
        }

        if (tccResult.isExpired) {
          print('  ✗ TCC expired');
          failedSuppliers.add({
            ...supplier,
            'reason': 'TCC expired',
          });
          continue;
        }

        print('  ✓ TCC valid (expires: ${tccResult.expiryDate})');

        // All checks passed
        verifiedSuppliers.add({
          ...supplier,
          'pin_result': pinResult,
          'tcc_result': tccResult,
        });

        print('  ✓✓ FULLY VERIFIED');
      } catch (e) {
        print('  ✗ Error: $e');
        failedSuppliers.add({
          ...supplier,
          'reason': 'Error during verification',
        });
      }
    }

    print('\n=== Verification Summary ===');
    print('Total Suppliers: ${suppliers.length}');
    print('Verified: ${verifiedSuppliers.length}');
    print('Failed: ${failedSuppliers.length}');

    if (verifiedSuppliers.isNotEmpty) {
      print('\nVerified Suppliers:');
      for (final supplier in verifiedSuppliers) {
        print('  ✓ ${supplier['name']} (${supplier['pin']})');
      }
    }

    if (failedSuppliers.isNotEmpty) {
      print('\nFailed Suppliers:');
      for (final supplier in failedSuppliers) {
        print('  ✗ ${supplier['name']}: ${supplier['reason']}');
      }
    }
  } catch (e) {
    print('❌ Error: $e');
  } finally {
    client.close();
    print('\n✓ Client closed');
  }
}

import 'package:kra_connect/kra_connect.dart';

/// Basic example demonstrating core KRA Connect SDK functionality.
void main() async {
  // Create a client with your API key
  final client = KraClient(
    config: KraConfig(
      apiKey: 'your-api-key-here',
      timeout: const Duration(seconds: 30),
      enableCache: true,
      enableRateLimit: true,
      maxRetries: 3,
    ),
  );

  try {
    // Example 1: Verify a single PIN
    print('=== Example 1: PIN Verification ===');
    final pinResult = await client.verifyPin('P051234567A');

    if (pinResult.isValid) {
      print('✓ PIN is valid');
      print('  Taxpayer Name: ${pinResult.taxpayerName}');
      print('  Taxpayer Type: ${pinResult.taxpayerType}');
      print('  Status: ${pinResult.status}');
      print('  Is Active: ${pinResult.isActive}');

      if (pinResult.isCompany) {
        print('  Type: Company');
      } else if (pinResult.isIndividual) {
        print('  Type: Individual');
      }
    } else {
      print('✗ PIN is invalid');
    }

    print('');

    // Example 2: Verify a TCC
    print('=== Example 2: TCC Verification ===');
    final tccResult = await client.verifyTcc('TCC123456');

    if (tccResult.isValid) {
      print('✓ TCC is valid');
      print('  TCC Number: ${tccResult.tccNumber}');
      print('  PIN: ${tccResult.pinNumber}');
      print('  Taxpayer: ${tccResult.taxpayerName}');
      print('  Issue Date: ${tccResult.issueDate}');
      print('  Expiry Date: ${tccResult.expiryDate}');

      if (tccResult.isExpired) {
        print('  ⚠ Warning: TCC has expired');
      } else {
        final daysLeft = tccResult.daysUntilExpiry;
        print('  Days until expiry: $daysLeft');

        if (tccResult.isExpiringSoon(30)) {
          print('  ⚠ Warning: TCC expires in less than 30 days');
        }
      }
    } else {
      print('✗ TCC is invalid');
    }

    print('');

    // Example 3: Validate an e-slip
    print('=== Example 3: E-slip Validation ===');
    final eslipResult = await client.validateEslip('ABC1234567890');

    if (eslipResult.isValid) {
      print('✓ E-slip is valid');
      print('  E-slip Number: ${eslipResult.eslipNumber}');
      print('  Taxpayer: ${eslipResult.taxpayerName}');
      print('  Amount: ${eslipResult.amount} ${eslipResult.currency}');
      print('  Payment Date: ${eslipResult.paymentDate}');
      print('  Status: ${eslipResult.status}');

      if (eslipResult.isPaid) {
        print('  ✓ Payment confirmed');
      } else if (eslipResult.isPending) {
        print('  ⏳ Payment pending');
      } else if (eslipResult.isCancelled) {
        print('  ✗ Payment cancelled');
      }
    } else {
      print('✗ E-slip is invalid');
    }

    print('');

    // Example 4: File a NIL return
    print('=== Example 4: File NIL Return ===');
    final nilReturnRequest = NilReturnRequest(
      pinNumber: 'P051234567A',
      obligationType: 'VAT',
      taxPeriod: '2024-01',
      reason: 'No business activity during this period',
      declaration: true,
    );

    // Validate request before submission
    if (nilReturnRequest.isValid()) {
      final nilReturnResult = await client.fileNilReturn(nilReturnRequest);

      if (nilReturnResult.isAccepted) {
        print('✓ NIL return accepted');
        print('  Reference Number: ${nilReturnResult.referenceNumber}');
        print('  Acknowledgement: ${nilReturnResult.acknowledgementNumber}');
        print('  Status: ${nilReturnResult.status}');
      } else if (nilReturnResult.isRejected) {
        print('✗ NIL return rejected');
        if (nilReturnResult.hasRejectionReasons) {
          print('  Rejection reasons:');
          for (final reason in nilReturnResult.rejectionReasons!) {
            print('    - $reason');
          }
        }
      }
    } else {
      print('✗ Invalid NIL return request');
    }

    print('');

    // Example 5: Get taxpayer details
    print('=== Example 5: Taxpayer Details ===');
    final details = await client.getTaxpayerDetails('P051234567A');

    print('Taxpayer Information:');
    print('  PIN: ${details.pinNumber}');
    print('  Name: ${details.getDisplayName()}');
    print('  Type: ${details.taxpayerType}');
    print('  Active: ${details.isActive}');
    print('  Compliant: ${details.isCompliant}');

    if (details.hasContactInfo) {
      print('  Email: ${details.email ?? "N/A"}');
      print('  Phone: ${details.phoneNumber ?? "N/A"}');
    }

    if (details.hasObligations) {
      print('  Obligations: ${details.obligationCount}');
      for (final obligation in details.obligations!) {
        print('    - ${obligation.obligationType}: ${obligation.status}');
        if (obligation.isOverdue) {
          print('      ⚠ OVERDUE');
        }
      }
    }

    print('');

    // Example 6: Cache statistics
    print('=== Example 6: Cache Statistics ===');
    final cacheStats = client.getCacheStats();
    print('Cache Stats:');
    print('  Size: ${cacheStats["size"]}');
    print('  Max Size: ${cacheStats["max_size"]}');
    print('  Utilization: ${cacheStats["utilization"]}%');
    print('  Valid Entries: ${cacheStats["valid_entries"]}');

    print('');

    // Example 7: Rate limiter statistics
    print('=== Example 7: Rate Limiter Statistics ===');
    final rateLimiterStats = client.getRateLimiterStats();
    print('Rate Limiter Stats:');
    print('  Enabled: ${rateLimiterStats["enabled"]}');
    print('  Max Requests/sec: ${rateLimiterStats["max_requests_per_second"]}');
    print('  Available Tokens: ${rateLimiterStats["available_tokens"]}');
    print('  Has Token: ${rateLimiterStats["has_available_token"]}');
  } on ValidationException catch (e) {
    print('❌ Validation Error: ${e.message}');
    print('   Field: ${e.field}');
  } on AuthenticationException catch (e) {
    print('❌ Authentication Error: ${e.message}');
    print('   Status Code: ${e.statusCode}');
  } on RateLimitException catch (e) {
    print('❌ Rate Limit Exceeded: ${e.message}');
    print('   Retry After: ${e.retryAfter.inSeconds}s');
  } on TimeoutException catch (e) {
    print('❌ Timeout Error: ${e.message}');
    print('   Endpoint: ${e.endpoint}');
    print('   Attempt: ${e.attemptNumber}');
  } on ApiException catch (e) {
    print('❌ API Error: ${e.message}');
    print('   Status Code: ${e.statusCode}');
    print('   Endpoint: ${e.endpoint}');
  } on NetworkException catch (e) {
    print('❌ Network Error: ${e.message}');
    print('   Endpoint: ${e.endpoint}');
  } on KraException catch (e) {
    print('❌ KRA Error: ${e.message}');
  } catch (e) {
    print('❌ Unexpected Error: $e');
  } finally {
    // Always close the client when done
    client.close();
    print('\n✓ Client closed');
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:kra_connect/kra_connect.dart';

void main() {
  group('Validators - PIN', () {
    test('should accept valid PIN format', () {
      expect(() => Validators.validatePin('P051234567A'), returnsNormally);
      expect(() => Validators.validatePin('P999999999Z'), returnsNormally);
    });

    test('should reject invalid PIN format', () {
      expect(
        () => Validators.validatePin(''),
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => Validators.validatePin('P12345678'), // Too short
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => Validators.validatePin('12345678901'), // Missing P
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => Validators.validatePin('P05123456712'), // Too long
        throwsA(isA<ValidationException>()),
      );
    });

    test('isValidPin should return boolean', () {
      expect(Validators.isValidPin('P051234567A'), true);
      expect(Validators.isValidPin('INVALID'), false);
      expect(Validators.isValidPin(''), false);
    });
  });

  group('Validators - TCC', () {
    test('should accept valid TCC format', () {
      expect(() => Validators.validateTcc('TCC123456'), returnsNormally);
      expect(() => Validators.validateTcc('TCC1234567890'), returnsNormally);
    });

    test('should reject invalid TCC format', () {
      expect(
        () => Validators.validateTcc(''),
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => Validators.validateTcc('123456'), // Missing TCC prefix
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => Validators.validateTcc('TCC12345'), // Too short
        throwsA(isA<ValidationException>()),
      );
    });

    test('isValidTcc should return boolean', () {
      expect(Validators.isValidTcc('TCC123456'), true);
      expect(Validators.isValidTcc('INVALID'), false);
    });
  });

  group('Validators - E-slip', () {
    test('should accept valid e-slip format', () {
      expect(() => Validators.validateEslip('ABC1234567'), returnsNormally);
      expect(() => Validators.validateEslip('XYZ12345678901234567'), returnsNormally);
    });

    test('should reject invalid e-slip format', () {
      expect(
        () => Validators.validateEslip(''),
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => Validators.validateEslip('ABC123'), // Too short
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => Validators.validateEslip('ABC123456789012345678901'), // Too long
        throwsA(isA<ValidationException>()),
      );
    });

    test('isValidEslip should return boolean', () {
      expect(Validators.isValidEslip('ABC1234567890'), true);
      expect(Validators.isValidEslip('ABC'), false);
    });
  });

  group('Validators - Tax Period', () {
    test('should accept valid tax period format', () {
      expect(() => Validators.validateTaxPeriod('2024-01'), returnsNormally);
      expect(() => Validators.validateTaxPeriod('2024-12'), returnsNormally);
    });

    test('should reject invalid tax period format', () {
      expect(
        () => Validators.validateTaxPeriod(''),
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => Validators.validateTaxPeriod('2024-13'), // Invalid month
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => Validators.validateTaxPeriod('2024-00'), // Invalid month
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => Validators.validateTaxPeriod('1999-01'), // Year too old
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => Validators.validateTaxPeriod('2024/01'), // Wrong separator
        throwsA(isA<ValidationException>()),
      );
    });

    test('isValidTaxPeriod should return boolean', () {
      expect(Validators.isValidTaxPeriod('2024-01'), true);
      expect(Validators.isValidTaxPeriod('2024-13'), false);
    });
  });

  group('Validators - Date', () {
    test('should accept valid date format', () {
      expect(() => Validators.validateDate('2024-01-15'), returnsNormally);
      expect(() => Validators.validateDate('2024-12-31'), returnsNormally);
    });

    test('should reject invalid date format', () {
      expect(
        () => Validators.validateDate(''),
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => Validators.validateDate('2024-13-01'), // Invalid month
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => Validators.validateDate('2024-02-30'), // Invalid day
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => Validators.validateDate('2024/01/15'), // Wrong separator
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('Validators - Email', () {
    test('should accept valid email format', () {
      expect(() => Validators.validateEmail('user@example.com'), returnsNormally);
      expect(() => Validators.validateEmail('test.user@domain.co.ke'), returnsNormally);
    });

    test('should reject invalid email format', () {
      expect(
        () => Validators.validateEmail(''),
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => Validators.validateEmail('invalid-email'),
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => Validators.validateEmail('@example.com'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('isValidEmail should return boolean', () {
      expect(Validators.isValidEmail('user@example.com'), true);
      expect(Validators.isValidEmail('invalid'), false);
    });
  });

  group('Validators - Phone', () {
    test('should accept valid Kenyan phone formats', () {
      expect(() => Validators.validatePhone('+254712345678'), returnsNormally);
      expect(() => Validators.validatePhone('0712345678'), returnsNormally);
      expect(() => Validators.validatePhone('+254112345678'), returnsNormally);
      expect(() => Validators.validatePhone('0112345678'), returnsNormally);
    });

    test('should reject invalid phone formats', () {
      expect(
        () => Validators.validatePhone(''),
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => Validators.validatePhone('12345'), // Too short
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => Validators.validatePhone('+254212345678'), // Wrong prefix
        throwsA(isA<ValidationException>()),
      );
    });

    test('isValidPhone should return boolean', () {
      expect(Validators.isValidPhone('+254712345678'), true);
      expect(Validators.isValidPhone('12345'), false);
    });
  });

  group('Validators - API Key', () {
    test('should accept valid API key', () {
      expect(() => Validators.validateApiKey('my-api-key-12345'), returnsNormally);
    });

    test('should reject invalid API key', () {
      expect(
        () => Validators.validateApiKey(''),
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => Validators.validateApiKey('short'), // Too short
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('Validators - Amount', () {
    test('should accept valid amounts', () {
      expect(() => Validators.validateAmount(0.0), returnsNormally);
      expect(() => Validators.validateAmount(100.50), returnsNormally);
      expect(() => Validators.validateAmount(999999.99), returnsNormally);
    });

    test('should reject invalid amounts', () {
      expect(
        () => Validators.validateAmount(-10.0), // Negative
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => Validators.validateAmount(1000000000.0), // Too large
        throwsA(isA<ValidationException>()),
      );
    });
  });
}

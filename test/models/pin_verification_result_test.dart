import 'package:flutter_test/flutter_test.dart';
import 'package:kra_connect/kra_connect.dart';

void main() {
  group('PinVerificationResult', () {
    test('should create from valid JSON', () {
      final json = {
        'pin_number': 'P051234567A',
        'is_valid': true,
        'taxpayer_name': 'John Doe',
        'taxpayer_type': 'individual',
        'status': 'active',
        'registration_date': '2020-01-15',
        'tax_office': 'Nairobi',
        'business_activity': 'IT Services',
        'additional_data': {'key': 'value'},
        'verified_at': '2024-01-15T10:00:00Z',
      };

      final result = PinVerificationResult.fromJson(json);

      expect(result.pinNumber, 'P051234567A');
      expect(result.isValid, true);
      expect(result.taxpayerName, 'John Doe');
      expect(result.taxpayerType, 'individual');
      expect(result.status, 'active');
      expect(result.registrationDate, '2020-01-15');
      expect(result.taxOffice, 'Nairobi');
      expect(result.businessActivity, 'IT Services');
      expect(result.additionalData, {'key': 'value'});
      expect(result.verifiedAt, isA<DateTime>());
    });

    test('should handle null optional fields', () {
      final json = {
        'pin_number': 'P051234567A',
        'is_valid': false,
        'verified_at': '2024-01-15T10:00:00Z',
      };

      final result = PinVerificationResult.fromJson(json);

      expect(result.pinNumber, 'P051234567A');
      expect(result.isValid, false);
      expect(result.taxpayerName, null);
      expect(result.taxpayerType, null);
      expect(result.status, null);
    });

    test('isActive should return true for valid and active PIN', () {
      final result = PinVerificationResult(
        pinNumber: 'P051234567A',
        isValid: true,
        status: 'active',
        verifiedAt: DateTime.now(),
      );

      expect(result.isActive, true);
    });

    test('isActive should return false for invalid PIN', () {
      final result = PinVerificationResult(
        pinNumber: 'P051234567A',
        isValid: false,
        status: 'active',
        verifiedAt: DateTime.now(),
      );

      expect(result.isActive, false);
    });

    test('isCompany should return true for company taxpayer type', () {
      final result = PinVerificationResult(
        pinNumber: 'P051234567A',
        isValid: true,
        taxpayerType: 'company',
        verifiedAt: DateTime.now(),
      );

      expect(result.isCompany, true);
      expect(result.isIndividual, false);
    });

    test('isIndividual should return true for individual taxpayer type', () {
      final result = PinVerificationResult(
        pinNumber: 'P051234567A',
        isValid: true,
        taxpayerType: 'individual',
        verifiedAt: DateTime.now(),
      );

      expect(result.isIndividual, true);
      expect(result.isCompany, false);
    });

    test('toJson should serialize correctly', () {
      final result = PinVerificationResult(
        pinNumber: 'P051234567A',
        isValid: true,
        taxpayerName: 'John Doe',
        taxpayerType: 'individual',
        status: 'active',
        verifiedAt: DateTime.parse('2024-01-15T10:00:00Z'),
      );

      final json = result.toJson();

      expect(json['pin_number'], 'P051234567A');
      expect(json['is_valid'], true);
      expect(json['taxpayer_name'], 'John Doe');
      expect(json['taxpayer_type'], 'individual');
      expect(json['status'], 'active');
      expect(json['verified_at'], '2024-01-15T10:00:00.000Z');
    });

    test('toJson should omit null fields', () {
      final result = PinVerificationResult(
        pinNumber: 'P051234567A',
        isValid: false,
        verifiedAt: DateTime.parse('2024-01-15T10:00:00Z'),
      );

      final json = result.toJson();

      expect(json.containsKey('taxpayer_name'), false);
      expect(json.containsKey('taxpayer_type'), false);
      expect(json.containsKey('status'), false);
    });

    test('toString should return formatted string', () {
      final result = PinVerificationResult(
        pinNumber: 'P051234567A',
        isValid: true,
        taxpayerName: 'John Doe',
        status: 'active',
        verifiedAt: DateTime.now(),
      );

      final str = result.toString();

      expect(str, contains('P051234567A'));
      expect(str, contains('true'));
      expect(str, contains('John Doe'));
      expect(str, contains('active'));
    });
  });
}

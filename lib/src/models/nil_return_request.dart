import 'package:meta/meta.dart';

/// Request object for filing a NIL return.
///
/// Example:
/// ```dart
/// final request = NilReturnRequest(
///   pinNumber: 'P051234567A',
///   obligationCode: 1,
///   month: 1,
///   year: 2024,
/// );
/// ```
@immutable
class NilReturnRequest {
  /// Taxpayer PIN
  final String pinNumber;

  /// Obligation code as defined by KRA
  final int obligationCode;

  /// Tax period month (1-12)
  final int month;

  /// Tax period year
  final int year;

  const NilReturnRequest({
    required this.pinNumber,
    required this.obligationCode,
    required this.month,
    required this.year,
  });

  /// Returns the tax period in YYYYMM format
  String get period => '$year${month.toString().padLeft(2, '0')}';

  /// Validates the request before submission
  bool isValid() {
    if (pinNumber.isEmpty) return false;
    if (obligationCode <= 0) return false;
    if (month < 1 || month > 12) return false;
    if (year < 2000) return false;
    return true;
  }

  /// Creates a [NilReturnRequest] from JSON
  factory NilReturnRequest.fromJson(Map<String, dynamic> json) {
    return NilReturnRequest(
      pinNumber: json['pin_number'] as String? ?? json['pinNumber'] as String,
      obligationCode: json['obligation_code'] as int? ?? json['obligationCode'] as int,
      month: json['month'] as int,
      year: json['year'] as int,
    );
  }

  /// Converts this [NilReturnRequest] to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'TAXPAYERDETAILS': {
        'TaxpayerPIN': pinNumber.trim().toUpperCase(),
        'ObligationCode': obligationCode,
        'Month': month,
        'Year': year,
      },
    };
  }

  /// Creates a copy with optional field overrides
  NilReturnRequest copyWith({
    String? pinNumber,
    int? obligationCode,
    int? month,
    int? year,
  }) {
    return NilReturnRequest(
      pinNumber: pinNumber ?? this.pinNumber,
      obligationCode: obligationCode ?? this.obligationCode,
      month: month ?? this.month,
      year: year ?? this.year,
    );
  }

  @override
  String toString() => 'NilReturnRequest('
      'pinNumber: $pinNumber, '
      'obligationCode: $obligationCode, '
      'month: $month, '
      'year: $year)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NilReturnRequest &&
          runtimeType == other.runtimeType &&
          pinNumber == other.pinNumber &&
          obligationCode == other.obligationCode &&
          month == other.month &&
          year == other.year;

  @override
  int get hashCode =>
      pinNumber.hashCode ^
      obligationCode.hashCode ^
      month.hashCode ^
      year.hashCode;
}

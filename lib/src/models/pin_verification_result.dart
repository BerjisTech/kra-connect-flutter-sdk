import 'package:meta/meta.dart';

/// Result of a PIN verification request.
///
/// Contains information about the taxpayer associated with the PIN.
@immutable
class PinVerificationResult {
  /// The verified PIN number
  final String pinNumber;

  /// Whether the PIN is valid
  final bool isValid;

  /// Taxpayer name (if available)
  final String? taxpayerName;

  /// Taxpayer status (e.g., "active", "inactive")
  final String? status;

  /// Taxpayer type (e.g., "individual", "company")
  final String? taxpayerType;

  /// Registration date (YYYY-MM-DD format)
  final String? registrationDate;

  /// Additional data from the API
  final Map<String, dynamic>? additionalData;

  /// Timestamp when verification was performed
  final DateTime verifiedAt;

  const PinVerificationResult({
    required this.pinNumber,
    required this.isValid,
    this.taxpayerName,
    this.status,
    this.taxpayerType,
    this.registrationDate,
    this.additionalData,
    required this.verifiedAt,
  });

  /// Returns true if the PIN is valid and active
  bool get isActive => isValid && status == 'active';

  /// Returns true if the taxpayer is a company
  bool get isCompany => taxpayerType == 'company';

  /// Returns true if the taxpayer is an individual
  bool get isIndividual => taxpayerType == 'individual';

  /// Creates a [PinVerificationResult] from JSON
  factory PinVerificationResult.fromJson(Map<String, dynamic> json) {
    return PinVerificationResult(
      pinNumber: json['pin_number'] as String,
      isValid: json['is_valid'] as bool,
      taxpayerName: json['taxpayer_name'] as String?,
      status: json['status'] as String?,
      taxpayerType: json['taxpayer_type'] as String?,
      registrationDate: json['registration_date'] as String?,
      additionalData: json['additional_data'] as Map<String, dynamic>?,
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : DateTime.now(),
    );
  }

  /// Converts this [PinVerificationResult] to JSON
  Map<String, dynamic> toJson() {
    return {
      'pin_number': pinNumber,
      'is_valid': isValid,
      if (taxpayerName != null) 'taxpayer_name': taxpayerName,
      if (status != null) 'status': status,
      if (taxpayerType != null) 'taxpayer_type': taxpayerType,
      if (registrationDate != null) 'registration_date': registrationDate,
      if (additionalData != null) 'additional_data': additionalData,
      'verified_at': verifiedAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'PinVerificationResult('
      'pinNumber: $pinNumber, '
      'isValid: $isValid, '
      'taxpayerName: $taxpayerName, '
      'status: $status)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PinVerificationResult &&
          runtimeType == other.runtimeType &&
          pinNumber == other.pinNumber &&
          isValid == other.isValid &&
          taxpayerName == other.taxpayerName &&
          status == other.status;

  @override
  int get hashCode =>
      pinNumber.hashCode ^
      isValid.hashCode ^
      taxpayerName.hashCode ^
      status.hashCode;
}

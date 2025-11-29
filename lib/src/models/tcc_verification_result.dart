import 'package:meta/meta.dart';

/// Result of a TCC (Tax Compliance Certificate) verification request.
@immutable
class TccVerificationResult {
  /// The verified TCC number
  final String tccNumber;

  /// Whether the TCC is valid
  final bool isValid;

  /// Taxpayer name
  final String? taxpayerName;

  /// Associated PIN number
  final String? pinNumber;

  /// Issue date (YYYY-MM-DD format)
  final String? issueDate;

  /// Expiry date (YYYY-MM-DD format)
  final String? expiryDate;

  /// Whether the TCC has expired
  final bool isExpired;

  /// TCC status (e.g., "active", "expired")
  final String? status;

  /// Certificate type
  final String? certificateType;

  /// Additional data from the API
  final Map<String, dynamic>? additionalData;

  /// Timestamp when verification was performed
  final DateTime verifiedAt;

  const TccVerificationResult({
    required this.tccNumber,
    required this.isValid,
    this.taxpayerName,
    this.pinNumber,
    this.issueDate,
    this.expiryDate,
    required this.isExpired,
    this.status,
    this.certificateType,
    this.additionalData,
    required this.verifiedAt,
  });

  /// Returns true if the TCC is valid and not expired
  bool get isCurrentlyValid => isValid && !isExpired && status == 'active';

  /// Returns the number of days until expiry (negative if expired)
  int get daysUntilExpiry {
    if (expiryDate == null) return 0;
    try {
      final expiry = DateTime.parse(expiryDate!);
      return expiry.difference(DateTime.now()).inDays;
    } catch (_) {
      return 0;
    }
  }

  /// Returns true if the TCC expires within the specified number of days
  bool isExpiringSoon(int days) {
    final daysLeft = daysUntilExpiry;
    return daysLeft >= 0 && daysLeft <= days;
  }

  /// Creates a [TccVerificationResult] from JSON
  factory TccVerificationResult.fromJson(Map<String, dynamic> json) {
    return TccVerificationResult(
      tccNumber: json['tcc_number'] as String,
      isValid: json['is_valid'] as bool,
      taxpayerName: json['taxpayer_name'] as String?,
      pinNumber: json['pin_number'] as String?,
      issueDate: json['issue_date'] as String?,
      expiryDate: json['expiry_date'] as String?,
      isExpired: json['is_expired'] as bool? ?? false,
      status: json['status'] as String?,
      certificateType: json['certificate_type'] as String?,
      additionalData: json['additional_data'] as Map<String, dynamic>?,
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : DateTime.now(),
    );
  }

  /// Converts this [TccVerificationResult] to JSON
  Map<String, dynamic> toJson() {
    return {
      'tcc_number': tccNumber,
      'is_valid': isValid,
      if (taxpayerName != null) 'taxpayer_name': taxpayerName,
      if (pinNumber != null) 'pin_number': pinNumber,
      if (issueDate != null) 'issue_date': issueDate,
      if (expiryDate != null) 'expiry_date': expiryDate,
      'is_expired': isExpired,
      if (status != null) 'status': status,
      if (certificateType != null) 'certificate_type': certificateType,
      if (additionalData != null) 'additional_data': additionalData,
      'verified_at': verifiedAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'TccVerificationResult('
      'tccNumber: $tccNumber, '
      'isValid: $isValid, '
      'isExpired: $isExpired, '
      'expiryDate: $expiryDate)';
}

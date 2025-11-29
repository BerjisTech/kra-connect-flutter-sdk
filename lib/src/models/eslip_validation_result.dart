import 'package:meta/meta.dart';

/// Result of an e-slip validation request.
@immutable
class EslipValidationResult {
  /// The validated e-slip number
  final String eslipNumber;

  /// Whether the e-slip is valid
  final bool isValid;

  /// Taxpayer PIN
  final String? taxpayerPin;

  /// Taxpayer name
  final String? taxpayerName;

  /// Payment amount
  final double? amount;

  /// Payment currency
  final String? currency;

  /// Payment date (YYYY-MM-DD format)
  final String? paymentDate;

  /// Payment reference number
  final String? paymentReference;

  /// Obligation type
  final String? obligationType;

  /// Obligation period
  final String? obligationPeriod;

  /// Payment status (e.g., "paid", "pending", "cancelled")
  final String? status;

  /// Additional data from the API
  final Map<String, dynamic>? additionalData;

  /// Timestamp when validation was performed
  final DateTime validatedAt;

  const EslipValidationResult({
    required this.eslipNumber,
    required this.isValid,
    this.taxpayerPin,
    this.taxpayerName,
    this.amount,
    this.currency,
    this.paymentDate,
    this.paymentReference,
    this.obligationType,
    this.obligationPeriod,
    this.status,
    this.additionalData,
    required this.validatedAt,
  });

  /// Returns true if the payment has been confirmed
  bool get isPaid => isValid && status == 'paid';

  /// Returns true if the payment is pending
  bool get isPending => isValid && status == 'pending';

  /// Returns true if the payment was cancelled
  bool get isCancelled => status == 'cancelled';

  /// Creates an [EslipValidationResult] from JSON
  factory EslipValidationResult.fromJson(Map<String, dynamic> json) {
    return EslipValidationResult(
      eslipNumber: json['eslip_number'] as String,
      isValid: json['is_valid'] as bool,
      taxpayerPin: json['taxpayer_pin'] as String?,
      taxpayerName: json['taxpayer_name'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      paymentDate: json['payment_date'] as String?,
      paymentReference: json['payment_reference'] as String?,
      obligationType: json['obligation_type'] as String?,
      obligationPeriod: json['obligation_period'] as String?,
      status: json['status'] as String?,
      additionalData: json['additional_data'] as Map<String, dynamic>?,
      validatedAt: json['validated_at'] != null
          ? DateTime.parse(json['validated_at'] as String)
          : DateTime.now(),
    );
  }

  /// Converts this [EslipValidationResult] to JSON
  Map<String, dynamic> toJson() {
    return {
      'eslip_number': eslipNumber,
      'is_valid': isValid,
      if (taxpayerPin != null) 'taxpayer_pin': taxpayerPin,
      if (taxpayerName != null) 'taxpayer_name': taxpayerName,
      if (amount != null) 'amount': amount,
      if (currency != null) 'currency': currency,
      if (paymentDate != null) 'payment_date': paymentDate,
      if (paymentReference != null) 'payment_reference': paymentReference,
      if (obligationType != null) 'obligation_type': obligationType,
      if (obligationPeriod != null) 'obligation_period': obligationPeriod,
      if (status != null) 'status': status,
      if (additionalData != null) 'additional_data': additionalData,
      'validated_at': validatedAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'EslipValidationResult('
      'eslipNumber: $eslipNumber, '
      'isValid: $isValid, '
      'status: $status, '
      'amount: $amount $currency)';
}

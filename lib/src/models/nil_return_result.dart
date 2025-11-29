import 'package:meta/meta.dart';

/// Result of a NIL return filing request.
@immutable
class NilReturnResult {
  /// The PIN number for which the NIL return was filed
  final String pinNumber;

  /// The obligation type
  final String obligationType;

  /// The tax period
  final String taxPeriod;

  /// Whether the filing was accepted
  final bool isAccepted;

  /// Filing reference number
  final String? referenceNumber;

  /// Acknowledgement receipt number
  final String? acknowledgementNumber;

  /// Filing status (e.g., 'accepted', 'rejected', 'pending')
  final String status;

  /// Timestamp when the filing was submitted
  final DateTime filedAt;

  /// Timestamp when the filing was processed
  final DateTime? processedAt;

  /// Any messages or notes from KRA
  final String? message;

  /// Rejection reasons (if rejected)
  final List<String>? rejectionReasons;

  /// Additional data from the API
  final Map<String, dynamic>? additionalData;

  const NilReturnResult({
    required this.pinNumber,
    required this.obligationType,
    required this.taxPeriod,
    required this.isAccepted,
    this.referenceNumber,
    this.acknowledgementNumber,
    required this.status,
    required this.filedAt,
    this.processedAt,
    this.message,
    this.rejectionReasons,
    this.additionalData,
  });

  /// Returns true if the filing was rejected
  bool get isRejected => !isAccepted && status == 'rejected';

  /// Returns true if the filing is pending
  bool get isPending => status == 'pending';

  /// Returns true if the filing is complete (accepted or rejected)
  bool get isComplete => isAccepted || isRejected;

  /// Returns true if rejection reasons are provided
  bool get hasRejectionReasons =>
      rejectionReasons != null && rejectionReasons!.isNotEmpty;

  /// Returns the number of rejection reasons
  int get rejectionReasonCount => rejectionReasons?.length ?? 0;

  /// Returns true if a reference number was assigned
  bool get hasReferenceNumber =>
      referenceNumber != null && referenceNumber!.isNotEmpty;

  /// Returns true if an acknowledgement number was assigned
  bool get hasAcknowledgementNumber =>
      acknowledgementNumber != null && acknowledgementNumber!.isNotEmpty;

  /// Returns processing time in seconds (if processed)
  int? get processingTimeSeconds {
    if (processedAt == null) return null;
    return processedAt!.difference(filedAt).inSeconds;
  }

  /// Creates a [NilReturnResult] from JSON
  factory NilReturnResult.fromJson(Map<String, dynamic> json) {
    return NilReturnResult(
      pinNumber: json['pin_number'] as String,
      obligationType: json['obligation_type'] as String,
      taxPeriod: json['tax_period'] as String,
      isAccepted: json['is_accepted'] as bool,
      referenceNumber: json['reference_number'] as String?,
      acknowledgementNumber: json['acknowledgement_number'] as String?,
      status: json['status'] as String,
      filedAt: json['filed_at'] != null
          ? DateTime.parse(json['filed_at'] as String)
          : DateTime.now(),
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'] as String)
          : null,
      message: json['message'] as String?,
      rejectionReasons: json['rejection_reasons'] != null
          ? List<String>.from(json['rejection_reasons'] as List)
          : null,
      additionalData: json['additional_data'] as Map<String, dynamic>?,
    );
  }

  /// Converts this [NilReturnResult] to JSON
  Map<String, dynamic> toJson() {
    return {
      'pin_number': pinNumber,
      'obligation_type': obligationType,
      'tax_period': taxPeriod,
      'is_accepted': isAccepted,
      if (referenceNumber != null) 'reference_number': referenceNumber,
      if (acknowledgementNumber != null)
        'acknowledgement_number': acknowledgementNumber,
      'status': status,
      'filed_at': filedAt.toIso8601String(),
      if (processedAt != null) 'processed_at': processedAt!.toIso8601String(),
      if (message != null) 'message': message,
      if (rejectionReasons != null) 'rejection_reasons': rejectionReasons,
      if (additionalData != null) 'additional_data': additionalData,
    };
  }

  @override
  String toString() => 'NilReturnResult('
      'pinNumber: $pinNumber, '
      'obligationType: $obligationType, '
      'taxPeriod: $taxPeriod, '
      'status: $status, '
      'isAccepted: $isAccepted)';
}

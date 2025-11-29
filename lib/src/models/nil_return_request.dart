import 'package:meta/meta.dart';

/// Request object for filing a NIL return.
@immutable
class NilReturnRequest {
  /// Taxpayer PIN
  final String pinNumber;

  /// Tax obligation type (e.g., 'VAT', 'INCOME_TAX', 'PAYE')
  final String obligationType;

  /// Tax period (YYYY-MM format)
  final String taxPeriod;

  /// Reason for NIL return
  final String? reason;

  /// Additional notes
  final String? notes;

  /// Supporting documents (if any)
  final List<String>? documents;

  /// Declaration that the information is true
  final bool declaration;

  const NilReturnRequest({
    required this.pinNumber,
    required this.obligationType,
    required this.taxPeriod,
    this.reason,
    this.notes,
    this.documents,
    required this.declaration,
  });

  /// Returns true if supporting documents are provided
  bool get hasDocuments => documents != null && documents!.isNotEmpty;

  /// Returns the number of supporting documents
  int get documentCount => documents?.length ?? 0;

  /// Returns true if a reason is provided
  bool get hasReason => reason != null && reason!.isNotEmpty;

  /// Validates the request before submission
  bool isValid() {
    if (pinNumber.isEmpty) return false;
    if (obligationType.isEmpty) return false;
    if (taxPeriod.isEmpty) return false;
    if (!declaration) return false;

    // Validate tax period format (YYYY-MM)
    final periodRegex = RegExp(r'^\d{4}-\d{2}$');
    if (!periodRegex.hasMatch(taxPeriod)) return false;

    return true;
  }

  /// Creates a [NilReturnRequest] from JSON
  factory NilReturnRequest.fromJson(Map<String, dynamic> json) {
    return NilReturnRequest(
      pinNumber: json['pin_number'] as String,
      obligationType: json['obligation_type'] as String,
      taxPeriod: json['tax_period'] as String,
      reason: json['reason'] as String?,
      notes: json['notes'] as String?,
      documents: json['documents'] != null
          ? List<String>.from(json['documents'] as List)
          : null,
      declaration: json['declaration'] as bool? ?? false,
    );
  }

  /// Converts this [NilReturnRequest] to JSON
  Map<String, dynamic> toJson() {
    return {
      'pin_number': pinNumber,
      'obligation_type': obligationType,
      'tax_period': taxPeriod,
      if (reason != null) 'reason': reason,
      if (notes != null) 'notes': notes,
      if (documents != null) 'documents': documents,
      'declaration': declaration,
    };
  }

  /// Creates a copy with optional field overrides
  NilReturnRequest copyWith({
    String? pinNumber,
    String? obligationType,
    String? taxPeriod,
    String? reason,
    String? notes,
    List<String>? documents,
    bool? declaration,
  }) {
    return NilReturnRequest(
      pinNumber: pinNumber ?? this.pinNumber,
      obligationType: obligationType ?? this.obligationType,
      taxPeriod: taxPeriod ?? this.taxPeriod,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      documents: documents ?? this.documents,
      declaration: declaration ?? this.declaration,
    );
  }

  @override
  String toString() => 'NilReturnRequest('
      'pinNumber: $pinNumber, '
      'obligationType: $obligationType, '
      'taxPeriod: $taxPeriod, '
      'declaration: $declaration)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NilReturnRequest &&
          runtimeType == other.runtimeType &&
          pinNumber == other.pinNumber &&
          obligationType == other.obligationType &&
          taxPeriod == other.taxPeriod &&
          reason == other.reason &&
          notes == other.notes &&
          _listEquals(documents, other.documents) &&
          declaration == other.declaration;

  @override
  int get hashCode =>
      pinNumber.hashCode ^
      obligationType.hashCode ^
      taxPeriod.hashCode ^
      reason.hashCode ^
      notes.hashCode ^
      documents.hashCode ^
      declaration.hashCode;

  bool _listEquals(List<String>? a, List<String>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

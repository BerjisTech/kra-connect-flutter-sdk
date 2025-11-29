import 'package:meta/meta.dart';
import 'tax_obligation.dart';

/// Detailed information about a taxpayer.
@immutable
class TaxpayerDetails {
  /// Taxpayer PIN
  final String pinNumber;

  /// Taxpayer name
  final String taxpayerName;

  /// Taxpayer type (e.g., 'individual', 'company')
  final String taxpayerType;

  /// Registration date (YYYY-MM-DD format)
  final String? registrationDate;

  /// Tax office
  final String? taxOffice;

  /// Business activity
  final String? businessActivity;

  /// Physical address
  final String? physicalAddress;

  /// Postal address
  final String? postalAddress;

  /// Email address
  final String? email;

  /// Phone number
  final String? phoneNumber;

  /// Tax compliance status
  final String? complianceStatus;

  /// Whether the taxpayer is active
  final bool isActive;

  /// Tax obligations
  final List<TaxObligation>? obligations;

  /// Additional data from the API
  final Map<String, dynamic>? additionalData;

  /// Timestamp when details were retrieved
  final DateTime retrievedAt;

  const TaxpayerDetails({
    required this.pinNumber,
    required this.taxpayerName,
    required this.taxpayerType,
    this.registrationDate,
    this.taxOffice,
    this.businessActivity,
    this.physicalAddress,
    this.postalAddress,
    this.email,
    this.phoneNumber,
    this.complianceStatus,
    required this.isActive,
    this.obligations,
    this.additionalData,
    required this.retrievedAt,
  });

  /// Returns true if taxpayer is a company
  bool get isCompany => taxpayerType.toLowerCase() == 'company';

  /// Returns true if taxpayer is an individual
  bool get isIndividual => taxpayerType.toLowerCase() == 'individual';

  /// Returns true if taxpayer is compliant
  bool get isCompliant =>
      complianceStatus != null &&
      complianceStatus!.toLowerCase() == 'compliant';

  /// Returns true if taxpayer has obligations
  bool get hasObligations => obligations != null && obligations!.isNotEmpty;

  /// Returns the number of obligations
  int get obligationCount => obligations?.length ?? 0;

  /// Returns true if contact information is available
  bool get hasContactInfo =>
      (email != null && email!.isNotEmpty) ||
      (phoneNumber != null && phoneNumber!.isNotEmpty);

  /// Returns true if address information is available
  bool get hasAddress =>
      (physicalAddress != null && physicalAddress!.isNotEmpty) ||
      (postalAddress != null && postalAddress!.isNotEmpty);

  /// Returns a display-friendly name
  String getDisplayName() {
    if (taxpayerName.isNotEmpty) {
      return taxpayerName;
    }
    return pinNumber;
  }

  /// Returns years since registration
  int? get yearsSinceRegistration {
    if (registrationDate == null) return null;
    try {
      final regDate = DateTime.parse(registrationDate!);
      return DateTime.now().difference(regDate).inDays ~/ 365;
    } catch (_) {
      return null;
    }
  }

  /// Returns obligations by type
  List<TaxObligation> getObligationsByType(String type) {
    if (obligations == null) return [];
    return obligations!
        .where((o) => o.obligationType.toLowerCase() == type.toLowerCase())
        .toList();
  }

  /// Returns overdue obligations
  List<TaxObligation> getOverdueObligations() {
    if (obligations == null) return [];
    return obligations!.where((o) => o.isOverdue).toList();
  }

  /// Creates a [TaxpayerDetails] from JSON
  factory TaxpayerDetails.fromJson(Map<String, dynamic> json) {
    return TaxpayerDetails(
      pinNumber: json['pin_number'] as String,
      taxpayerName: json['taxpayer_name'] as String,
      taxpayerType: json['taxpayer_type'] as String,
      registrationDate: json['registration_date'] as String?,
      taxOffice: json['tax_office'] as String?,
      businessActivity: json['business_activity'] as String?,
      physicalAddress: json['physical_address'] as String?,
      postalAddress: json['postal_address'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
      complianceStatus: json['compliance_status'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      obligations: json['obligations'] != null
          ? (json['obligations'] as List)
              .map((o) => TaxObligation.fromJson(o as Map<String, dynamic>))
              .toList()
          : null,
      additionalData: json['additional_data'] as Map<String, dynamic>?,
      retrievedAt: json['retrieved_at'] != null
          ? DateTime.parse(json['retrieved_at'] as String)
          : DateTime.now(),
    );
  }

  /// Converts this [TaxpayerDetails] to JSON
  Map<String, dynamic> toJson() {
    return {
      'pin_number': pinNumber,
      'taxpayer_name': taxpayerName,
      'taxpayer_type': taxpayerType,
      if (registrationDate != null) 'registration_date': registrationDate,
      if (taxOffice != null) 'tax_office': taxOffice,
      if (businessActivity != null) 'business_activity': businessActivity,
      if (physicalAddress != null) 'physical_address': physicalAddress,
      if (postalAddress != null) 'postal_address': postalAddress,
      if (email != null) 'email': email,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (complianceStatus != null) 'compliance_status': complianceStatus,
      'is_active': isActive,
      if (obligations != null)
        'obligations': obligations!.map((o) => o.toJson()).toList(),
      if (additionalData != null) 'additional_data': additionalData,
      'retrieved_at': retrievedAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'TaxpayerDetails('
      'pinNumber: $pinNumber, '
      'taxpayerName: $taxpayerName, '
      'taxpayerType: $taxpayerType, '
      'isActive: $isActive)';
}

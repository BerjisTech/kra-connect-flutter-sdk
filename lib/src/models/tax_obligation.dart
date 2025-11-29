import 'package:meta/meta.dart';

/// Tax obligation information.
@immutable
class TaxObligation {
  /// Obligation type (e.g., 'VAT', 'INCOME_TAX', 'PAYE')
  final String obligationType;

  /// Tax period (YYYY-MM format)
  final String taxPeriod;

  /// Due date for filing (YYYY-MM-DD format)
  final String? filingDueDate;

  /// Due date for payment (YYYY-MM-DD format)
  final String? paymentDueDate;

  /// Filing status (e.g., 'filed', 'not_filed', 'overdue')
  final String? filingStatus;

  /// Payment status (e.g., 'paid', 'unpaid', 'partial')
  final String? paymentStatus;

  /// Amount due
  final double? amountDue;

  /// Amount paid
  final double? amountPaid;

  /// Balance remaining
  final double? balance;

  /// Currency
  final String? currency;

  /// Last filing date
  final String? lastFilingDate;

  /// Last payment date
  final String? lastPaymentDate;

  /// Whether this obligation is overdue
  final bool isOverdue;

  /// Additional data from the API
  final Map<String, dynamic>? additionalData;

  const TaxObligation({
    required this.obligationType,
    required this.taxPeriod,
    this.filingDueDate,
    this.paymentDueDate,
    this.filingStatus,
    this.paymentStatus,
    this.amountDue,
    this.amountPaid,
    this.balance,
    this.currency,
    this.lastFilingDate,
    this.lastPaymentDate,
    required this.isOverdue,
    this.additionalData,
  });

  /// Returns true if filing is complete
  bool get isFiled =>
      filingStatus != null && filingStatus!.toLowerCase() == 'filed';

  /// Returns true if filing is pending
  bool get isFilingPending =>
      filingStatus != null && filingStatus!.toLowerCase() == 'not_filed';

  /// Returns true if payment is complete
  bool get isPaid =>
      paymentStatus != null && paymentStatus!.toLowerCase() == 'paid';

  /// Returns true if payment is pending
  bool get isPaymentPending =>
      paymentStatus != null && paymentStatus!.toLowerCase() == 'unpaid';

  /// Returns true if payment is partial
  bool get isPartiallyPaid =>
      paymentStatus != null && paymentStatus!.toLowerCase() == 'partial';

  /// Returns true if there is a balance due
  bool get hasBalance => balance != null && balance! > 0;

  /// Returns the payment completion percentage
  double? get paymentPercentage {
    if (amountDue == null || amountPaid == null || amountDue == 0) {
      return null;
    }
    return (amountPaid! / amountDue!) * 100;
  }

  /// Returns days until filing due date
  int? get daysUntilFilingDue {
    if (filingDueDate == null) return null;
    try {
      final dueDate = DateTime.parse(filingDueDate!);
      return dueDate.difference(DateTime.now()).inDays;
    } catch (_) {
      return null;
    }
  }

  /// Returns days until payment due date
  int? get daysUntilPaymentDue {
    if (paymentDueDate == null) return null;
    try {
      final dueDate = DateTime.parse(paymentDueDate!);
      return dueDate.difference(DateTime.now()).inDays;
    } catch (_) {
      return null;
    }
  }

  /// Returns true if filing is overdue
  bool get isFilingOverdue {
    if (filingDueDate == null || isFiled) return false;
    try {
      final dueDate = DateTime.parse(filingDueDate!);
      return DateTime.now().isAfter(dueDate);
    } catch (_) {
      return false;
    }
  }

  /// Returns true if payment is overdue
  bool get isPaymentOverdue {
    if (paymentDueDate == null || isPaid) return false;
    try {
      final dueDate = DateTime.parse(paymentDueDate!);
      return DateTime.now().isAfter(dueDate);
    } catch (_) {
      return false;
    }
  }

  /// Returns true if filing is due soon (within specified days)
  bool isFilingDueSoon(int days) {
    final daysLeft = daysUntilFilingDue;
    if (daysLeft == null) return false;
    return daysLeft >= 0 && daysLeft <= days;
  }

  /// Returns true if payment is due soon (within specified days)
  bool isPaymentDueSoon(int days) {
    final daysLeft = daysUntilPaymentDue;
    if (daysLeft == null) return false;
    return daysLeft >= 0 && daysLeft <= days;
  }

  /// Returns a formatted amount string
  String getFormattedAmount() {
    if (amountDue == null) return 'N/A';
    final currencySymbol = _getCurrencySymbol();
    return '$currencySymbol${amountDue!.toStringAsFixed(2)}';
  }

  /// Returns a formatted balance string
  String getFormattedBalance() {
    if (balance == null) return 'N/A';
    final currencySymbol = _getCurrencySymbol();
    return '$currencySymbol${balance!.toStringAsFixed(2)}';
  }

  String _getCurrencySymbol() {
    switch (currency?.toUpperCase()) {
      case 'KES':
        return 'KSh ';
      case 'USD':
        return '\$ ';
      case 'EUR':
        return '€ ';
      case 'GBP':
        return '£ ';
      default:
        return currency != null ? '$currency ' : '';
    }
  }

  /// Creates a [TaxObligation] from JSON
  factory TaxObligation.fromJson(Map<String, dynamic> json) {
    return TaxObligation(
      obligationType: json['obligation_type'] as String,
      taxPeriod: json['tax_period'] as String,
      filingDueDate: json['filing_due_date'] as String?,
      paymentDueDate: json['payment_due_date'] as String?,
      filingStatus: json['filing_status'] as String?,
      paymentStatus: json['payment_status'] as String?,
      amountDue: (json['amount_due'] as num?)?.toDouble(),
      amountPaid: (json['amount_paid'] as num?)?.toDouble(),
      balance: (json['balance'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      lastFilingDate: json['last_filing_date'] as String?,
      lastPaymentDate: json['last_payment_date'] as String?,
      isOverdue: json['is_overdue'] as bool? ?? false,
      additionalData: json['additional_data'] as Map<String, dynamic>?,
    );
  }

  /// Converts this [TaxObligation] to JSON
  Map<String, dynamic> toJson() {
    return {
      'obligation_type': obligationType,
      'tax_period': taxPeriod,
      if (filingDueDate != null) 'filing_due_date': filingDueDate,
      if (paymentDueDate != null) 'payment_due_date': paymentDueDate,
      if (filingStatus != null) 'filing_status': filingStatus,
      if (paymentStatus != null) 'payment_status': paymentStatus,
      if (amountDue != null) 'amount_due': amountDue,
      if (amountPaid != null) 'amount_paid': amountPaid,
      if (balance != null) 'balance': balance,
      if (currency != null) 'currency': currency,
      if (lastFilingDate != null) 'last_filing_date': lastFilingDate,
      if (lastPaymentDate != null) 'last_payment_date': lastPaymentDate,
      'is_overdue': isOverdue,
      if (additionalData != null) 'additional_data': additionalData,
    };
  }

  @override
  String toString() => 'TaxObligation('
      'obligationType: $obligationType, '
      'taxPeriod: $taxPeriod, '
      'isOverdue: $isOverdue, '
      'balance: $balance $currency)';
}

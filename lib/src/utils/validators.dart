import '../exceptions/validation_exception.dart';

/// Utility class for validating KRA-related data.
class Validators {
  // Private constructor to prevent instantiation
  Validators._();

  /// Regular expression for KRA PIN format (P + 9 digits + letter)
  static final RegExp _pinRegex = RegExp(r'^P\d{9}[A-Z]$');

  /// Regular expression for TCC number format (TCC + digits)
  static final RegExp _tccRegex = RegExp(r'^TCC\d{6,10}$');

  /// Regular expression for e-slip number format
  static final RegExp _eslipRegex = RegExp(r'^[A-Z0-9]{10,20}$');

  /// Regular expression for tax period format (YYYY-MM)
  static final RegExp _taxPeriodRegex = RegExp(r'^\d{4}-\d{2}$');

  /// Regular expression for date format (YYYY-MM-DD)
  static final RegExp _dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  /// Regular expression for email format
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Regular expression for phone number format
  static final RegExp _phoneRegex = RegExp(r'^(\+254|0)[17]\d{8}$');

  /// Validates a KRA PIN number.
  ///
  /// Throws [ValidationException] if the PIN is invalid.
  ///
  /// Example:
  /// ```dart
  /// Validators.validatePin('P051234567A'); // Valid
  /// Validators.validatePin('P12345678'); // Throws ValidationException
  /// ```
  static void validatePin(String pin) {
    if (pin.isEmpty) {
      throw const ValidationException(
        'PIN number is required',
        'pin',
      );
    }

    final cleanPin = pin.trim().toUpperCase();

    if (!_pinRegex.hasMatch(cleanPin)) {
      throw ValidationException(
        'Invalid PIN format. Expected format: P followed by 9 digits and a letter (e.g., P051234567A)',
        'pin',
        details: {'provided': pin},
      );
    }
  }

  /// Validates a TCC number.
  ///
  /// Throws [ValidationException] if the TCC is invalid.
  ///
  /// Example:
  /// ```dart
  /// Validators.validateTcc('TCC123456'); // Valid
  /// Validators.validateTcc('123456'); // Throws ValidationException
  /// ```
  static void validateTcc(String tcc) {
    if (tcc.isEmpty) {
      throw const ValidationException(
        'TCC number is required',
        'tcc',
      );
    }

    final cleanTcc = tcc.trim().toUpperCase();

    if (!_tccRegex.hasMatch(cleanTcc)) {
      throw ValidationException(
        'Invalid TCC format. Expected format: TCC followed by 6-10 digits (e.g., TCC123456)',
        'tcc',
        details: {'provided': tcc},
      );
    }
  }

  /// Validates an e-slip number.
  ///
  /// Throws [ValidationException] if the e-slip is invalid.
  ///
  /// Example:
  /// ```dart
  /// Validators.validateEslip('ABC1234567'); // Valid
  /// Validators.validateEslip('123'); // Throws ValidationException
  /// ```
  static void validateEslip(String eslip) {
    if (eslip.isEmpty) {
      throw const ValidationException(
        'E-slip number is required',
        'eslip',
      );
    }

    final cleanEslip = eslip.trim().toUpperCase();

    if (!_eslipRegex.hasMatch(cleanEslip)) {
      throw ValidationException(
        'Invalid e-slip format. Expected format: 10-20 alphanumeric characters',
        'eslip',
        details: {'provided': eslip},
      );
    }
  }

  /// Validates a tax period.
  ///
  /// Throws [ValidationException] if the tax period is invalid.
  ///
  /// Example:
  /// ```dart
  /// Validators.validateTaxPeriod('2024-01'); // Valid
  /// Validators.validateTaxPeriod('2024-13'); // Throws ValidationException (invalid month)
  /// ```
  static void validateTaxPeriod(String taxPeriod) {
    if (taxPeriod.isEmpty) {
      throw const ValidationException(
        'Tax period is required',
        'tax_period',
      );
    }

    if (!_taxPeriodRegex.hasMatch(taxPeriod)) {
      throw ValidationException(
        'Invalid tax period format. Expected format: YYYY-MM (e.g., 2024-01)',
        'tax_period',
        details: {'provided': taxPeriod},
      );
    }

    // Validate month range
    final parts = taxPeriod.split('-');
    final month = int.tryParse(parts[1]);

    if (month == null || month < 1 || month > 12) {
      throw ValidationException(
        'Invalid month in tax period. Month must be between 01 and 12',
        'tax_period',
        details: {'provided': taxPeriod},
      );
    }

    // Validate year range
    final year = int.tryParse(parts[0]);
    if (year == null || year < 2000 || year > 2100) {
      throw ValidationException(
        'Invalid year in tax period. Year must be between 2000 and 2100',
        'tax_period',
        details: {'provided': taxPeriod},
      );
    }
  }

  /// Validates a date string.
  ///
  /// Throws [ValidationException] if the date is invalid.
  ///
  /// Example:
  /// ```dart
  /// Validators.validateDate('2024-01-15'); // Valid
  /// Validators.validateDate('2024-13-01'); // Throws ValidationException
  /// ```
  static void validateDate(String date) {
    if (date.isEmpty) {
      throw const ValidationException(
        'Date is required',
        'date',
      );
    }

    if (!_dateRegex.hasMatch(date)) {
      throw ValidationException(
        'Invalid date format. Expected format: YYYY-MM-DD (e.g., 2024-01-15)',
        'date',
        details: {'provided': date},
      );
    }

    // Try to parse the date to ensure it's valid
    try {
      DateTime.parse(date);
    } catch (e) {
      throw ValidationException(
        'Invalid date value',
        'date',
        details: {'provided': date, 'error': e.toString()},
      );
    }
  }

  /// Validates an email address.
  ///
  /// Throws [ValidationException] if the email is invalid.
  ///
  /// Example:
  /// ```dart
  /// Validators.validateEmail('user@example.com'); // Valid
  /// Validators.validateEmail('invalid-email'); // Throws ValidationException
  /// ```
  static void validateEmail(String email) {
    if (email.isEmpty) {
      throw const ValidationException(
        'Email is required',
        'email',
      );
    }

    if (!_emailRegex.hasMatch(email.trim())) {
      throw ValidationException(
        'Invalid email format',
        'email',
        details: {'provided': email},
      );
    }
  }

  /// Validates a phone number.
  ///
  /// Throws [ValidationException] if the phone number is invalid.
  ///
  /// Example:
  /// ```dart
  /// Validators.validatePhone('+254712345678'); // Valid
  /// Validators.validatePhone('0712345678'); // Valid
  /// Validators.validatePhone('12345'); // Throws ValidationException
  /// ```
  static void validatePhone(String phone) {
    if (phone.isEmpty) {
      throw const ValidationException(
        'Phone number is required',
        'phone',
      );
    }

    if (!_phoneRegex.hasMatch(phone.trim())) {
      throw ValidationException(
        'Invalid Kenyan phone number format. Expected format: +254712345678 or 0712345678',
        'phone',
        details: {'provided': phone},
      );
    }
  }

  /// Validates an API key.
  ///
  /// Throws [ValidationException] if the API key is invalid.
  ///
  /// Example:
  /// ```dart
  /// Validators.validateApiKey('my-api-key-123'); // Valid
  /// Validators.validateApiKey(''); // Throws ValidationException
  /// ```
  static void validateApiKey(String apiKey) {
    if (apiKey.isEmpty) {
      throw const ValidationException(
        'API key is required',
        'api_key',
      );
    }

    if (apiKey.trim().length < 10) {
      throw const ValidationException(
        'API key is too short. Minimum length is 10 characters',
        'api_key',
      );
    }
  }

  /// Validates an amount value.
  ///
  /// Throws [ValidationException] if the amount is invalid.
  ///
  /// Example:
  /// ```dart
  /// Validators.validateAmount(100.50); // Valid
  /// Validators.validateAmount(-10.0); // Throws ValidationException
  /// ```
  static void validateAmount(double amount) {
    if (amount < 0) {
      throw ValidationException(
        'Amount cannot be negative',
        'amount',
        details: {'provided': amount},
      );
    }

    if (amount > 999999999.99) {
      throw ValidationException(
        'Amount exceeds maximum allowed value',
        'amount',
        details: {'provided': amount, 'max': 999999999.99},
      );
    }
  }

  /// Checks if a PIN is valid without throwing an exception.
  ///
  /// Returns `true` if the PIN is valid, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// if (Validators.isValidPin('P051234567A')) {
  ///   print('Valid PIN');
  /// }
  /// ```
  static bool isValidPin(String pin) {
    try {
      validatePin(pin);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Checks if a TCC is valid without throwing an exception.
  ///
  /// Returns `true` if the TCC is valid, `false` otherwise.
  static bool isValidTcc(String tcc) {
    try {
      validateTcc(tcc);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Checks if an e-slip is valid without throwing an exception.
  ///
  /// Returns `true` if the e-slip is valid, `false` otherwise.
  static bool isValidEslip(String eslip) {
    try {
      validateEslip(eslip);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Checks if a tax period is valid without throwing an exception.
  ///
  /// Returns `true` if the tax period is valid, `false` otherwise.
  static bool isValidTaxPeriod(String taxPeriod) {
    try {
      validateTaxPeriod(taxPeriod);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Checks if an email is valid without throwing an exception.
  ///
  /// Returns `true` if the email is valid, `false` otherwise.
  static bool isValidEmail(String email) {
    try {
      validateEmail(email);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Checks if a phone number is valid without throwing an exception.
  ///
  /// Returns `true` if the phone number is valid, `false` otherwise.
  static bool isValidPhone(String phone) {
    try {
      validatePhone(phone);
      return true;
    } catch (_) {
      return false;
    }
  }
}

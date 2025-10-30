/// Extension utilities for MFTracker
library;

import 'package:intl/intl.dart';

/// Extension methods for DateTime
extension DateTimeExtension on DateTime {
  /// Format date as "dd MMM yyyy" (e.g., "19 Oct 2025")
  String toShortDateString() {
    return DateFormat('dd MMM yyyy').format(this);
  }

  /// Format date as "dd MMMM yyyy" (e.g., "19 October 2025")
  String toLongDateString() {
    return DateFormat('dd MMMM yyyy').format(this);
  }

  /// Format date as "MMM yyyy" (e.g., "Oct 2025")
  String toMonthYearString() {
    return DateFormat('MMM yyyy').format(this);
  }

  /// Format date and time as "dd MMM yyyy, hh:mm a" (e.g., "19 Oct 2025, 02:30 PM")
  String toFullDateTimeString() {
    return DateFormat('dd MMM yyyy, hh:mm a').format(this);
  }

  /// Format time only as "hh:mm a" (e.g., "02:30 PM")
  String toTimeString() {
    return DateFormat('hh:mm a').format(this);
  }

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Check if date is in current month
  bool get isCurrentMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  /// Check if date is in current year
  bool get isCurrentYear {
    return year == DateTime.now().year;
  }

  /// Get start of day (00:00:00)
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  /// Get end of day (23:59:59.999)
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }

  /// Get start of month
  DateTime get startOfMonth {
    return DateTime(year, month, 1);
  }

  /// Get end of month
  DateTime get endOfMonth {
    return DateTime(year, month + 1, 0, 23, 59, 59, 999);
  }

  /// Get start of year
  DateTime get startOfYear {
    return DateTime(year, 1, 1);
  }

  /// Get end of year
  DateTime get endOfYear {
    return DateTime(year, 12, 31, 23, 59, 59, 999);
  }

  /// Get relative display string (Today, Yesterday, or date)
  String toRelativeString() {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    return toShortDateString();
  }
}

/// Extension methods for double (amounts)
extension DoubleExtension on double {
  /// Format as Indian Rupees with symbol
  String toCurrency({bool showSymbol = true}) {
    final symbol = showSymbol ? '₹' : '';
    return '$symbol${toStringAsFixed(2)}';
  }

  /// Format as compact currency (K, L, Cr)
  String toCompactCurrency({bool showSymbol = true}) {
    final symbol = showSymbol ? '₹' : '';
    if (this >= 10000000) {
      // 1 Crore+
      return '$symbol${(this / 10000000).toStringAsFixed(2)}Cr';
    } else if (this >= 100000) {
      // 1 Lakh+
      return '$symbol${(this / 100000).toStringAsFixed(2)}L';
    } else if (this >= 1000) {
      // 1 Thousand+
      return '$symbol${(this / 1000).toStringAsFixed(2)}K';
    }
    return '$symbol${toStringAsFixed(0)}';
  }

  /// Format with Indian number system (commas)
  String toIndianFormat({bool showSymbol = true}) {
    final symbol = showSymbol ? '₹' : '';
    final parts = toStringAsFixed(2).split('.');
    final wholePart = parts[0];
    final decimalPart = parts[1];

    // Indian format: 1,00,00,000
    String formatted = '';
    int count = 0;

    for (int i = wholePart.length - 1; i >= 0; i--) {
      if (count == 3 || (count > 3 && (count - 3) % 2 == 0)) {
        formatted = ',$formatted';
      }
      formatted = wholePart[i] + formatted;
      count++;
    }

    return '$symbol$formatted.$decimalPart';
  }

  /// Get absolute value
  double get absolute => abs();

  /// Check if amount is positive
  bool get isPositive => this > 0;

  /// Check if amount is negative
  bool get isNegative => this < 0;

  /// Check if amount is zero
  bool get isZeroAmount => this == 0.0;
}

/// Extension methods for String
extension StringExtension on String {
  /// Convert string to Title Case
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ')
        .map((word) => word.isEmpty
            ? word
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  /// Check if string is a valid email
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Check if string is a valid phone number (Indian)
  bool get isValidPhone {
    final phoneRegex = RegExp(r'^[6-9]\d{9}$');
    return phoneRegex.hasMatch(replaceAll(RegExp(r'[^\d]'), ''));
  }

  /// Extract amount from notification text
  double? extractAmount() {
    // Common patterns: Rs. 1234.56, INR 1234.56, ₹1234.56, 1234.56
    final patterns = [
      RegExp(r'(?:rs\.?|inr|₹)\s*(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
      RegExp(r'(\d+(?:,\d+)*(?:\.\d{2})?)(?:\s*(?:rs\.?|inr|₹))', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(this);
      if (match != null) {
        final amountStr = match.group(1)?.replaceAll(',', '') ?? '0';
        return double.tryParse(amountStr);
      }
    }
    return null;
  }

  /// Extract account number from notification text (last 4 digits)
  String? extractAccountNumber() {
    // Pattern: A/C **1234 or Account ending 1234
    final patterns = [
      RegExp(r'a/?c\s*(?:\*{2,4})?(\d{4})', caseSensitive: false),
      RegExp(r'account\s+ending\s+(?:with\s+)?(\d{4})', caseSensitive: false),
      RegExp(r'card\s+(?:\*{2,4})?(\d{4})', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(this);
      if (match != null) {
        return match.group(1);
      }
    }
    return null;
  }

  /// Extract UPI ID from notification text
  String? extractUpiId() {
    // Pattern: abc@paytm, xyz@okaxis, etc.
    final pattern = RegExp(r'([a-zA-Z0-9._-]+@[a-zA-Z0-9]+)');
    final match = pattern.firstMatch(this);
    return match?.group(1);
  }

  /// Extract merchant name from notification text
  String? extractMerchantName() {
    // Common patterns: "to Swiggy", "at Amazon", "from Flipkart"
    final patterns = [
      RegExp(r'(?:to|at|from)\s+([A-Z][a-zA-Z0-9\s]{2,30})', caseSensitive: false),
      RegExp(r'merchant:\s*([A-Z][a-zA-Z0-9\s]{2,30})', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(this);
      if (match != null) {
        return match.group(1)?.trim();
      }
    }
    return null;
  }

  /// Check if text contains transaction keywords
  bool get isTransactionNotification {
    final keywords = [
      'debited',
      'credited',
      'paid',
      'received',
      'withdrawn',
      'transferred',
      'refund',
      'cashback',
      'inr',
      'rs.',
      '₹',
    ];

    final lowerCase = toLowerCase();
    return keywords.any((keyword) => lowerCase.contains(keyword));
  }

  /// Truncate string to max length with ellipsis
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }
}

/// Extension methods for List of double
extension DoubleListExtension on List<double> {
  /// Calculate sum of all amounts
  double get sum => isEmpty ? 0.0 : reduce((a, b) => a + b);

  /// Calculate average of all amounts
  double get average => isEmpty ? 0.0 : sum / length;

  /// Get maximum amount
  double get max => isEmpty ? 0.0 : reduce((a, b) => a > b ? a : b);

  /// Get minimum amount
  double get min => isEmpty ? 0.0 : reduce((a, b) => a < b ? a : b);
}

/// Extension methods for int (timestamps)
extension IntExtension on int {
  /// Convert Unix timestamp (milliseconds) to DateTime
  DateTime toDateTime() {
    return DateTime.fromMillisecondsSinceEpoch(this);
  }

  /// Format as currency
  String toCurrency({bool showSymbol = true}) {
    return toDouble().toCurrency(showSymbol: showSymbol);
  }
}

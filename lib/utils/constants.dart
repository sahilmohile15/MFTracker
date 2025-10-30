/// Constants and configurations for MFTracker
library;

import 'package:flutter/material.dart';

/// App Information
class AppInfo {
  static const String appName = 'MFTracker';
  static const String appFullName = 'My Finance Tracker';
  static const String appTagline = 'Your Notifications, Your Insights';
  static const String version = '2.0.0';
  static const String buildNumber = '2';
}

/// Database Configuration
class DatabaseConfig {
  static const String databaseName = 'mftracker.db';
  static const int databaseVersion = 1;
  static const int batchSize = 100; // Notification batch processing size
  static const int pageSize = 50; // Transaction pagination size
}

/// Performance Targets
class PerformanceTargets {
  static const int maxActiveMemoryMB = 50;
  static const int maxBackgroundMemoryMB = 20;
  static const double maxBatteryDrainPercent = 2.0;
  static const int maxAppLaunchMs = 1500;
  static const int maxDatabaseQueryMs = 100;
}

/// Notification Service Configuration
class NotificationConfig {
  static const Duration notificationProcessDelay = Duration(milliseconds: 500);
  static const int maxNotificationAgeDays = 365; // Only process last 1 year
  static const int notificationBufferSize = 100;
}

/// Transaction Types
enum TransactionType {
  debit,
  credit;

  String get displayName {
    switch (this) {
      case TransactionType.debit:
        return 'Debit';
      case TransactionType.credit:
        return 'Credit';
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionType.debit:
        return Icons.arrow_upward;
      case TransactionType.credit:
        return Icons.arrow_downward;
    }
  }

  Color get color {
    switch (this) {
      case TransactionType.debit:
        return Colors.red;
      case TransactionType.credit:
        return Colors.green;
    }
  }
}

/// Transaction Categories
enum Category {
  upiPayments(
    name: 'UPI Payments',
    icon: Icons.payment,
    color: Color(0xFF2196F3), // Blue
  ),
  foodDelivery(
    name: 'Food Delivery',
    icon: Icons.fastfood,
    color: Color(0xFFFF9800), // Orange
  ),
  shopping(
    name: 'Shopping',
    icon: Icons.shopping_bag,
    color: Color(0xFF9C27B0), // Purple
  ),
  groceries(
    name: 'Groceries',
    icon: Icons.shopping_cart,
    color: Color(0xFF4CAF50), // Green
  ),
  transportation(
    name: 'Transportation',
    icon: Icons.directions_car,
    color: Color(0xFF009688), // Teal
  ),
  entertainment(
    name: 'Entertainment',
    icon: Icons.movie,
    color: Color(0xFFE91E63), // Pink
  ),
  billPayments(
    name: 'Bill Payments',
    icon: Icons.receipt,
    color: Color(0xFFF44336), // Red
  ),
  recharge(
    name: 'Recharge',
    icon: Icons.phone_android,
    color: Color(0xFF3F51B5), // Indigo
  ),
  cardPayments(
    name: 'Card Payments',
    icon: Icons.credit_card,
    color: Color(0xFFFFC107), // Amber
  ),
  bankTransfers(
    name: 'Bank Transfers',
    icon: Icons.account_balance,
    color: Color(0xFF00BCD4), // Cyan
  ),
  atmWithdrawals(
    name: 'ATM Withdrawals',
    icon: Icons.atm,
    color: Color(0xFF795548), // Brown
  ),
  emi(
    name: 'EMI',
    icon: Icons.payment,
    color: Color(0xFFFF5722), // Deep Orange
  ),
  subscriptions(
    name: 'Subscriptions',
    icon: Icons.subscriptions,
    color: Color(0xFF673AB7), // Deep Purple
  ),
  healthcare(
    name: 'Healthcare',
    icon: Icons.medical_services,
    color: Color(0xFFE57373), // Red 300
  ),
  income(
    name: 'Income',
    icon: Icons.trending_up,
    color: Color(0xFF8BC34A), // Light Green
  ),
  investment(
    name: 'Investment',
    icon: Icons.show_chart,
    color: Color(0xFF1976D2), // Blue 700
  ),
  others(
    name: 'Others',
    icon: Icons.more_horiz,
    color: Color(0xFF9E9E9E), // Grey
  );

  const Category({
    required this.name,
    required this.icon,
    required this.color,
  });

  final String name;
  final IconData icon;
  final Color color;
}

/// Categorization Methods
enum CategorizationMethod {
  ruleBased(name: 'Rule-Based'),
  machineLearning(name: 'ML Model'),
  merchantDatabase(name: 'Merchant DB'),
  userCorrected(name: 'User Corrected'),
  defaultFallback(name: 'Default');

  const CategorizationMethod({required this.name});

  final String name;
}

/// Account Types
enum AccountType {
  savings(name: 'Savings Account', icon: Icons.account_balance),
  current(name: 'Current Account', icon: Icons.business),
  creditCard(name: 'Credit Card', icon: Icons.credit_card),
  wallet(name: 'Wallet', icon: Icons.account_balance_wallet);

  const AccountType({
    required this.name,
    required this.icon,
  });

  final String name;
  final IconData icon;
}

/// Trend Period for Analytics
enum TrendPeriod {
  daily(name: 'Daily', days: 1),
  weekly(name: 'Weekly', days: 7),
  monthly(name: 'Monthly', days: 30),
  yearly(name: 'Yearly', days: 365);

  const TrendPeriod({
    required this.name,
    required this.days,
  });

  final String name;
  final int days;
}

/// Currency Formatter
class CurrencyFormatter {
  static String format(double amount, {bool showSymbol = true}) {
    final symbol = showSymbol ? '₹' : '';
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  static String formatCompact(double amount, {bool showSymbol = true}) {
    final symbol = showSymbol ? '₹' : '';
    if (amount >= 10000000) {
      // 1 Crore+
      return '$symbol${(amount / 10000000).toStringAsFixed(2)}Cr';
    } else if (amount >= 100000) {
      // 1 Lakh+
      return '$symbol${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount >= 1000) {
      // 1 Thousand+
      return '$symbol${(amount / 1000).toStringAsFixed(2)}K';
    }
    return '$symbol${amount.toStringAsFixed(0)}';
  }
}

/// Date & Time Formats
class DateFormats {
  static const String shortDate = 'dd MMM yyyy'; // 19 Oct 2025
  static const String longDate = 'dd MMMM yyyy'; // 19 October 2025
  static const String monthYear = 'MMM yyyy'; // Oct 2025
  static const String fullDateTime = 'dd MMM yyyy, hh:mm a'; // 19 Oct 2025, 02:30 PM
  static const String timeOnly = 'hh:mm a'; // 02:30 PM
}

/// Transaction Notification Keywords - Common keywords for filtering
class TransactionKeywords {
  // Transaction keywords
  static const List<String> transactionKeywords = [
    'debited',
    'credited',
    'paid',
    'received',
    'withdrawn',
    'transferred',
    'refund',
    'cashback',
  ];

  // Payment methods
  static const List<String> paymentMethods = [
    'upi',
    'card',
    'atm',
    'neft',
    'imps',
    'rtgs',
  ];

  // Currency indicators
  static const List<String> currencyIndicators = [
    'inr',
    'rs',
    '₹',
  ];
}

/// App Theme Colors
class AppColors {
  // Primary Colors
  static const Color primaryColor = Color(0xFF2196F3); // Blue
  static const Color secondaryColor = Color(0xFF4CAF50); // Green
  static const Color accentColor = Color(0xFFFF9800); // Orange

  // Status Colors
  static const Color successColor = Color(0xFF4CAF50); // Green
  static const Color errorColor = Color(0xFFF44336); // Red
  static const Color warningColor = Color(0xFFFFC107); // Amber
  static const Color infoColor = Color(0xFF2196F3); // Blue

  // Neutral Colors
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE0E0E0);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
}

/// App Spacing
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// App Border Radius
class AppBorderRadius {
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double circular = 9999.0;
}

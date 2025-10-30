import 'package:flutter/material.dart';

/// Service for handling navigation from notification taps
class NotificationNavigation {
  static final NotificationNavigation _instance = NotificationNavigation._internal();
  factory NotificationNavigation() => _instance;
  NotificationNavigation._internal();

  /// Global navigator key for navigation without context
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Handle notification tap and navigate to appropriate screen
  void handleNotificationTap(String type, String id) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    switch (type) {
      case 'budget':
        _navigateToBudgetDetails(navigator, id);
        break;
      case 'summary':
        _navigateToTransactions(navigator, id);
        break;
      case 'bill':
        _navigateToRecurring(navigator, id);
        break;
      case 'insight':
        _navigateToInsights(navigator, id);
        break;
      default:
        // Unknown type, do nothing
        break;
    }
  }

  /// Navigate to budget details screen
  void _navigateToBudgetDetails(NavigatorState navigator, String budgetId) {
    // Navigate to budgets tab and show specific budget
    navigator.pushNamed('/budgets', arguments: {'budgetId': budgetId});
  }

  /// Navigate to transactions screen filtered by date
  void _navigateToTransactions(NavigatorState navigator, String dateString) {
    // Parse date and navigate to transactions tab
    try {
      final date = DateTime.parse(dateString);
      navigator.pushNamed('/transactions', arguments: {'date': date});
    } catch (e) {
      // Invalid date, just navigate to transactions
      navigator.pushNamed('/transactions');
    }
  }

  /// Navigate to recurring transactions screen
  void _navigateToRecurring(NavigatorState navigator, String billId) {
    // Navigate to recurring tab (Phase 3B feature)
    navigator.pushNamed('/recurring', arguments: {'billId': billId});
  }

  /// Navigate to insights screen with specific category
  void _navigateToInsights(NavigatorState navigator, String category) {
    // Navigate to insights/analytics screen (Phase 3D feature)
    navigator.pushNamed('/insights', arguments: {'category': category});
  }
}

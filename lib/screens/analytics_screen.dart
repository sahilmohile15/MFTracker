import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/transaction_provider.dart';
import '../providers/budget_provider.dart';
import 'insights_screen.dart';

/// Analytics screen - redirects to full Insights screen with live data
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionListProvider);
    final budgetsAsync = ref.watch(budgetListProvider);

    return transactionsAsync.when(
      data: (transactions) {
        return budgetsAsync.when(
          data: (budgets) {
            // Redirect to the full Insights screen with live data
            return InsightsScreen(
              transactions: transactions,
              budgets: budgets,
            );
          },
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Scaffold(
            appBar: AppBar(title: const Text('Analytics')),
            body: Center(
              child: Text('Error loading budgets: $error'),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Analytics')),
        body: Center(
          child: Text('Error loading transactions: $error'),
        ),
      ),
    );
  }
}

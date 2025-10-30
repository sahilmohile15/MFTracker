import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/transaction_provider.dart';
import '../screens/add_transaction_screen.dart';
import '../screens/edit_transaction_screen.dart';
import '../widgets/transaction_list_view.dart';

/// Transactions list screen with filtering and management
class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: TransactionListView(
        onTransactionTap: (transaction) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  EditTransactionScreen(transaction: transaction),
            ),
          );
        },
        onTransactionEdit: (transaction) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  EditTransactionScreen(transaction: transaction),
            ),
          );
        },
        onTransactionDelete: (transaction) async {
          await ref
              .read(transactionActionsProvider.notifier)
              .deleteTransaction(transaction.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Transaction deleted'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'transactions_fab',  // Unique hero tag
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
      ),
    );
  }
}

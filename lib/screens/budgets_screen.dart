import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/budget_provider.dart';
import '../screens/add_budget_screen.dart';
import '../screens/edit_budget_screen.dart';

/// Screen showing all budgets with progress
class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final budgetProgressAsync = ref.watch(allBudgetProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              refreshBudgets(ref);
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: budgetProgressAsync.when(
        data: (progressList) {
          if (progressList.isEmpty) {
            return _buildEmptyState(context, theme);
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80, top: 8),
            itemCount: progressList.length,
            itemBuilder: (context, index) {
              final progress = progressList[index];
              return _buildBudgetCard(context, ref, theme, progress);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'budgets_fab',  // Unique hero tag
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddBudgetScreen(),
            ),
          );
          // Refresh after returning from add screen
          refreshBudgets(ref);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Budget'),
      ),
    );
  }

  Widget _buildBudgetCard(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    BudgetProgress progress,
  ) {
    if (progress.budget == null) return const SizedBox();
    
    final budget = progress.budget!;
    final percentage = progress.percentage.clamp(0.0, 100.0);

    Color progressColor;
    if (progress.isOverBudget) {
      progressColor = Colors.red[700]!;
    } else if (progress.needsAlert) {
      progressColor = Colors.orange[700]!;
    } else {
      progressColor = Colors.green[700]!;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditBudgetScreen(budget: budget),
            ),
          );
          // Refresh after returning from edit screen
          refreshBudgets(ref);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Category icon
                  if (budget.category != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: budget.category!.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        budget.category!.icon,
                        color: budget.category!.color,
                        size: 24,
                      ),
                    ),
                  const SizedBox(width: 12),

                  // Budget name and period
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          budget.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          budget.period.name,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Amount info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${NumberFormat('#,##0').format(progress.spent)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: progressColor,
                        ),
                      ),
                      Text(
                        'of ₹${NumberFormat('#,##0').format(budget.amount)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (percentage / 100).clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${percentage.toStringAsFixed(1)}% used',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: progressColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        progress.remaining >= 0
                            ? '₹${NumberFormat('#,##0').format(progress.remaining)} left'
                            : '₹${NumberFormat('#,##0').format(progress.remaining.abs())} over',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: progress.remaining >= 0
                              ? theme.colorScheme.onSurfaceVariant
                              : Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Alert badge
              if (progress.needsAlert) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: progress.isOverBudget
                        ? Colors.red[100]
                        : Colors.orange[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        progress.isOverBudget
                            ? Icons.error
                            : Icons.warning,
                        size: 16,
                        color: progress.isOverBudget
                            ? Colors.red[700]
                            : Colors.orange[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        progress.isOverBudget
                            ? 'Over budget!'
                            : 'Approaching limit',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: progress.isOverBudget
                              ? Colors.red[700]
                              : Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No budgets yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a budget to track your spending',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

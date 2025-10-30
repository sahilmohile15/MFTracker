import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';
import '../providers/filter_provider.dart';
import '../widgets/transaction_card.dart';

/// Transaction list view with date grouping
class TransactionListView extends ConsumerStatefulWidget {
  final bool showFilterBar;
  final bool enableSwipeActions;
  final Function(Transaction)? onTransactionTap;
  final Function(Transaction)? onTransactionEdit;
  final Function(Transaction)? onTransactionDelete;

  const TransactionListView({
    super.key,
    this.showFilterBar = true,
    this.enableSwipeActions = true,
    this.onTransactionTap,
    this.onTransactionEdit,
    this.onTransactionDelete,
  });

  @override
  ConsumerState<TransactionListView> createState() =>
      _TransactionListViewState();
}

class _TransactionListViewState extends ConsumerState<TransactionListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filter = ref.watch(filterProvider);
    final filteredTransactions = ref.watch(filteredTransactionsProvider);
    final filteredTotals = ref.watch(filteredTransactionTotalProvider);

    // Group transactions by date
    final groupedTransactions = _groupTransactionsByDate(filteredTransactions);

    return Column(
      children: [
        // Filter bar
        if (widget.showFilterBar) _buildFilterBar(theme, filter),

        // Summary card
        if (filter.hasActiveFilters) _buildSummaryCard(theme, filteredTotals),

        // Transaction list
        Expanded(
          child: filteredTransactions.isEmpty
              ? _buildEmptyState(theme)
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: groupedTransactions.length,
                  itemBuilder: (context, index) {
                    final dateGroup = groupedTransactions[index];
                    return _buildDateGroup(theme, dateGroup);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterBar(ThemeData theme, TransactionFilter filter) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Filter chip
          FilterChip(
            label: Text(
              filter.hasActiveFilters
                  ? 'Filters (${filter.activeFilterCount})'
                  : 'Add Filter',
            ),
            selected: filter.hasActiveFilters,
            onSelected: (_) => _showFilterSheet(context),
            avatar: Icon(
              Icons.filter_list,
              size: 18,
              color: filter.hasActiveFilters
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),

          // Quick filters
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickFilter(theme, 'Today', () {
                    ref.read(filterProvider.notifier).setToday();
                  }),
                  _buildQuickFilter(theme, 'This Week', () {
                    ref.read(filterProvider.notifier).setThisWeek();
                  }),
                  _buildQuickFilter(theme, 'This Month', () {
                    ref.read(filterProvider.notifier).setThisMonth();
                  }),
                ],
              ),
            ),
          ),

          // Clear filters
          if (filter.hasActiveFilters)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                ref.read(filterProvider.notifier).clearAll();
              },
              tooltip: 'Clear filters',
            ),
        ],
      ),
    );
  }

  Widget _buildQuickFilter(
      ThemeData theme, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildSummaryCard(
      ThemeData theme, Map<String, double> totals) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTotalColumn(
            theme,
            'Credit',
            totals['credit'] ?? 0.0,
            Colors.green[700]!,
          ),
          Container(
            height: 40,
            width: 1,
            color: theme.colorScheme.outlineVariant,
          ),
          _buildTotalColumn(
            theme,
            'Debit',
            totals['debit'] ?? 0.0,
            Colors.red[700]!,
          ),
          Container(
            height: 40,
            width: 1,
            color: theme.colorScheme.outlineVariant,
          ),
          _buildTotalColumn(
            theme,
            'Net',
            totals['net'] ?? 0.0,
            (totals['net'] ?? 0.0) >= 0
                ? Colors.green[700]!
                : Colors.red[700]!,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalColumn(
      ThemeData theme, String label, double amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '₹${NumberFormat('#,##0').format(amount.abs())}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDateGroup(ThemeData theme, DateGroup dateGroup) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDateHeader(dateGroup.date),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(
                '${dateGroup.transactions.length} transactions',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        // Transactions
        ...dateGroup.transactions.map((transaction) {
          if (widget.enableSwipeActions) {
            return TransactionListItem(
              transaction: transaction,
              onTap: () => widget.onTransactionTap?.call(transaction),
              onEdit: () => widget.onTransactionEdit?.call(transaction),
              onDelete: () => widget.onTransactionDelete?.call(transaction),
            );
          } else {
            return TransactionCard(
              transaction: transaction,
              onTap: () => widget.onTransactionTap?.call(transaction),
            );
          }
        }),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or add a transaction',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  List<DateGroup> _groupTransactionsByDate(List<Transaction> transactions) {
    final Map<String, List<Transaction>> grouped = {};

    for (final transaction in transactions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(transaction.timestamp);
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(transaction);
    }

    return grouped.entries
        .map((entry) => DateGroup(
              date: DateTime.parse(entry.key),
              transactions: entry.value,
            ))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else if (now.difference(dateOnly).inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else if (date.year == now.year) {
      return DateFormat('MMM d').format(date);
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }
}

/// Date group data class
class DateGroup {
  final DateTime date;
  final List<Transaction> transactions;

  DateGroup({
    required this.date,
    required this.transactions,
  });
}

/// Filter bottom sheet
class FilterBottomSheet extends ConsumerWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filter = ref.watch(filterProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter Transactions',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(filterProvider.notifier).clearAll();
                      },
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              ),

              // Filter options
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Date range filter
                    _buildFilterSection(
                      theme,
                      'Date Range',
                      Icons.calendar_today,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: filter.startDate ?? DateTime.now(),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime.now(),
                                    );
                                    if (date != null) {
                                      ref
                                          .read(filterProvider.notifier)
                                          .setDateRange(date, filter.endDate);
                                    }
                                  },
                                  icon: const Icon(Icons.date_range),
                                  label: Text(
                                    filter.startDate != null
                                        ? DateFormat('MMM d, yyyy')
                                            .format(filter.startDate!)
                                        : 'Start Date',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: filter.endDate ?? DateTime.now(),
                                      firstDate: filter.startDate ?? DateTime(2020),
                                      lastDate: DateTime.now(),
                                    );
                                    if (date != null) {
                                      ref
                                          .read(filterProvider.notifier)
                                          .setDateRange(filter.startDate, date);
                                    }
                                  },
                                  icon: const Icon(Icons.date_range),
                                  label: Text(
                                    filter.endDate != null
                                        ? DateFormat('MMM d, yyyy')
                                            .format(filter.endDate!)
                                        : 'End Date',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Quick date filters
                          Wrap(
                            spacing: 8,
                            children: [
                              FilterChip(
                                label: const Text('Today'),
                                onSelected: (_) {
                                  ref.read(filterProvider.notifier).setToday();
                                },
                              ),
                              FilterChip(
                                label: const Text('This Week'),
                                onSelected: (_) {
                                  ref.read(filterProvider.notifier).setThisWeek();
                                },
                              ),
                              FilterChip(
                                label: const Text('This Month'),
                                onSelected: (_) {
                                  ref.read(filterProvider.notifier).setThisMonth();
                                },
                              ),
                              FilterChip(
                                label: const Text('Last Month'),
                                onSelected: (_) {
                                  ref.read(filterProvider.notifier).setLastMonth();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Amount range filter
                    _buildFilterSection(
                      theme,
                      'Amount Range',
                      Icons.currency_rupee,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'Min Amount',
                                prefixText: '₹',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                final amount = double.tryParse(value);
                                ref
                                    .read(filterProvider.notifier)
                                    .setAmountRange(amount, filter.maxAmount);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'Max Amount',
                                prefixText: '₹',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                final amount = double.tryParse(value);
                                ref
                                    .read(filterProvider.notifier)
                                    .setAmountRange(filter.minAmount, amount);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Search filter
                    _buildFilterSection(
                      theme,
                      'Search',
                      Icons.search,
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search in description or category',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (value) {
                          ref
                              .read(filterProvider.notifier)
                              .setSearchText(value.isEmpty ? null : value);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Apply button
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterSection(
    ThemeData theme,
    String title,
    IconData icon, {
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

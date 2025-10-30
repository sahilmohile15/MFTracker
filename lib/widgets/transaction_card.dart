import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';
import '../providers/account_provider.dart';
import '../utils/constants.dart';

/// Card widget to display a single transaction
class TransactionCard extends ConsumerWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showAccount;
  final bool showDate;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
    this.onLongPress,
    this.showAccount = true,
    this.showDate = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final accountAsync = ref.watch(accountByIdProvider(transaction.accountId));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Category Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: transaction.category.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  transaction.category.icon,
                  color: transaction.category.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Transaction Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    Text(
                      transaction.description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Category & Additional Info
                    Row(
                      children: [
                        Text(
                          transaction.category.name,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (transaction.merchantName != null) ...[
                          Text(
                            ' • ',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              transaction.merchantName!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Account Name & Date
                    if (showAccount || showDate) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (showAccount)
                            accountAsync.when(
                              data: (account) => Text(
                                account?.name ?? 'Unknown Account',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                              loading: () => const SizedBox(),
                              error: (_, __) => const SizedBox(),
                            ),
                          if (showAccount && showDate)
                            Text(
                              ' • ',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                          if (showDate)
                            Text(
                              DateFormat('MMM d, h:mm a')
                                  .format(transaction.timestamp),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Amount & Type
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${transaction.type == TransactionType.credit ? '+' : '-'}₹${NumberFormat('#,##0.00').format(transaction.amount)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: transaction.type == TransactionType.credit
                          ? Colors.green[700]
                          : Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 2),
                  _buildStatusChip(theme),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme) {
    // Show payment method or categorization method
    String? chipText;
    Color? chipColor;

    if (transaction.paymentMethod != null) {
      chipText = transaction.paymentMethod!;
      chipColor = theme.colorScheme.primary;
    } else if (transaction.categorizationMethod == CategorizationMethod.ruleBased) {
      chipText = 'Rule';
      chipColor = theme.colorScheme.tertiary;
    } else if (transaction.categorizationMethod ==
        CategorizationMethod.userCorrected) {
      chipText = 'Manual';
      chipColor = theme.colorScheme.secondary;
    }

    if (chipText == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor?.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        chipText,
        style: theme.textTheme.labelSmall?.copyWith(
          color: chipColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Compact version of transaction card for lists
class TransactionCardCompact extends ConsumerWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionCardCompact({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Category Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: transaction.category.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                transaction.category.icon,
                color: transaction.category.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    DateFormat('MMM d, h:mm a').format(transaction.timestamp),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Amount
            Text(
              '${transaction.type == TransactionType.credit ? '+' : '-'}₹${NumberFormat('#,##0').format(transaction.amount)}',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: transaction.type == TransactionType.credit
                    ? Colors.green[700]
                    : Colors.red[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Transaction list item with swipe actions
class TransactionListItem extends ConsumerWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showAccount;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showAccount = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(transaction.id),
      background: Container(
        color: Colors.blue,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Edit
          onEdit?.call();
          return false;
        } else {
          // Delete
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Transaction'),
              content: const Text(
                  'Are you sure you want to delete this transaction?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
          if (confirm == true) {
            onDelete?.call();
          }
          return confirm ?? false;
        }
      },
      child: TransactionCard(
        transaction: transaction,
        onTap: onTap,
        showAccount: showAccount,
      ),
    );
  }
}

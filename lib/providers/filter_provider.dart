import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction.dart';
import '../utils/constants.dart';
import 'transaction_provider.dart';

/// Filter state class
class TransactionFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final Category? category;
  final double? minAmount;
  final double? maxAmount;
  final List<String>? accountIds;
  final TransactionType? type;
  final String? searchText;
  
  const TransactionFilter({
    this.startDate,
    this.endDate,
    this.category,
    this.minAmount,
    this.maxAmount,
    this.accountIds,
    this.type,
    this.searchText,
  });
  
  TransactionFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    Category? category,
    double? minAmount,
    double? maxAmount,
    List<String>? accountIds,
    TransactionType? type,
    String? searchText,
    bool clearStartDate = false,
    bool clearEndDate = false,
    bool clearCategory = false,
    bool clearMinAmount = false,
    bool clearMaxAmount = false,
    bool clearAccountIds = false,
    bool clearType = false,
    bool clearSearchText = false,
  }) {
    return TransactionFilter(
      startDate: clearStartDate ? null : startDate ?? this.startDate,
      endDate: clearEndDate ? null : endDate ?? this.endDate,
      category: clearCategory ? null : (category ?? this.category),
      minAmount: clearMinAmount ? null : minAmount ?? this.minAmount,
      maxAmount: clearMaxAmount ? null : maxAmount ?? this.maxAmount,
      accountIds: clearAccountIds ? null : (accountIds ?? this.accountIds),
      type: clearType ? null : type ?? this.type,
      searchText: clearSearchText ? null : searchText ?? this.searchText,
    );
  }
  
  /// Check if any filters are active
  bool get hasActiveFilters {
    return startDate != null ||
        endDate != null ||
        category != null ||
        minAmount != null ||
        maxAmount != null ||
        (accountIds != null && accountIds!.isNotEmpty) ||
        type != null ||
        (searchText != null && searchText!.isNotEmpty);
  }
  
  /// Count active filters
  int get activeFilterCount {
    int count = 0;
    if (startDate != null) count++;
    if (endDate != null) count++;
    if (category != null) count++;
    if (minAmount != null) count++;
    if (maxAmount != null) count++;
    if (accountIds != null && accountIds!.isNotEmpty) count++;
    if (type != null) count++;
    if (searchText != null && searchText!.isNotEmpty) count++;
    return count;
  }
  
  /// Apply filters to a list of transactions
  List<Transaction> apply(List<Transaction> transactions) {
    return transactions.where((transaction) {
      // Date filter
      if (startDate != null && transaction.timestamp.isBefore(startDate!)) {
        return false;
      }
      if (endDate != null && transaction.timestamp.isAfter(endDate!.add(const Duration(days: 1)))) {
        return false;
      }
      
      // Category filter
      if (category != null && transaction.category != category) {
        return false;
      }
      
      // Amount filter
      if (minAmount != null && transaction.amount < minAmount!) {
        return false;
      }
      if (maxAmount != null && transaction.amount > maxAmount!) {
        return false;
      }
      
      // Account filter
      if (accountIds != null && accountIds!.isNotEmpty) {
        if (!accountIds!.contains(transaction.accountId)) {
          return false;
        }
      }
      
      // Type filter
      if (type != null && transaction.type != type) {
        return false;
      }
      
      // Search text filter (search in description and category name)
      if (searchText != null && searchText!.isNotEmpty) {
        final searchLower = searchText!.toLowerCase();
        final descriptionMatch = transaction.description.toLowerCase().contains(searchLower);
        final categoryMatch = transaction.category.name.toLowerCase().contains(searchLower);
        if (!descriptionMatch && !categoryMatch) {
          return false;
        }
      }
      
      return true;
    }).toList();
  }
}

/// Filter state notifier
class FilterNotifier extends StateNotifier<TransactionFilter> {
  FilterNotifier() : super(const TransactionFilter());
  
  /// Set date range
  void setDateRange(DateTime? start, DateTime? end) {
    state = state.copyWith(startDate: start, endDate: end);
  }
  
  /// Clear date range
  void clearDateRange() {
    state = state.copyWith(clearStartDate: true, clearEndDate: true);
  }
  
  /// Set category filter
  void setCategory(Category? category) {
    state = state.copyWith(category: category);
  }
  
  /// Clear category filter
  void clearCategory() {
    state = state.copyWith(clearCategory: true);
  }
  
  /// Set amount range
  void setAmountRange(double? min, double? max) {
    state = state.copyWith(minAmount: min, maxAmount: max);
  }
  
  /// Clear amount range
  void clearAmountRange() {
    state = state.copyWith(clearMinAmount: true, clearMaxAmount: true);
  }
  
  /// Set account filter
  void setAccounts(List<String>? accountIds) {
    state = state.copyWith(accountIds: accountIds);
  }
  
  /// Clear account filter
  void clearAccounts() {
    state = state.copyWith(clearAccountIds: true);
  }
  
  /// Set transaction type filter
  void setType(TransactionType? type) {
    state = state.copyWith(type: type);
  }
  
  /// Clear type filter
  void clearType() {
    state = state.copyWith(clearType: true);
  }
  
  /// Set search text
  void setSearchText(String? text) {
    state = state.copyWith(searchText: text);
  }
  
  /// Clear search text
  void clearSearchText() {
    state = state.copyWith(clearSearchText: true);
  }
  
  /// Clear all filters
  void clearAll() {
    state = const TransactionFilter();
  }
  
  /// Set quick filter presets
  void setThisMonth() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    setDateRange(start, end);
  }
  
  void setLastMonth() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - 1, 1);
    final end = DateTime(now.year, now.month, 0, 23, 59, 59);
    setDateRange(start, end);
  }
  
  void setThisWeek() {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    final end = start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    setDateRange(
      DateTime(start.year, start.month, start.day),
      DateTime(end.year, end.month, end.day, 23, 59, 59),
    );
  }
  
  void setLastWeek() {
    final now = DateTime.now();
    final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    final lastWeekEnd = thisWeekStart.subtract(const Duration(days: 1));
    setDateRange(
      DateTime(lastWeekStart.year, lastWeekStart.month, lastWeekStart.day),
      DateTime(lastWeekEnd.year, lastWeekEnd.month, lastWeekEnd.day, 23, 59, 59),
    );
  }
  
  void setToday() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    setDateRange(start, end);
  }
  
  void setYesterday() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final start = DateTime(yesterday.year, yesterday.month, yesterday.day);
    final end = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
    setDateRange(start, end);
  }
}

/// Filter state provider
final filterProvider = StateNotifierProvider.autoDispose<FilterNotifier, TransactionFilter>((ref) {
  return FilterNotifier();
});

/// Filtered transactions provider
final filteredTransactionsProvider = Provider.autoDispose<List<Transaction>>((ref) {
  final filter = ref.watch(filterProvider);
  final transactionsAsync = ref.watch(transactionListProvider);
  
  return transactionsAsync.when(
    data: (transactions) => filter.apply(transactions),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Filtered transactions count
final filteredTransactionCountProvider = Provider.autoDispose<int>((ref) {
  final filtered = ref.watch(filteredTransactionsProvider);
  return filtered.length;
});

/// Filtered transactions total
final filteredTransactionTotalProvider = Provider.autoDispose<Map<String, double>>((ref) {
  final filtered = ref.watch(filteredTransactionsProvider);
  
  double credit = 0.0;
  double debit = 0.0;
  
  for (final transaction in filtered) {
    if (transaction.type == TransactionType.credit) {
      credit += transaction.amount;
    } else {
      debit += transaction.amount;
    }
  }
  
  return {
    'credit': credit,
    'debit': debit,
    'net': credit - debit,
  };
});

/// Available categories from filtered transactions
final availableCategoriesProvider = Provider.autoDispose<List<Category>>((ref) {
  final filtered = ref.watch(filteredTransactionsProvider);
  final categories = filtered.map((t) => t.category).toSet().toList();
  categories.sort((a, b) => a.name.compareTo(b.name));
  return categories;
});

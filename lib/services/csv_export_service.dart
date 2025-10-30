import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../utils/constants.dart';

/// Service for exporting transactions to CSV format
class CsvExportService {
  static final CsvExportService _instance = CsvExportService._internal();
  factory CsvExportService() => _instance;
  CsvExportService._internal();

  /// Export transactions to CSV file
  Future<File> exportTransactions({
    required List<Transaction> transactions,
    required String filePath,
    bool includeHeaders = true,
  }) async {
    final currencyFormatter = NumberFormat('#,##0.00');
    
    // Build CSV data
    final List<List<dynamic>> rows = [];
    
    // Add headers
    if (includeHeaders) {
      rows.add([
        'Date',
        'Time',
        'Description',
        'Merchant',
        'Category',
        'Type',
        'Amount',
        'Account Number',
        'Payment Method',
        'UPI ID',
        'Transaction ID',
        'Notes',
      ]);
    }
    
    // Add transaction data
    for (final transaction in transactions) {
      final dateTime = transaction.timestamp;
      final isDebit = transaction.type == TransactionType.debit;
      
      rows.add([
        DateFormat('yyyy-MM-dd').format(dateTime),
        DateFormat('HH:mm:ss').format(dateTime),
        transaction.description,
        transaction.merchantName ?? '',
        transaction.category.name,
        isDebit ? 'Expense' : 'Income',
        currencyFormatter.format(transaction.amount),
        transaction.accountNumber ?? '',
        transaction.paymentMethod ?? '',
        transaction.upiId ?? '',
        transaction.upiTransactionId ?? '',
        transaction.notes ?? '',
      ]);
    }
    
    // Convert to CSV string
    final csvString = const ListToCsvConverter().convert(rows);
    
    // Write to file
    final file = File(filePath);
    await file.writeAsString(csvString);
    
    return file;
  }

  /// Export summary data to CSV
  Future<File> exportSummary({
    required Map<String, double> categoryTotals,
    required String filePath,
    double? totalIncome,
    double? totalExpense,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final dateFormatter = DateFormat('yyyy-MM-dd');
    final currencyFormatter = NumberFormat('#,##0.00');
    
    final List<List<dynamic>> rows = [];
    
    // Add metadata
    rows.add(['Transaction Summary Report']);
    rows.add(['Generated', DateTime.now().toString()]);
    
    if (startDate != null) {
      rows.add(['Start Date', dateFormatter.format(startDate)]);
    }
    if (endDate != null) {
      rows.add(['End Date', dateFormatter.format(endDate)]);
    }
    
    rows.add([]); // Empty row
    
    // Add totals
    if (totalIncome != null) {
      rows.add(['Total Income', currencyFormatter.format(totalIncome)]);
    }
    if (totalExpense != null) {
      rows.add(['Total Expense', currencyFormatter.format(totalExpense)]);
    }
    if (totalIncome != null && totalExpense != null) {
      rows.add(['Net Balance', currencyFormatter.format(totalIncome - totalExpense)]);
    }
    
    rows.add([]); // Empty row
    
    // Add category breakdown
    rows.add(['Category', 'Amount', 'Percentage']);
    
    final totalSpending = categoryTotals.values.fold(0.0, (sum, value) => sum + value);
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    for (final entry in sortedCategories) {
      final percentage = totalSpending > 0 
          ? (entry.value / totalSpending) * 100 
          : 0.0;
      
      rows.add([
        entry.key,
        currencyFormatter.format(entry.value),
        '${percentage.toStringAsFixed(2)}%',
      ]);
    }
    
    // Convert to CSV
    final csvString = const ListToCsvConverter().convert(rows);
    
    // Write to file
    final file = File(filePath);
    await file.writeAsString(csvString);
    
    return file;
  }

  /// Export monthly summary to CSV
  Future<File> exportMonthlySummary({
    required Map<int, Map<String, double>> monthlyData,
    required String filePath,
  }) async {
    final currencyFormatter = NumberFormat('#,##0.00');
    
    final List<List<dynamic>> rows = [];
    
    // Add headers
    rows.add(['Month', 'Income', 'Expense', 'Net Balance', 'Transaction Count']);
    
    // Sort by month
    final sortedMonths = monthlyData.keys.toList()..sort();
    
    for (final month in sortedMonths) {
      final data = monthlyData[month]!;
      final income = data['income'] ?? 0;
      final expense = data['expense'] ?? 0;
      final netBalance = income - expense;
      final count = data['count']?.toInt() ?? 0;
      
      rows.add([
        DateFormat('MMM yyyy').format(DateTime(2024, month)),
        currencyFormatter.format(income),
        currencyFormatter.format(expense),
        currencyFormatter.format(netBalance),
        count,
      ]);
    }
    
    // Convert and write
    final csvString = const ListToCsvConverter().convert(rows);
    final file = File(filePath);
    await file.writeAsString(csvString);
    
    return file;
  }
}

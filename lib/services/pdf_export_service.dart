import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../utils/constants.dart';

/// Service for exporting transactions to PDF format
class PdfExportService {
  static final PdfExportService _instance = PdfExportService._internal();
  factory PdfExportService() => _instance;
  PdfExportService._internal();

  /// Generate PDF report from transactions
  Future<File> generateTransactionReport({
    required List<Transaction> transactions,
    required String filePath,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final pdf = pw.Document();
    
    final dateFormatter = DateFormat('MMM dd, yyyy');
    final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    
    // Calculate totals
    double totalExpense = 0;
    double totalIncome = 0;
    
    for (final transaction in transactions) {
      if (transaction.type == TransactionType.debit) {
        totalExpense += transaction.amount;
      } else {
        totalIncome += transaction.amount;
      }
    }
    
    final netBalance = totalIncome - totalExpense;

    // Build PDF pages
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            _buildHeader(
              title ?? 'Transaction Report',
              startDate,
              endDate,
              dateFormatter,
            ),
            pw.SizedBox(height: 20),
            
            // Summary section
            _buildSummary(
              totalIncome,
              totalExpense,
              netBalance,
              transactions.length,
              currencyFormatter,
            ),
            pw.SizedBox(height: 20),
            
            // Transactions table
            _buildTransactionsTable(
              transactions,
              dateFormatter,
              currencyFormatter,
            ),
            
            // Footer
            pw.SizedBox(height: 20),
            _buildFooter(),
          ];
        },
      ),
    );

    // Save to file
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }

  /// Build PDF header
  pw.Widget _buildHeader(
    String title,
    DateTime? startDate,
    DateTime? endDate,
    DateFormat dateFormatter,
  ) {
    String subtitle = 'All Transactions';
    if (startDate != null && endDate != null) {
      subtitle = '${dateFormatter.format(startDate)} - ${dateFormatter.format(endDate)}';
    } else if (startDate != null) {
      subtitle = 'From ${dateFormatter.format(startDate)}';
    } else if (endDate != null) {
      subtitle = 'Until ${dateFormatter.format(endDate)}';
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          subtitle,
          style: const pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Divider(thickness: 2),
      ],
    );
  }

  /// Build summary section
  pw.Widget _buildSummary(
    double totalIncome,
    double totalExpense,
    double netBalance,
    int transactionCount,
    NumberFormat currencyFormatter,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            'Total Income',
            currencyFormatter.format(totalIncome),
            PdfColors.green,
          ),
          _buildSummaryItem(
            'Total Expense',
            currencyFormatter.format(totalExpense),
            PdfColors.red,
          ),
          _buildSummaryItem(
            'Net Balance',
            currencyFormatter.format(netBalance),
            netBalance >= 0 ? PdfColors.green : PdfColors.red,
          ),
          _buildSummaryItem(
            'Transactions',
            transactionCount.toString(),
            PdfColors.blue,
          ),
        ],
      ),
    );
  }

  /// Build summary item
  pw.Widget _buildSummaryItem(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// Build transactions table
  pw.Widget _buildTransactionsTable(
    List<Transaction> transactions,
    DateFormat dateFormatter,
    NumberFormat currencyFormatter,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(2), // Date
        1: const pw.FlexColumnWidth(3), // Description
        2: const pw.FlexColumnWidth(2), // Category
        3: const pw.FlexColumnWidth(1.5), // Type
        4: const pw.FlexColumnWidth(2), // Amount
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColors.grey200,
          ),
          children: [
            _buildTableCell('Date', isHeader: true),
            _buildTableCell('Description', isHeader: true),
            _buildTableCell('Category', isHeader: true),
            _buildTableCell('Type', isHeader: true),
            _buildTableCell('Amount', isHeader: true, align: pw.TextAlign.right),
          ],
        ),
        
        // Data rows
        ...transactions.map((transaction) {
          final isDebit = transaction.type == TransactionType.debit;
          
          return pw.TableRow(
            children: [
              _buildTableCell(dateFormatter.format(transaction.timestamp)),
              _buildTableCell(
                transaction.merchantName ?? transaction.description,
                maxLines: 2,
              ),
              _buildTableCell(transaction.category.name),
              _buildTableCell(
                isDebit ? 'Expense' : 'Income',
                color: isDebit ? PdfColors.red : PdfColors.green,
              ),
              _buildTableCell(
                currencyFormatter.format(transaction.amount),
                align: pw.TextAlign.right,
                color: isDebit ? PdfColors.red : PdfColors.green,
              ),
            ],
          );
        }),
      ],
    );
  }

  /// Build table cell
  pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    pw.TextAlign align = pw.TextAlign.left,
    PdfColor? color,
    int maxLines = 1,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color ?? (isHeader ? PdfColors.black : PdfColors.grey800),
        ),
        textAlign: align,
        maxLines: maxLines,
        overflow: pw.TextOverflow.clip,
      ),
    );
  }

  /// Build footer
  pw.Widget _buildFooter() {
    final now = DateTime.now();
    final formatter = DateFormat('MMM dd, yyyy HH:mm');
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(),
        pw.Text(
          'Generated by MFTracker on ${formatter.format(now)}',
          style: const pw.TextStyle(
            fontSize: 8,
            color: PdfColors.grey600,
          ),
        ),
      ],
    );
  }

  /// Generate category-wise spending report
  Future<File> generateCategoryReport({
    required Map<String, double> categoryTotals,
    required String filePath,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final pdf = pw.Document();
    final dateFormatter = DateFormat('MMM dd, yyyy');
    final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final totalSpending = categoryTotals.values.fold(0.0, (sum, value) => sum + value);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(
                'Category-wise Spending Report',
                startDate,
                endDate,
                dateFormatter,
              ),
              pw.SizedBox(height: 20),
              
              // Total spending
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      'Total Spending: ',
                      style: const pw.TextStyle(fontSize: 16),
                    ),
                    pw.Text(
                      currencyFormatter.format(totalSpending),
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.red,
                      ),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Category breakdown
              ...sortedCategories.map((entry) {
                final percentage = (entry.value / totalSpending) * 100;
                
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 12),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            entry.key,
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            '${currencyFormatter.format(entry.value)} (${percentage.toStringAsFixed(1)}%)',
                            style: const pw.TextStyle(
                              fontSize: 12,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Stack(
                        children: [
                          pw.Container(
                            height: 8,
                            decoration: pw.BoxDecoration(
                              color: PdfColors.grey200,
                              borderRadius: pw.BorderRadius.circular(4),
                            ),
                          ),
                          pw.Container(
                            height: 8,
                            width: (percentage / 100) * 500, // Approximate page width
                            decoration: pw.BoxDecoration(
                              color: PdfColors.blue,
                              borderRadius: pw.BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              
              pw.Spacer(),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }
}

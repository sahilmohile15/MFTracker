import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../models/transaction.dart';
import '../services/pdf_export_service.dart';
import '../services/csv_export_service.dart';
import '../utils/constants.dart';

enum ExportFormat { pdf, csv }

enum ExportType { transactions, summary, monthly }

class ExportScreen extends StatefulWidget {
  final List<Transaction> transactions;

  const ExportScreen({
    super.key,
    required this.transactions,
  });

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  ExportFormat _selectedFormat = ExportFormat.pdf;
  ExportType _selectedType = ExportType.transactions;
  
  DateTimeRange? _dateRange;
  List<Category>? _selectedCategories;
  
  bool _isExporting = false;
  File? _lastExportedFile;

  @override
  void initState() {
    super.initState();
    // Default to last 30 days
    final now = DateTime.now();
    _dateRange = DateTimeRange(
      start: DateTime(now.year, now.month - 1, now.day),
      end: now,
    );
  }

  List<Transaction> get _filteredTransactions {
    var transactions = widget.transactions;
    
    // Filter by date range
    if (_dateRange != null) {
      transactions = transactions.where((t) {
        return t.timestamp.isAfter(_dateRange!.start) &&
               t.timestamp.isBefore(_dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }
    
    // Filter by categories
    if (_selectedCategories != null && _selectedCategories!.isNotEmpty) {
      transactions = transactions.where((t) {
        return _selectedCategories!.contains(t.category);
      }).toList();
    }
    
    return transactions;
  }

  Future<void> _exportTransactions() async {
    setState(() => _isExporting = true);
    
    try {
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final extension = _selectedFormat == ExportFormat.pdf ? 'pdf' : 'csv';
      final filePath = '${dir.path}/transactions_$timestamp.$extension';
      
      File file;
      
      if (_selectedFormat == ExportFormat.pdf) {
        file = await PdfExportService().generateTransactionReport(
          transactions: _filteredTransactions,
          filePath: filePath,
          startDate: _dateRange?.start,
          endDate: _dateRange?.end,
        );
      } else {
        file = await CsvExportService().exportTransactions(
          transactions: _filteredTransactions,
          filePath: filePath,
        );
      }
      
      setState(() {
        _lastExportedFile = file;
        _isExporting = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported ${_filteredTransactions.length} transactions'),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () => _openFile(file),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isExporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _exportSummary() async {
    setState(() => _isExporting = true);
    
    try {
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final extension = _selectedFormat == ExportFormat.pdf ? 'pdf' : 'csv';
      final filePath = '${dir.path}/summary_$timestamp.$extension';
      
      // Calculate totals
      final totalIncome = _filteredTransactions
          .where((t) => t.type == TransactionType.credit)
          .fold(0.0, (sum, t) => sum + t.amount);
      
      final totalExpense = _filteredTransactions
          .where((t) => t.type == TransactionType.debit)
          .fold(0.0, (sum, t) => sum + t.amount);
      
      // Category totals
      final categoryTotals = <String, double>{};
      for (final transaction in _filteredTransactions) {
        if (transaction.type == TransactionType.debit) {
          categoryTotals[transaction.category.name] = 
              (categoryTotals[transaction.category.name] ?? 0) + transaction.amount;
        }
      }
      
      File file;
      
      if (_selectedFormat == ExportFormat.pdf) {
        file = await PdfExportService().generateCategoryReport(
          categoryTotals: categoryTotals,
          filePath: filePath,
          startDate: _dateRange?.start,
          endDate: _dateRange?.end,
        );
      } else {
        file = await CsvExportService().exportSummary(
          categoryTotals: categoryTotals,
          filePath: filePath,
          totalIncome: totalIncome,
          totalExpense: totalExpense,
          startDate: _dateRange?.start,
          endDate: _dateRange?.end,
        );
      }
      
      setState(() {
        _lastExportedFile = file;
        _isExporting = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Summary exported'),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () => _openFile(file),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isExporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _openFile(File file) async {
    await OpenFilex.open(file.path);
  }

  Future<void> _shareFile(File file) async {
    final result = await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: 'Transaction Export',
      ),
    );
    // Handle result if needed  
    if (mounted && result.status == ShareResultStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File shared successfully')),
      );
    }
  }

  Future<void> _printPdf(File file) async {
    if (_selectedFormat == ExportFormat.pdf) {
      final bytes = await file.readAsBytes();
      await Printing.layoutPdf(
        onLayout: (_) => bytes,
      );
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    
    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  Future<void> _selectCategories() async {
    final allCategories = Category.values;
    final selected = await showDialog<List<Category>>(
      context: context,
      builder: (context) {
        return _CategorySelectionDialog(
          initialSelection: _selectedCategories ?? [],
          allCategories: allCategories,
        );
      },
    );
    
    if (selected != null) {
      setState(() => _selectedCategories = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Transactions'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Export format selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Export Format',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<ExportFormat>(
                      segments: const [
                        ButtonSegment(
                          value: ExportFormat.pdf,
                          label: Text('PDF'),
                          icon: Icon(Icons.picture_as_pdf),
                        ),
                        ButtonSegment(
                          value: ExportFormat.csv,
                          label: Text('CSV'),
                          icon: Icon(Icons.table_chart),
                        ),
                      ],
                      selected: {_selectedFormat},
                      onSelectionChanged: (Set<ExportFormat> selected) {
                        setState(() => _selectedFormat = selected.first);
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Export type selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Export Type',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<ExportType>(
                      segments: const [
                        ButtonSegment(
                          value: ExportType.transactions,
                          label: Text('Transactions'),
                        ),
                        ButtonSegment(
                          value: ExportType.summary,
                          label: Text('Summary'),
                        ),
                      ],
                      selected: {_selectedType},
                      onSelectionChanged: (Set<ExportType> selected) {
                        setState(() => _selectedType = selected.first);
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Filters
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filters',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    
                    // Date range
                    ListTile(
                      leading: const Icon(Icons.date_range),
                      title: const Text('Date Range'),
                      subtitle: Text(
                        _dateRange == null
                            ? 'All time'
                            : '${DateFormat.yMMMd().format(_dateRange!.start)} - ${DateFormat.yMMMd().format(_dateRange!.end)}',
                      ),
                      trailing: const Icon(Icons.edit),
                      onTap: _selectDateRange,
                    ),
                    
                    const Divider(),
                    
                    // Categories
                    ListTile(
                      leading: const Icon(Icons.category),
                      title: const Text('Categories'),
                      subtitle: Text(
                        _selectedCategories == null || _selectedCategories!.isEmpty
                            ? 'All categories'
                            : '${_selectedCategories!.length} selected',
                      ),
                      trailing: const Icon(Icons.edit),
                      onTap: _selectCategories,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Preview info
            Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${_filteredTransactions.length} transactions will be exported',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Export button
            FilledButton.icon(
              onPressed: _isExporting ? null : () {
                if (_selectedType == ExportType.transactions) {
                  _exportTransactions();
                } else {
                  _exportSummary();
                }
              },
              icon: _isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download),
              label: Text(_isExporting ? 'Exporting...' : 'Export'),
            ),
            
            // Action buttons (if file exists)
            if (_lastExportedFile != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openFile(_lastExportedFile!),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Open'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _shareFile(_lastExportedFile!),
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                    ),
                  ),
                  if (_selectedFormat == ExportFormat.pdf) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _printPdf(_lastExportedFile!),
                        icon: const Icon(Icons.print),
                        label: const Text('Print'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategorySelectionDialog extends StatefulWidget {
  final List<Category> initialSelection;
  final List<Category> allCategories;

  const _CategorySelectionDialog({
    required this.initialSelection,
    required this.allCategories,
  });

  @override
  State<_CategorySelectionDialog> createState() => _CategorySelectionDialogState();
}

class _CategorySelectionDialogState extends State<_CategorySelectionDialog> {
  late Set<Category> _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelection.toSet();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Categories'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.allCategories.length,
          itemBuilder: (context, index) {
            final category = widget.allCategories[index];
            final isSelected = _selected.contains(category);
            
            return CheckboxListTile(
              title: Text(category.name),
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selected.add(category);
                  } else {
                    _selected.remove(category);
                  }
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            setState(() => _selected.clear());
          },
          child: const Text('Clear All'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _selected.toList()),
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

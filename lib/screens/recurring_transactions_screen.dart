import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/recurring_transaction.dart';
import '../services/recurring_detection_service.dart';

/// Screen to display detected recurring transactions
class RecurringTransactionsScreen extends StatefulWidget {
  const RecurringTransactionsScreen({super.key});

  @override
  State<RecurringTransactionsScreen> createState() =>
      _RecurringTransactionsScreenState();
}

class _RecurringTransactionsScreenState
    extends State<RecurringTransactionsScreen> {
  final RecurringDetectionService _detectionService =
      RecurringDetectionService();

  List<RecurringPattern>? _patterns;
  List<Map<String, dynamic>>? _upcomingTransactions;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecurringPatterns();
  }

  Future<void> _loadRecurringPatterns() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final patterns = await _detectionService.detectRecurringPatterns();
      final upcoming = await _detectionService.getUpcomingRecurring();

      setState(() {
        _patterns = patterns;
        _upcomingTransactions = upcoming;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecurringPatterns,
            tooltip: 'Refresh patterns',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : _buildContentView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $_error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadRecurringPatterns,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContentView() {
    final patterns = _patterns ?? [];
    final upcoming = _upcomingTransactions ?? [];

    if (patterns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No recurring patterns detected',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'We need at least 3 similar transactions to detect patterns',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadRecurringPatterns,
              icon: const Icon(Icons.refresh),
              label: const Text('Scan Again'),
            ),
          ],
        ),
      );
    }

    return ListView(
      children: [
        if (upcoming.isNotEmpty) ...[
          _buildSectionHeader('Upcoming (Next 30 Days)', upcoming.length),
          ...upcoming.map((item) => _buildUpcomingCard(item)),
          const SizedBox(height: 16),
        ],
        _buildSectionHeader('Detected Patterns', patterns.length),
        ...patterns.map((pattern) => _buildPatternCard(pattern)),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingCard(Map<String, dynamic> item) {
    final merchant = item['merchant'] as String;
    final amount = item['amount'] as double;
    final nextDate = item['nextDate'] as DateTime;
    final frequency = item['frequency'] as String;
    final confidence = item['confidence'] as double;

    final daysUntil = nextDate.difference(DateTime.now()).inDays;
    final dateFormatter = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getColorForDaysUntil(daysUntil),
          child: Text(
            daysUntil.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          merchant,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('₹${amount.toStringAsFixed(0)} · $frequency'),
            Text(
              'Expected: ${dateFormatter.format(nextDate)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_outlined),
            Text(
              '${(confidence * 100).toInt()}%',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternCard(RecurringPattern pattern) {
    final dateFormatter = DateFormat('MMM dd, yyyy');
    final nextDate =
        _detectionService.predictNextOccurrence(pattern);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: _getFrequencyIcon(pattern.frequency),
        title: Text(
          pattern.merchantPattern,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '₹${pattern.avgAmount.toStringAsFixed(0)} · ${pattern.frequency.displayName}',
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildConfidenceBadge(pattern.confidence),
                const SizedBox(width: 8),
                Text(
                  '${pattern.occurrences.length} occurrences',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Category', pattern.category),
                _buildInfoRow(
                  'Last seen',
                  dateFormatter.format(pattern.occurrences.last),
                ),
                _buildInfoRow(
                  'Next expected',
                  dateFormatter.format(nextDate),
                ),
                _buildInfoRow(
                  'Confidence',
                  '${(pattern.confidence * 100).toInt()}%',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Transaction History:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: pattern.occurrences
                      .map((date) => Chip(
                            label: Text(
                              DateFormat('MMM dd').format(date),
                              style: const TextStyle(fontSize: 11),
                            ),
                            backgroundColor: Colors.grey.shade200,
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceBadge(double confidence) {
    final percentage = (confidence * 100).toInt();
    final color = confidence >= 0.8
        ? Colors.green
        : confidence >= 0.6
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        '$percentage% match',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _getFrequencyIcon(RecurringFrequency frequency) {
    IconData icon;
    Color color;

    switch (frequency) {
      case RecurringFrequency.weekly:
        icon = Icons.calendar_view_week;
        color = Colors.blue;
        break;
      case RecurringFrequency.biweekly:
        icon = Icons.calendar_view_week;
        color = Colors.indigo;
        break;
      case RecurringFrequency.monthly:
        icon = Icons.calendar_month;
        color = Colors.purple;
        break;
      case RecurringFrequency.quarterly:
        icon = Icons.calendar_today;
        color = Colors.orange;
        break;
      case RecurringFrequency.yearly:
        icon = Icons.event_repeat;
        color = Colors.red;
        break;
    }

    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.1),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Color _getColorForDaysUntil(int days) {
    if (days <= 3) return Colors.red;
    if (days <= 7) return Colors.orange;
    if (days <= 14) return Colors.blue;
    return Colors.green;
  }
}

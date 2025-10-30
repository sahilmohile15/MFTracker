import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/budget.dart';
import '../services/insights_service.dart';

enum TimeRange { week, month, quarter, year }

class InsightsScreen extends StatefulWidget {
  final List<Transaction> transactions;
  final List<Budget> budgets;

  const InsightsScreen({
    super.key,
    required this.transactions,
    this.budgets = const [],
  });

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final _insightsService = InsightsService();
  TimeRange _selectedRange = TimeRange.month;

  DateTimeRange get _dateRange {
    final now = DateTime.now();
    switch (_selectedRange) {
      case TimeRange.week:
        return DateTimeRange(
          start: now.subtract(const Duration(days: 7)),
          end: now,
        );
      case TimeRange.month:
        return DateTimeRange(
          start: DateTime(now.year, now.month - 1, now.day),
          end: now,
        );
      case TimeRange.quarter:
        return DateTimeRange(
          start: DateTime(now.year, now.month - 3, now.day),
          end: now,
        );
      case TimeRange.year:
        return DateTimeRange(
          start: DateTime(now.year - 1, now.month, now.day),
          end: now,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transactions = widget.transactions;
    final budgets = widget.budgets;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Time range selector
            _buildTimeRangeSelector(theme),
            
            // Spending trend card
            _buildSpendingTrendCard(transactions, theme),
            
            // Monthly comparison chart
            _buildMonthlyComparisonChart(transactions, theme),
            
            // Category breakdown pie chart
            _buildCategoryPieChart(transactions, theme),
            
            // Budget performance
            if (budgets.isNotEmpty)
              _buildBudgetPerformance(transactions, budgets, theme),
            
            // Spending forecast
            _buildSpendingForecast(transactions, theme),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRangeSelector(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: TimeRange.values.map((range) {
          final isSelected = _selectedRange == range;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedRange = range),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  range.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSpendingTrendCard(List<Transaction> transactions, ThemeData theme) {
    final trend = _insightsService.calculateSpendingTrend(
      transactions: transactions,
      startDate: _dateRange.start,
      endDate: _dateRange.end,
    );

    final isIncrease = trend.change > 0;
    final trendColor = isIncrease ? Colors.red : Colors.green;
    final trendIcon = isIncrease ? Icons.trending_up : Icons.trending_down;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending Trend',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Period',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        NumberFormat.currency(symbol: '₹', decimalDigits: 0)
                            .format(trend.currentPeriodSpending),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: trendColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(trendIcon, color: trendColor, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${trend.percentChange.abs().toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: trendColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Previous Period: ${NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(trend.previousPeriodSpending)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            Text(
              '${trend.transactionCount} transactions',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyComparisonChart(List<Transaction> transactions, ThemeData theme) {
    final comparisons = _insightsService.calculateMonthlyComparison(
      transactions: transactions,
      monthCount: 6,
    );

    if (comparisons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Comparison',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: comparisons.map((c) => c.expense).reduce((a, b) => a > b ? a : b) * 1.2,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final comparison = comparisons[groupIndex];
                        return BarTooltipItem(
                          '${DateFormat.MMM().format(comparison.month)}\n',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(rod.toY),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= comparisons.length) {
                            return const SizedBox();
                          }
                          final month = comparisons[value.toInt()].month;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat.MMM().format(month),
                              style: theme.textTheme.bodySmall,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${(value / 1000).toStringAsFixed(0)}k',
                            style: theme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 5000,
                  ),
                  barGroups: comparisons.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.expense,
                          color: theme.colorScheme.primary,
                          width: 16,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPieChart(List<Transaction> transactions, ThemeData theme) {
    final insights = _insightsService.calculateCategoryInsights(
      transactions: transactions,
      startDate: _dateRange.start,
      endDate: _dateRange.end,
    );

    if (insights.isEmpty) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text(
              'No spending data for this period',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      );
    }

    final topInsights = insights.take(5).toList();
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      Colors.orange,
      Colors.purple,
    ];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Breakdown',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                // Pie chart
                SizedBox(
                  width: 150,
                  height: 150,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: topInsights.asMap().entries.map((entry) {
                        final index = entry.key;
                        final insight = entry.value;
                        return PieChartSectionData(
                          value: insight.amount,
                          title: '${insight.percentage.toStringAsFixed(0)}%',
                          color: colors[index % colors.length],
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Legend
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: topInsights.asMap().entries.map((entry) {
                      final index = entry.key;
                      final insight = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: colors[index % colors.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    insight.category.name,
                                    style: theme.textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    NumberFormat.currency(symbol: '₹', decimalDigits: 0)
                                        .format(insight.amount),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetPerformance(
    List<Transaction> transactions,
    List<Budget> budgets,
    ThemeData theme,
  ) {
    final performance = _insightsService.calculateBudgetPerformance(
      budgets: budgets,
      transactions: transactions,
    );

    if (performance.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Budget Performance',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...performance.map((perf) {
              final percentUsed = perf.percentUsed.clamp(0, 100);
              final isOverBudget = perf.percentUsed > 100;
              final color = isOverBudget
                  ? Colors.red
                  : perf.isOnTrack
                      ? Colors.green
                      : Colors.orange;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          perf.budget.category?.name ?? 'Overall',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              perf.isOnTrack ? Icons.check_circle : Icons.warning,
                              size: 16,
                              color: color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(perf.spent)} / ${NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(perf.budget.amount)}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentUsed / 100,
                        minHeight: 8,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${percentUsed.toStringAsFixed(0)}% used',
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(
                          '${perf.daysRemaining} days left',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingForecast(List<Transaction> transactions, ThemeData theme) {
    final forecast = _insightsService.predictNextMonthSpending(
      transactions: transactions,
    );

    if (forecast.predictedAmount == 0) {
      return const SizedBox.shrink();
    }

    final trendColor = forecast.trend == ForecastTrend.increasing
        ? Colors.red
        : forecast.trend == ForecastTrend.decreasing
            ? Colors.green
            : Colors.blue;

    final trendIcon = forecast.trend == ForecastTrend.increasing
        ? Icons.trending_up
        : forecast.trend == ForecastTrend.decreasing
            ? Icons.trending_down
            : Icons.trending_flat;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Spending Forecast',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Month Prediction',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        NumberFormat.currency(symbol: '₹', decimalDigits: 0)
                            .format(forecast.predictedAmount),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: trendColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(trendIcon, color: trendColor, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        forecast.trend.name.toUpperCase(),
                        style: TextStyle(
                          color: trendColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Confidence: ',
                  style: theme.textTheme.bodySmall,
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: forecast.confidence / 100,
                      minHeight: 6,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      color: forecast.confidence >= 70
                          ? Colors.green
                          : forecast.confidence >= 50
                              ? Colors.orange
                              : Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${forecast.confidence.toStringAsFixed(0)}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Based on 6-month spending pattern analysis',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Insights'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Spending Trend',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Compares your spending in the current period vs the previous period of the same duration.',
              ),
              SizedBox(height: 12),
              Text(
                'Monthly Comparison',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Shows your expenses over the last 6 months to identify patterns.',
              ),
              SizedBox(height: 12),
              Text(
                'Category Breakdown',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Visualizes your top 5 spending categories with percentages.',
              ),
              SizedBox(height: 12),
              Text(
                'Budget Performance',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Tracks your progress against active budgets and shows if you\'re on track.',
              ),
              SizedBox(height: 12),
              Text(
                'Spending Forecast',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Uses machine learning to predict next month\'s spending based on your historical patterns.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

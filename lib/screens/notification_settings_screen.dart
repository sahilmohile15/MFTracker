import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_manager.dart';
import '../services/background_task_manager.dart';

/// Screen for configuring notification preferences
class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  final NotificationManager _notificationManager = NotificationManager();
  final BackgroundTaskManager _backgroundTaskManager = BackgroundTaskManager();

  // Settings state
  bool _budgetAlertsEnabled = true;
  bool _dailySummariesEnabled = false;
  bool _billRemindersEnabled = true;
  bool _insightsEnabled = true;
  
  int _quietHoursStart = 22; // 10 PM
  int _quietHoursEnd = 7; // 7 AM
  
  TimeOfDay _dailySummaryTime = const TimeOfDay(hour: 21, minute: 0); // 9 PM

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final budgetAlerts = await _notificationManager.areBudgetAlertsEnabled();
    final dailySummaries = await _notificationManager.areDailySummariesEnabled();
    final billReminders = await _notificationManager.areBillRemindersEnabled();
    final insights = await _notificationManager.areInsightsEnabled();
    final (startHour, endHour) = await _notificationManager.getQuietHours();

    if (mounted) {
      setState(() {
        _budgetAlertsEnabled = budgetAlerts;
        _dailySummariesEnabled = dailySummaries;
        _billRemindersEnabled = billReminders;
        _insightsEnabled = insights;
        _quietHoursStart = startHour;
        _quietHoursEnd = endHour;
      });
    }
  }

  Future<void> _showTestNotification() async {
    // Request permission first (important for iOS)
    final hasPermission = await _notificationManager.requestPermission();
    
    if (!hasPermission && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enable notifications in device settings'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show a test notification
    await _notificationManager.showUnusualSpendingAlert(
      message: 'This is a test notification from MFTracker!',
      category: 'Test',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test notification sent! Check your notification tray'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        children: [
          _buildSection(
            icon: Icons.notifications_active,
            title: 'Budget Alerts',
            subtitle: 'Get notified when approaching budget limits',
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Enable Budget Alerts'),
                  subtitle: const Text('Alerts at 50%, 75%, 90%, 100%'),
                  value: _budgetAlertsEnabled,
                  onChanged: (value) async {
                    setState(() => _budgetAlertsEnabled = value);
                    await _notificationManager.setBudgetAlertsEnabled(value);
                  },
                ),
                if (_budgetAlertsEnabled) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'You\'ll receive notifications when you reach:',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  _buildThresholdChip('50%', '🔵 Reminder', Colors.blue),
                  _buildThresholdChip('75%', '🟡 Update', Colors.orange),
                  _buildThresholdChip('90%', '🟠 Warning', Colors.deepOrange),
                  _buildThresholdChip('100%', '🔴 Exceeded', Colors.red),
                ],
              ],
            ),
          ),
          
          _buildSection(
            icon: Icons.summarize,
            title: 'Daily Summary',
            subtitle: 'End-of-day spending overview',
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Enable Daily Summary'),
                  subtitle: const Text('Get a summary of your daily spending'),
                  value: _dailySummariesEnabled,
                  onChanged: (value) async {
                    setState(() => _dailySummariesEnabled = value);
                    await _notificationManager.setDailySummariesEnabled(value);
                    
                    if (value) {
                      // Schedule the daily summary with WorkManager
                      await _backgroundTaskManager.scheduleDailySummary(
                        hour: _dailySummaryTime.hour,
                        minute: _dailySummaryTime.minute,
                      );
                    } else {
                      // Cancel the scheduled task
                      await _backgroundTaskManager.cancelDailySummary();
                    }
                  },
                ),
                if (_dailySummariesEnabled)
                  ListTile(
                    title: const Text('Summary Time'),
                    subtitle: Text(
                      _dailySummaryTime.format(context),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _dailySummaryTime,
                      );
                      
                      if (time != null) {
                        setState(() => _dailySummaryTime = time);
                        // Update the scheduled time with WorkManager
                        await _backgroundTaskManager.scheduleDailySummary(
                          hour: time.hour,
                          minute: time.minute,
                        );
                      }
                    },
                  ),
              ],
            ),
          ),
          
          _buildSection(
            icon: Icons.payment,
            title: 'Bill Reminders',
            subtitle: 'Reminders for upcoming recurring payments',
            child: SwitchListTile(
              title: const Text('Enable Bill Reminders'),
              subtitle: const Text('Get reminded 3 days before bills are due'),
              value: _billRemindersEnabled,
              onChanged: (value) async {
                setState(() => _billRemindersEnabled = value);
                await _notificationManager.setBillRemindersEnabled(value);
              },
            ),
          ),
          
          _buildSection(
            icon: Icons.insights,
            title: 'Spending Insights',
            subtitle: 'Unusual patterns and smart recommendations',
            child: SwitchListTile(
              title: const Text('Enable Insights'),
              subtitle: const Text('Get alerts about unusual spending'),
              value: _insightsEnabled,
              onChanged: (value) async {
                setState(() => _insightsEnabled = value);
                await _notificationManager.setInsightsEnabled(value);
              },
            ),
          ),
          
          _buildSection(
            icon: Icons.bedtime,
            title: 'Quiet Hours',
            subtitle: 'No notifications during sleep time',
            child: Column(
              children: [
                ListTile(
                  title: const Text('Start Time'),
                  subtitle: Text(
                    '${_quietHoursStart.toString().padLeft(2, '0')}:00',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.nightlight_round),
                  onTap: () => _selectQuietHour(isStart: true),
                ),
                ListTile(
                  title: const Text('End Time'),
                  subtitle: Text(
                    '${_quietHoursEnd.toString().padLeft(2, '0')}:00',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.wb_sunny),
                  onTap: () => _selectQuietHour(isStart: false),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Test notification button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: OutlinedButton.icon(
              onPressed: _showTestNotification,
              icon: const Icon(Icons.notifications_active),
              label: const Text('Send Test Notification'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildThresholdChip(String threshold, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: [
          Chip(
            label: Text(threshold),
            backgroundColor: color.withValues(alpha: 0.1),
            labelStyle: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Future<void> _selectQuietHour({required bool isStart}) async {
    final initialHour = isStart ? _quietHoursStart : _quietHoursEnd;
    
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: 0),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    
    if (selectedTime != null) {
      setState(() {
        if (isStart) {
          _quietHoursStart = selectedTime.hour;
        } else {
          _quietHoursEnd = selectedTime.hour;
        }
      });
      
      await _notificationManager.setQuietHours(_quietHoursStart, _quietHoursEnd);
    }
  }
}

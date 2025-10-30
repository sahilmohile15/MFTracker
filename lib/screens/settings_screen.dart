import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/sms_import_screen.dart';
import '../screens/notification_settings_screen.dart';
import '../screens/recurring_transactions_screen.dart';
import '../screens/export_screen.dart';
import '../screens/analytics_screen.dart';
import '../screens/dev_tools_screen.dart';
import '../screens/manage_categories_screen.dart';
import '../screens/manage_tags_screen.dart';
import '../screens/manage_accounts_screen.dart';
import '../test_sms_detection_screen.dart';
import '../utils/constants.dart';
import '../database/database_helper.dart';
import '../providers/theme_provider.dart';
import '../providers/transaction_provider.dart';

/// App settings and preferences
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _backgroundSyncEnabled = true; // Default to ON
  bool _notificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // SMS Import Section
          ListTile(
            leading: const Icon(Icons.sms),
            title: const Text('Import from SMS'),
            subtitle: const Text('Import transactions from bank SMS messages'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SmsImportScreen(),
                ),
              );
            },
          ),
          const Divider(),

          // Background Sync Section
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Background Sync'),
            subtitle: const Text('Automatically sync transactions in background'),
            trailing: Switch(
              value: _backgroundSyncEnabled,
              onChanged: (value) {
                setState(() {
                  _backgroundSyncEnabled = value;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? 'Background sync enabled'
                          : 'Background sync disabled',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
          const Divider(),

          // Notifications Section
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            subtitle: const Text('Get notified about new transactions'),
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? 'Notifications enabled'
                          : 'Notifications disabled',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
          const Divider(),

          // Phase 3 Features Section
          const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Text(
              'ADVANCED FEATURES',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.insights, color: Colors.blue),
            title: const Text('Insights & Analytics'),
            subtitle: const Text('Advanced spending insights and forecasts'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to analytics screen which will load data via providers
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnalyticsScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.file_download, color: Colors.green),
            title: const Text('Export Data'),
            subtitle: const Text('Export transactions as PDF or CSV'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExportScreen(
                    transactions: [],
                  ),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.repeat, color: Colors.orange),
            title: const Text('Recurring Transactions'),
            subtitle: const Text('Manage subscriptions and recurring payments'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecurringTransactionsScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.notifications_active, color: Colors.purple),
            title: const Text('Notification Settings'),
            subtitle: const Text('Configure budget alerts and reminders'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsScreen(),
                ),
              );
            },
          ),

          const Divider(),

          // App Settings Section
          const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Text(
              'APP SETTINGS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),

          // Theme Selection
          ListTile(
            leading: Icon(
              ref.watch(themeModeProvider).icon,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('App Theme'),
            subtitle: Text('Current: ${ref.watch(themeModeProvider).displayName}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemeDialog(context),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Manage Categories'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageCategoriesScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text('Manage Accounts'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageAccountsScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.label),
            title: const Text('Manage Tags'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageTagsScreen(),
                ),
              );
            },
          ),

          const Divider(),

          // Data & Privacy Section
          const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Text(
              'DATA & PRIVACY',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup Data'),
            subtitle: const Text('Export all your data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showFeatureDialog(context, 'Backup Data');
            },
          ),

          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restore Data'),
            subtitle: const Text('Import data from backup'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showFeatureDialog(context, 'Restore Data');
            },
          ),

          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Clear All Data'),
            subtitle: const Text('Delete all transactions and settings'),
            onTap: () {
              _showClearDataDialog(context);
            },
          ),

          const Divider(),

          // Developer Tools Section
          const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Text(
              'DEVELOPER TOOLS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.developer_mode, color: Colors.deepOrange),
            title: const Text('Developer Tools'),
            subtitle: const Text('Generate test data and simulate notifications'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DevToolsScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.science, color: Colors.purple),
            title: const Text('Test SMS Detection'),
            subtitle: const Text('Test ML classifier with sample SMS'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TestSmsDetectionScreen(),
                ),
              );
            },
          ),

          const Divider(),

          // About Section
          const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Text(
              'ABOUT',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('App Version'),
            subtitle: Text('${AppInfo.appName} v${AppInfo.version}'),
          ),

          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Open Source'),
            subtitle: const Text('View source code on GitHub'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              _showFeatureDialog(context, 'GitHub Repository');
            },
          ),

          ListTile(
            leading: const Icon(Icons.gavel),
            title: const Text('License'),
            subtitle: const Text('MIT License'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showLicenseDialog(context);
            },
          ),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  void _showFeatureDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: const Text(
          'This feature will be available in Phase 2.\n\n'
          'Phase 1 focuses on:\n'
          '✅ Core database structure\n'
          '✅ Data models & repositories\n'
          '✅ Basic UI foundation\n\n'
          'Phase 2 will include:\n'
          '🔜 Full CRUD operations\n'
          '🔜 Data management screens\n'
          '🔜 Import/Export features',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all your transactions, '
          'accounts, budgets, categories, and tags. Default data will be restored.\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Show loading indicator
              if (!context.mounted) return;
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Clearing data...'),
                        ],
                      ),
                    ),
                  ),
                ),
              );

              try {
                // Clear all data
                await DatabaseHelper.instance.clearAllData();
                
                // Trigger data refresh across all screens
                ref.read(transactionRefreshProvider.notifier).state++;
                
                if (!context.mounted) return;
                Navigator.pop(context); // Close loading dialog
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data cleared successfully'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                Navigator.pop(context); // Close loading dialog
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error clearing data: $e'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showLicenseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('MIT License'),
        content: const SingleChildScrollView(
          child: Text(
            'Copyright (c) 2025 MFTracker\n\n'
            'Permission is hereby granted, free of charge, to any person '
            'obtaining a copy of this software and associated documentation '
            'files (the "Software"), to deal in the Software without '
            'restriction, including without limitation the rights to use, '
            'copy, modify, merge, publish, distribute, sublicense, and/or '
            'sell copies of the Software, and to permit persons to whom the '
            'Software is furnished to do so, subject to the following '
            'conditions:\n\n'
            'The above copyright notice and this permission notice shall be '
            'included in all copies or substantial portions of the Software.\n\n'
            'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, '
            'EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES '
            'OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND '
            'NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT '
            'HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, '
            'WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING '
            'FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR '
            'OTHER DEALINGS IN THE SOFTWARE.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    final currentTheme = ref.read(themeModeProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppThemeMode.values.map((mode) {
            return RadioListTile<AppThemeMode>(
              value: mode,
              groupValue: currentTheme,
              title: Text(mode.displayName),
              subtitle: Text(
                mode == AppThemeMode.system
                    ? 'Follow system settings'
                    : mode == AppThemeMode.light
                        ? 'Always use light theme'
                        : 'Always use dark theme',
              ),
              secondary: Icon(mode.icon),
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

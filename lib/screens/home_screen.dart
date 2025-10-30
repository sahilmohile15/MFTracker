import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'transactions_screen.dart';
import 'budgets_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';
import '../services/sms_realtime_service.dart';

/// Main app home screen with bottom navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    TransactionsScreen(),
    BudgetsScreen(),
    AnalyticsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Request SMS permission and set up real-time transaction listener
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestSmsPermission();
      _setupRealtimeListener();
    });
  }
  
  void _setupRealtimeListener() {
    // Listen for new transactions from real-time SMS
    SmsRealtimeService().onTransactionDetected = (transaction) {
      if (mounted) {
        // Show snackbar notification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '💰 New transaction: ₹${transaction.amount.toStringAsFixed(2)} at ${transaction.merchantName}',
            ),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'View',
              onPressed: () {
                // Navigate to transactions screen
                setState(() {
                  _selectedIndex = 0;
                });
              },
            ),
          ),
        );
      }
    };
  }

  Future<void> _requestSmsPermission() async {
    // Check if SMS permission is already granted
    final status = await Permission.sms.status;
    
    if (status.isDenied) {
      // Show dialog explaining why we need the permission
      if (mounted) {
        final shouldRequest = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Enable SMS Access'),
            content: const Text(
              'MFTracker needs SMS access to:\n\n'
              '• 🚀 Auto-detect transactions as SMS arrives\n'
              '• 🤖 Use ML to parse bank SMS messages\n'
              '• 💸 Track spending in real-time\n'
              '• 📊 Import existing SMS transactions\n\n'
              'You can change this later in Settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Not Now'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Enable'),
              ),
            ],
          ),
        );

        if (shouldRequest == true) {
          await Permission.sms.request();
        }
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Budgets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

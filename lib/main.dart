import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/home_screen.dart';
import 'services/notification_manager.dart';
import 'services/sms_realtime_service.dart';
import 'utils/constants.dart';
import 'parsers/parser_registry.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';

/// Application entry point
///
/// Initializes services, configures system UI, and starts the app with
/// Riverpod state management.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize financial text parsers for SMS transaction parsing
  initializeBankParsers();

  // Initialize notification manager for budget alerts and reminders
  await NotificationManager().initialize();
  
  // Initialize real-time SMS monitoring service
  await SmsRealtimeService().initialize();

  // Lock app to portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configure system UI appearance
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ProviderScope(
      child: MFTrackerApp(),
    ),
  );
}

/// Root application widget
///
/// Provides theme configuration and navigation using MaterialApp.
/// Integrates with Riverpod for reactive theme switching.
class MFTrackerApp extends ConsumerWidget {
  const MFTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(flutterThemeModeProvider);

    return MaterialApp(
      title: AppInfo.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeMode,
      home: const HomeScreen(),
    );
  }
}

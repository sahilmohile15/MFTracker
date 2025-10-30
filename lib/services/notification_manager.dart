import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/budget.dart';

/// Callback type for handling notification taps
typedef NotificationTapCallback = void Function(String type, String id);

/// Manages all local notifications for the app
/// Handles budget alerts, daily summaries, and bill reminders
class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  /// Callback to handle notification taps (set by main app)
  NotificationTapCallback? onNotificationTapped;

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Notification IDs
  static const int budgetAlertBaseId = 1000;
  static const int dailySummaryId = 2000;
  static const int billReminderBaseId = 3000;
  static const int unusualSpendingId = 4000;

  // Notification channels
  static const String budgetChannelId = 'budget_alerts';
  static const String summaryChannelId = 'daily_summary';
  static const String billChannelId = 'bill_reminders';
  static const String insightsChannelId = 'spending_insights';

  bool _isInitialized = false;

  /// Initialize the notification system
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Request notification permissions for Android 13+
    await _requestPermissions();

    // Initialize timezone data
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    await _createNotificationChannels();

    _isInitialized = true;
  }

  /// Request notification permissions (Android 13+)
  Future<void> _requestPermissions() async {
    // Request POST_NOTIFICATIONS permission for Android 13+
    final status = await Permission.notification.request();
    
    if (!status.isGranted) {
      print('[NotificationManager] Notification permission denied');
    }
    
    // Request exact alarm permission if needed
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  /// Create Android notification channels
  Future<void> _createNotificationChannels() async {
    const budgetChannel = AndroidNotificationChannel(
      budgetChannelId,
      'Budget Alerts',
      description: 'Notifications when you approach or exceed budget limits',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    const summaryChannel = AndroidNotificationChannel(
      summaryChannelId,
      'Daily Summary',
      description: 'Daily spending summary notifications',
      importance: Importance.defaultImportance,
      enableVibration: false,
      playSound: false,
    );

    const billChannel = AndroidNotificationChannel(
      billChannelId,
      'Bill Reminders',
      description: 'Reminders for upcoming bill payments',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    const insightsChannel = AndroidNotificationChannel(
      insightsChannelId,
      'Spending Insights',
      description: 'Unusual spending patterns and insights',
      importance: Importance.defaultImportance,
      enableVibration: false,
      playSound: false,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(budgetChannel);
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(summaryChannel);
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(billChannel);
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(insightsChannel);
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;

    // Parse payload and navigate accordingly
    // Format: "type:id" e.g., "budget:123" or "summary:2024-10-24"
    final parts = payload.split(':');
    if (parts.length != 2) return;

    final type = parts[0];
    final id = parts[1];

    // Call the registered callback
    onNotificationTapped?.call(type, id);
  }

  /// Show budget alert notification
  Future<void> showBudgetAlert({
    required Budget budget,
    required double percentage,
    required double spentAmount,
  }) async {
    if (!_isInitialized) await initialize();

    // Check if budget alerts are enabled
    if (!await areBudgetAlertsEnabled()) return;

    // Check if this threshold has already been notified
    if (await hasBeenNotified(budget.id, percentage)) return;

    final String title;
    final String body;

    if (percentage >= 100) {
      title = '🚨 Budget Exceeded!';
      body =
          '${budget.name}: You\'ve spent ₹${spentAmount.toStringAsFixed(0)} of ₹${budget.amount.toStringAsFixed(0)} (${percentage.toInt()}%)';
    } else if (percentage >= 90) {
      title = '⚠️ Budget Alert';
      body =
          '${budget.name}: You\'ve used ${percentage.toInt()}% of your budget';
    } else if (percentage >= 75) {
      title = '📊 Budget Update';
      body =
          '${budget.name}: You\'ve spent ${percentage.toInt()}% of your budget';
    } else {
      // 50% threshold
      title = 'ℹ️ Budget Reminder';
      body = '${budget.name}: You\'re halfway through your budget';
    }

    const androidDetails = AndroidNotificationDetails(
      budgetChannelId,
      'Budget Alerts',
      channelDescription: 'Notifications when you approach or exceed budget limits',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Budget Alert',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      budgetAlertBaseId + budget.id.hashCode % 1000,
      title,
      body,
      details,
      payload: 'budget:${budget.id}',
    );

    // Mark this threshold as notified
    await markAsNotified(budget.id, percentage);
  }

  /// Show daily spending summary
  Future<void> showDailySummary({
    required double totalSpent,
    required Map<String, double> topCategories,
    required int transactionCount,
  }) async {
    if (!_isInitialized) await initialize();

    // Check if daily summaries are enabled
    if (!await areDailySummariesEnabled()) return;

    final topCategoryText = topCategories.entries.isNotEmpty
        ? '\nTop: ${topCategories.entries.first.key} ₹${topCategories.entries.first.value.toStringAsFixed(0)}'
        : '';

    const androidDetails = AndroidNotificationDetails(
      summaryChannelId,
      'Daily Summary',
      channelDescription: 'Daily spending summary notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      ticker: 'Daily Summary',
      styleInformation: BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      dailySummaryId,
      '📊 Today\'s Spending Summary',
      'You spent ₹${totalSpent.toStringAsFixed(0)} across $transactionCount transactions$topCategoryText',
      details,
      payload: 'summary:${DateTime.now().toIso8601String()}',
    );
  }

  /// Schedule daily summary notification
  Future<void> scheduleDailySummary({
    required int hour, // 0-23
    required int minute, // 0-59
  }) async {
    if (!_isInitialized) await initialize();

    // Cancel existing scheduled notification
    await _notifications.cancel(dailySummaryId);

    // Calculate next occurrence
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      summaryChannelId,
      'Daily Summary',
      channelDescription: 'Daily spending summary notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      dailySummaryId,
      '📊 Daily Spending Summary',
      'Tap to see your spending overview',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      payload: 'summary:scheduled',
    );
  }

  /// Show bill reminder notification
  Future<void> showBillReminder({
    required String billName,
    required double amount,
    required DateTime dueDate,
    required String recurringId,
  }) async {
    if (!_isInitialized) await initialize();

    // Check if bill reminders are enabled
    if (!await areBillRemindersEnabled()) return;

    final daysUntilDue = dueDate.difference(DateTime.now()).inDays;
    final dueDateText = daysUntilDue == 0
        ? 'due today'
        : daysUntilDue == 1
            ? 'due tomorrow'
            : 'due in $daysUntilDue days';

    const androidDetails = AndroidNotificationDetails(
      billChannelId,
      'Bill Reminders',
      channelDescription: 'Reminders for upcoming bill payments',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Bill Reminder',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      billReminderBaseId + recurringId.hashCode % 1000,
      '💰 Bill Reminder',
      '$billName: ₹${amount.toStringAsFixed(0)} $dueDateText',
      details,
      payload: 'bill:$recurringId',
    );
  }

  /// Show unusual spending alert
  Future<void> showUnusualSpendingAlert({
    required String message,
    required String category,
  }) async {
    if (!_isInitialized) await initialize();

    // Check if insights notifications are enabled
    if (!await areInsightsEnabled()) return;

    const androidDetails = AndroidNotificationDetails(
      insightsChannelId,
      'Spending Insights',
      channelDescription: 'Unusual spending patterns and insights',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      ticker: 'Spending Insight',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      unusualSpendingId,
      '🔍 Spending Insight',
      message,
      details,
      payload: 'insight:$category',
    );
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// Cancel specific notification
  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }

  // Settings getters/setters using SharedPreferences

  Future<void> setBudgetAlertsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_budget_alerts', enabled);
  }

  Future<void> setDailySummariesEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_daily_summary', enabled);
  }

  Future<void> setBillRemindersEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_bill_reminders', enabled);
  }

  Future<void> setInsightsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_insights', enabled);
  }

  Future<bool> areBudgetAlertsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_budget_alerts') ?? true;
  }

  Future<bool> areDailySummariesEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_daily_summary') ?? false;
  }

  Future<bool> areBillRemindersEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_bill_reminders') ?? true;
  }

  Future<bool> areInsightsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_insights') ?? true;
  }

  /// Check if a specific budget threshold has already been notified
  Future<bool> hasBeenNotified(String budgetId, double percentage) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'notified_${budgetId}_${percentage.toInt()}';
    return prefs.getBool(key) ?? false;
  }

  /// Mark a budget threshold as notified
  Future<void> markAsNotified(String budgetId, double percentage) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'notified_${budgetId}_${percentage.toInt()}';
    await prefs.setBool(key, true);
  }

  /// Reset notification flags for a budget (call this when budget resets or is modified)
  Future<void> resetBudgetNotifications(String budgetId) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = [
      'notified_${budgetId}_50',
      'notified_${budgetId}_75',
      'notified_${budgetId}_90',
      'notified_${budgetId}_100',
    ];
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  /// Get quiet hours settings
  Future<(int startHour, int endHour)> getQuietHours() async {
    final prefs = await SharedPreferences.getInstance();
    final startHour = prefs.getInt('quiet_hours_start') ?? 22; // 10 PM
    final endHour = prefs.getInt('quiet_hours_end') ?? 7; // 7 AM
    return (startHour, endHour);
  }

  /// Set quiet hours
  Future<void> setQuietHours(int startHour, int endHour) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quiet_hours_start', startHour);
    await prefs.setInt('quiet_hours_end', endHour);
  }

  /// Check if current time is within quiet hours
  Future<bool> isQuietTime() async {
    final (startHour, endHour) = await getQuietHours();
    final now = DateTime.now().hour;

    if (startHour < endHour) {
      // e.g., 22 to 7 (overnight)
      return now >= startHour || now < endHour;
    } else {
      // e.g., 7 to 22 (same day)
      return now >= startHour && now < endHour;
    }
  }

  /// Request notification permission (iOS)
  Future<bool> requestPermission() async {
    if (!_isInitialized) await initialize();

    final result = await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    return result ?? true; // Android doesn't need runtime permission
  }
}

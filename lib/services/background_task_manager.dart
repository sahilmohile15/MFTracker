import 'package:workmanager/workmanager.dart';
import 'summary_service.dart';

/// Background task names
const String dailySummaryTask = 'dailySummaryTask';

/// Callback dispatcher for background tasks
/// This runs in a separate isolate and must be a top-level function
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case dailySummaryTask:
        await _executeDailySummary();
        break;
      default:
        break;
    }
    return Future.value(true);
  });
}

/// Execute the daily summary task
Future<void> _executeDailySummary() async {
  try {
    final summaryService = SummaryService();
    await summaryService.showTodaysSummary();
  } catch (e) {
    // Log error but don't crash - silently fail
    // In production, consider using proper logging service
  }
}

/// Service for managing background tasks
class BackgroundTaskManager {
  static final BackgroundTaskManager _instance = BackgroundTaskManager._internal();
  factory BackgroundTaskManager() => _instance;
  BackgroundTaskManager._internal();

  bool _isInitialized = false;

  /// Initialize WorkManager
  Future<void> initialize() async {
    if (_isInitialized) return;

    await Workmanager().initialize(
      callbackDispatcher,
      // isInDebugMode removed - use WorkmanagerDebug instead if needed
    );

    _isInitialized = true;
  }

  /// Schedule daily summary notification
  /// [hour] - Hour of day (0-23)
  /// [minute] - Minute of hour (0-59)
  Future<void> scheduleDailySummary({
    required int hour,
    required int minute,
  }) async {
    if (!_isInitialized) await initialize();

    // Cancel any existing daily summary task
    await Workmanager().cancelByUniqueName(dailySummaryTask);

    // Calculate initial delay until next occurrence
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
    
    // If the time has already passed today, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final initialDelay = scheduledTime.difference(now);

    // Schedule periodic task (runs daily)
    await Workmanager().registerPeriodicTask(
      dailySummaryTask,
      dailySummaryTask,
      frequency: const Duration(hours: 24),
      initialDelay: initialDelay,
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
      inputData: {
        'hour': hour,
        'minute': minute,
      },
    );
  }

  /// Cancel daily summary notifications
  Future<void> cancelDailySummary() async {
    if (!_isInitialized) return;
    await Workmanager().cancelByUniqueName(dailySummaryTask);
  }

  /// Cancel all background tasks
  Future<void> cancelAll() async {
    if (!_isInitialized) return;
    await Workmanager().cancelAll();
  }
}

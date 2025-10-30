import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for handling notification permissions and receiving transaction notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const platform = MethodChannel('com.example.finance_tracker/notifications');
  
  // Callback when a new notification is received
  Function(NotificationData)? onNotificationReceived;
  
  /// Initialize the notification service and set up listeners
  Future<void> initialize() async {
    if (kDebugMode) {
      print('[NotificationService] Initializing...');
    }
    
    platform.setMethodCallHandler(_handleMethodCall);
    
    if (kDebugMode) {
      print('[NotificationService] Initialized successfully');
    }
  }
  
  /// Handle method calls from Android
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (kDebugMode) {
      print('[NotificationService] Received call: ${call.method}');
    }
    
    switch (call.method) {
      case 'onNotificationReceived':
        _handleNotificationReceived(call.arguments);
        break;
      default:
        if (kDebugMode) {
          print('[NotificationService] Unknown method: ${call.method}');
        }
    }
  }
  
  /// Handle incoming notification data
  void _handleNotificationReceived(dynamic arguments) {
    try {
      if (arguments is! Map) {
        if (kDebugMode) {
          print('[NotificationService] Invalid arguments type');
        }
        return;
      }
      
      final data = Map<String, dynamic>.from(arguments);
      final notification = NotificationData.fromMap(data);
      
      if (kDebugMode) {
        print('[NotificationService] Received notification from ${notification.packageName}');
        print('[NotificationService] Title: ${notification.title}');
        print('[NotificationService] Text: ${notification.text.substring(0, notification.text.length > 50 ? 50 : notification.text.length)}...');
      }
      
      // Call the callback if set
      onNotificationReceived?.call(notification);
      
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('[NotificationService] Error handling notification: $e');
        print('[NotificationService] Stack trace: $stackTrace');
      }
    }
  }
  
  /// Check if notification permission is granted
  Future<bool> checkPermission() async {
    try {
      // Use permission_handler instead of platform channel
      final status = await Permission.notification.status;
      
      if (kDebugMode) {
        print('[NotificationService] Permission status: ${status.isGranted}');
      }
      
      return status.isGranted;
    } catch (e) {
      if (kDebugMode) {
        print('[NotificationService] Error checking permission: $e');
      }
      return false;
    }
  }
  
  /// Request notification access permission (opens Settings)
  Future<void> requestPermission() async {
    try {
      // Use permission_handler instead of platform channel
      final status = await Permission.notification.request();
      
      if (kDebugMode) {
        print('[NotificationService] Permission request result: ${status.isGranted}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[NotificationService] Error requesting permission: $e');
      }
    }
  }
  
  /// Get active notifications (optional feature)
  Future<List<NotificationData>> getActiveNotifications() async {
    try {
      final List<dynamic> notifications = await platform.invokeMethod('getActiveNotifications');
      
      return notifications
          .map((data) => NotificationData.fromMap(Map<String, dynamic>.from(data)))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('[NotificationService] Error getting notifications: $e');
      }
      return [];
    }
  }
}

/// Data model for notification
class NotificationData {
  final String packageName;
  final String title;
  final String text;
  final String subText;
  final DateTime timestamp;
  
  NotificationData({
    required this.packageName,
    required this.title,
    required this.text,
    required this.subText,
    required this.timestamp,
  });
  
  factory NotificationData.fromMap(Map<String, dynamic> map) {
    return NotificationData(
      packageName: map['package'] as String? ?? '',
      title: map['title'] as String? ?? '',
      text: map['text'] as String? ?? '',
      subText: map['subText'] as String? ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int? ?? 0),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'package': packageName,
      'title': title,
      'text': text,
      'subText': subText,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
  
  @override
  String toString() {
    return 'NotificationData(package: $packageName, title: $title, timestamp: $timestamp)';
  }
}

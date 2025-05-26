import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // Initialize notifications
  static Future<void> initialize() async {
    if (_initialized) return;

    // Request notification permissions
    await _requestPermissions();

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize the plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  // Request notification permissions
  static Future<void> _requestPermissions() async {
    // Request notification permission
    await Permission.notification.request();

    // For Android 13+ (API level 33+), request POST_NOTIFICATIONS permission
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  // Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    
    // Handle different notification types based on payload
    switch (payload) {
      case 'check_in_reminder':
        // Navigate to check-in screen
        break;
      case 'message_sent':
        // Navigate to messages screen
        break;
      default:
        // Default action
        break;
    }
  }

  // Show a simple notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'afterwords_channel',
      'AfterWords Notifications',
      channelDescription: 'Notifications for AfterWords app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Show urgent check-in notification
  static Future<void> showUrgentCheckInNotification({
    required Duration timeRemaining,
  }) async {
    String title = 'URGENT: AfterWords Check-in Required';
    String body;

    if (timeRemaining.inMinutes < 60) {
      body = 'Check-in required in ${timeRemaining.inMinutes} minutes!';
    } else {
      body = 'Check-in required in ${timeRemaining.inHours} hours!';
    }

    const androidDetails = AndroidNotificationDetails(
      'urgent_checkin_channel',
      'Urgent Check-in Notifications',
      channelDescription: 'Urgent check-in reminders',
      importance: Importance.max,
      priority: Priority.max,
      showWhen: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      999, // Use a specific ID for urgent notifications
      title,
      body,
      notificationDetails,
      payload: 'urgent_check_in',
    );
  }

  // Schedule a notification
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      'Scheduled Notifications',
      channelDescription: 'Scheduled notifications for AfterWords',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Note: For scheduled notifications, you would need to use timezone package
    // For now, we'll use a simple show notification
    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Cancel a notification
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Get pending notifications
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Show message delivery notification
  static Future<void> showMessageDeliveryNotification({
    required String messageTitle,
    required int recipientCount,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Message Delivered',
      body: '"$messageTitle" has been sent to $recipientCount recipient(s)',
      payload: 'message_sent',
    );
  }

  // Show check-in success notification
  static Future<void> showCheckInSuccessNotification() async {
    await showNotification(
      id: 100,
      title: 'Check-in Successful',
      body: 'Your check-in has been recorded successfully',
      payload: 'check_in_success',
    );
  }

  // Show check-in failure notification
  static Future<void> showCheckInFailureNotification() async {
    await showNotification(
      id: 101,
      title: 'Check-in Failed',
      body: 'Failed to record your check-in. Please try again.',
      payload: 'check_in_failure',
    );
  }

  // Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  // Open app settings for notification permissions
  static Future<void> openNotificationSettings() async {
    await openAppSettings();
  }
}
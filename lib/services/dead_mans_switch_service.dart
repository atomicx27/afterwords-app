import 'dart:async';
import 'package:workmanager/workmanager.dart';
import '../services/auth_service.dart';
import '../services/message_service.dart';
import '../services/notification_service.dart';

class DeadMansSwitchService {
  static const String _checkInTaskName = 'check_in_reminder';
  static const String _deadlineMissedTaskName = 'deadline_missed_check';

  // Initialize the dead man's switch system
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  // Schedule check-in reminders
  static Future<void> scheduleCheckInReminders() async {
    try {
      final user = await AuthService.getUserProfile();
      if (user == null) return;

      // Cancel existing tasks
      await Workmanager().cancelByUniqueName(_checkInTaskName);
      await Workmanager().cancelByUniqueName(_deadlineMissedTaskName);

      // Schedule periodic check-in reminders
      await Workmanager().registerPeriodicTask(
        _checkInTaskName,
        _checkInTaskName,
        frequency: Duration(hours: user.checkInIntervalHours ~/ 4), // Remind 4 times per interval
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
      );

      // Schedule deadline check
      await Workmanager().registerPeriodicTask(
        _deadlineMissedTaskName,
        _deadlineMissedTaskName,
        frequency: const Duration(hours: 1), // Check every hour
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
      );
    } catch (e) {
      print('Failed to schedule check-in reminders: $e');
    }
  }

  // Cancel all scheduled tasks
  static Future<void> cancelAllTasks() async {
    await Workmanager().cancelAll();
  }

  // Check if user has missed their deadline
  static Future<bool> hasUserMissedDeadline() async {
    try {
      final user = await AuthService.getUserProfile();
      if (user == null) return false;

      return user.isOverdue;
    } catch (e) {
      return false;
    }
  }

  // Get time until next deadline
  static Future<Duration?> getTimeUntilDeadline() async {
    try {
      final user = await AuthService.getUserProfile();
      if (user == null) return null;

      return user.timeUntilDeadline;
    } catch (e) {
      return null;
    }
  }

  // Trigger message delivery (called when deadline is missed)
  static Future<void> triggerMessageDelivery() async {
    try {
      final user = await AuthService.getUserProfile();
      if (user == null || !user.isOverdue) return;

      // Get all scheduled messages for the user
      final messages = await MessageService.getMessagesToSend(user.id);

      for (final message in messages) {
        try {
          // Here you would integrate with your email/messaging service
          // For now, we'll just mark as sent
          await MessageService.markMessageAsSent(message.id);
          
          // Log the delivery
          print('Message "${message.title}" delivered to ${message.recipientIds.length} recipients');
        } catch (e) {
          await MessageService.markMessageAsFailed(message.id, e.toString());
          print('Failed to deliver message "${message.title}": $e');
        }
      }

      // Deactivate user account to prevent further deliveries
      final updatedUser = user.copyWith(
        isActive: false,
        updatedAt: DateTime.now(),
      );
      await AuthService.updateUserProfile(updatedUser);

    } catch (e) {
      print('Failed to trigger message delivery: $e');
    }
  }

  // Send check-in reminder notification
  static Future<void> sendCheckInReminder() async {
    try {
      final timeUntilDeadline = await getTimeUntilDeadline();
      if (timeUntilDeadline == null) return;

      String title = 'AfterWords Check-in Required';
      String body;

      if (timeUntilDeadline.inHours < 1) {
        body = 'URGENT: Check-in required in ${timeUntilDeadline.inMinutes} minutes!';
      } else if (timeUntilDeadline.inHours < 24) {
        body = 'Check-in required in ${timeUntilDeadline.inHours} hours';
      } else {
        body = 'Check-in required in ${timeUntilDeadline.inDays} days';
      }

      await NotificationService.showNotification(
        id: 1,
        title: title,
        body: body,
        payload: 'check_in_reminder',
      );
    } catch (e) {
      print('Failed to send check-in reminder: $e');
    }
  }

  // Perform check-in
  static Future<bool> performCheckIn(String password) async {
    try {
      // Here you would verify the password against stored hash
      // For now, we'll assume it's correct and update the check-in time
      await AuthService.updateLastCheckIn();
      
      // Reschedule reminders based on new check-in time
      await scheduleCheckInReminders();
      
      return true;
    } catch (e) {
      print('Failed to perform check-in: $e');
      return false;
    }
  }

  // Get check-in status
  static Future<Map<String, dynamic>> getCheckInStatus() async {
    try {
      final user = await AuthService.getUserProfile();
      if (user == null) {
        return {
          'isOverdue': false,
          'timeUntilDeadline': null,
          'lastCheckIn': null,
          'intervalHours': 24,
        };
      }

      return {
        'isOverdue': user.isOverdue,
        'timeUntilDeadline': user.timeUntilDeadline,
        'lastCheckIn': user.lastCheckIn,
        'intervalHours': user.checkInIntervalHours,
      };
    } catch (e) {
      return {
        'isOverdue': false,
        'timeUntilDeadline': null,
        'lastCheckIn': null,
        'intervalHours': 24,
      };
    }
  }

  // Update check-in interval
  static Future<void> updateCheckInInterval(int hours) async {
    try {
      final user = await AuthService.getUserProfile();
      if (user == null) return;

      final updatedUser = user.copyWith(
        checkInIntervalHours: hours,
        updatedAt: DateTime.now(),
      );

      await AuthService.updateUserProfile(updatedUser);
      await scheduleCheckInReminders();
    } catch (e) {
      print('Failed to update check-in interval: $e');
    }
  }
}

// Background task callback dispatcher
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      switch (task) {
        case DeadMansSwitchService._checkInTaskName:
          await DeadMansSwitchService.sendCheckInReminder();
          break;
        case DeadMansSwitchService._deadlineMissedTaskName:
          final hasUserMissedDeadline = await DeadMansSwitchService.hasUserMissedDeadline();
          if (hasUserMissedDeadline) {
            await DeadMansSwitchService.triggerMessageDelivery();
          }
          break;
      }
      return Future.value(true);
    } catch (e) {
      print('Background task failed: $e');
      return Future.value(false);
    }
  });
}
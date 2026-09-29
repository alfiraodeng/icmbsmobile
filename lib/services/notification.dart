import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService();

  static final _localNotifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    var initializationSettings = InitializationSettings(
      android: const AndroidInitializationSettings('@mipmap/launcher_icon'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {},
      ),
    );

    await _localNotifications.initialize(initializationSettings);
  }

  static Future<void> display({title, body, payload}) async {
    var id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    var notificationDetails = const NotificationDetails(
      android: AndroidNotificationDetails(
        'indexsafe_notification_channel',
        'MBS SAP Channel',
        channelDescription: 'MBS SAP Notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(presentSound: false),
    );

    await _localNotifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  static void cancelAll() => _localNotifications.cancelAll();
}

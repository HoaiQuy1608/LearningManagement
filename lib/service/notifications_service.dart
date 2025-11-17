import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:learningmanagement/models/schedule_model.dart';
import 'package:learningmanagement/main.dart';

class NotificationsService {
  static Future<void> schedule(
    ScheduleModel event, {
    DateTime? specificTime,
    String? idSuffix,
  }) async {
    final String rawId = event.id + (idSuffix ?? '');
    final int notificationId = rawId.hashCode;

    await notificationsPlugin.cancel(notificationId);

    tz.TZDateTime scheduledTime;
    String bodyText;

    if (specificTime != null) {
      scheduledTime = tz.TZDateTime.from(specificTime, tz.local);
      bodyText = 'Sap ket thuc: ${event.title}';
    } else {
      if (event.reminder == null || event.reminder == 'Không nhắc') return;

      final eventTime = tz.TZDateTime.from(event.startTime, tz.local);
      int minutes = switch (event.reminder) {
        'Trước 1 phút' => 1,
        'Trước 5 phút' => 5,
        'Trước 1 giờ' => 60,
        'Trước 1 ngày' => 1440,
        _ => 0,
      };
      scheduledTime = eventTime.subtract(Duration(minutes: minutes));
      bodyText = 'Sap dien ra: ${event.title}';
    }
    final now = tz.TZDateTime.now(tz.local);
    if (scheduledTime.isBefore(now)) return;

    const androidDetails = AndroidNotificationDetails(
      'schedule_channel',
      'Lịch học',
      channelDescription: 'Thông báo cho các sự kiện đã lên lịch',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await notificationsPlugin.zonedSchedule(
      notificationId,
      event.title,
      bodyText,
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> cancel(String eventId) async {
    await notificationsPlugin.cancel(eventId.hashCode);
    await notificationsPlugin.cancel('${eventId}_end'.hashCode);
  }
}

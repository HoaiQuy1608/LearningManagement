import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:learningmanagement/models/schedule_model.dart';
import 'package:learningmanagement/main.dart';

class NotificationsService {
  static Future<void> schedule(ScheduleModel event) async {
    await notificationsPlugin.cancel(event.id.hashCode);

    if (event.reminder == null || event.reminder == 'Không nhắc') return;

    final now = tz.TZDateTime.now(tz.local);
    final eventTime = tz.TZDateTime.from(event.startTime, tz.local);
    if (eventTime.isBefore(now)) return;

    int minutes = switch (event.reminder) {
      'Trước 1 phút' => 1,
      'Trước 5 phút' => 5,
      'Trước 1 giờ' => 60,
      'Trước 1 ngày' => 1440,
      _ => 0,
    };

    final scheduledTime = eventTime.subtract(Duration(minutes: minutes));
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
      event.id.hashCode,
      'Sắp tới: ${event.title}',
      event.reminder!,
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> cancel(String eventId) async {
    await notificationsPlugin.cancel(eventId.hashCode);
  }
}

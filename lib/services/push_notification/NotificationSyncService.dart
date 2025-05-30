import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/timezone.dart' as tz;

import '../user_service.dart';
import 'NotificationCacheService.dart';

  // Hàm định dạng thời gian
   String formatTime(DateTime time) {
    String hour = time.hour.toString().padLeft(2, '0');
    String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

class NotificationSyncService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();



  // Đồng bộ tất cả thông báo khi đăng nhập
  static Future<void> syncAllNotifications() async {
    try {
      // Lấy danh sách lịch tập
      final workoutSchedules = await _fetchWorkoutSchedules();
      // Lấy danh sách lịch ăn
      final mealSchedules = await _fetchMealSchedules();

      // Lên lịch lại các thông báo tập luyện
      for (var schedule in workoutSchedules) {
        if (schedule['scheduled_execution_time'] != null) {
          DateTime workoutTime = DateTime.parse(schedule['scheduled_execution_time']);
          if (workoutTime.isAfter(DateTime.now())) {
            int notificationId = workoutTime.millisecondsSinceEpoch ~/ 1000;
            String workoutName = schedule['workout_id']['name'];
            await _scheduleWorkoutNotification(workoutTime, workoutName, notificationId);
            await NotificationCacheService.saveWorkoutNotificationId(
                schedule['id'].toString(), notificationId);
          }
        }
      }

      // Lên lịch lại các thông báo bữa ăn
      for (var schedule in mealSchedules) {
        if (schedule['meal_time'] != null) {
          DateTime mealTime = DateTime.parse(schedule['meal_time']);
          if (mealTime.isAfter(DateTime.now())) {
            int notificationId = mealTime.millisecondsSinceEpoch ~/ 1000;
            String mealName = schedule['dish_id']['name'];
            await _scheduleMealNotification(mealTime, mealName, notificationId);
            await NotificationCacheService.saveMealNotificationId(
                schedule['id'].toString(), notificationId);
          }
        }
      }

      // Lên lịch thông báo động viên
      await _scheduleMotivationalNotification();
    } catch (e) {
      print('Lỗi khi đồng bộ thông báo: $e');
    }
  }

  // Lấy danh sách lịch tập
  static Future<List<dynamic>> _fetchWorkoutSchedules() async {
    final response = await http.get(
      Uri.parse('http://192.168.133.101:8055/items/workout_schedule?fields=*,workout_id.*'),
      headers: {
        'Authorization': 'Bearer ${await getToken()}',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? [];
    }
    return [];
  }

  // Lấy danh sách lịch ăn
  static Future<List<dynamic>> _fetchMealSchedules() async {
    final response = await http.get(
      Uri.parse('http://192.168.133.101:8055/items/meal_schedule?fields=*,dish_id.*'),
      headers: {
        'Authorization': 'Bearer ${await getToken()}',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? [];
    }
    return [];
  }

  // Lên lịch thông báo tập luyện
  static Future<void> _scheduleWorkoutNotification(
      DateTime workoutTime, String workoutName, int notificationId) async {
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(workoutTime, tz.local)
        .subtract(const Duration(minutes: 30));
    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      "Đến giờ tập rồi 🏋️",
      "Hôm nay bạn có lịch tập $workoutName lúc ${formatTime(workoutTime)}",
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'workout_channel_id',
          'Nhắc nhở tập luyện',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'app_icon',
        ),
      ),
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  // Lên lịch thông báo bữa ăn
  static Future<void> _scheduleMealNotification(
      DateTime mealTime, String mealName, int notificationId) async {
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(mealTime, tz.local)
        .subtract(const Duration(minutes: 30));
    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      "Đến giờ ăn rồi 🍽️",
      "Hôm nay bạn có bữa $mealName lúc ${formatTime(mealTime)}",
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'meal_channel_id',
          'Nhắc nhở ăn uống',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'app_icon',
        ),
      ),
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  // Lên lịch thông báo động viên
  static Future<void> _scheduleMotivationalNotification() async {
    final tz.TZDateTime scheduledDate = tz.TZDateTime.local(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      21,
      0,
    ).add(const Duration(days: 1));

    const motivationalMessages = [
      "Hôm nay bạn đã cố gắng rất nhiều! 💪",
      "Hãy nghỉ ngơi sớm để ngày mai thật năng lượng 🌙",
      "Bạn đang tiến bộ từng ngày, đừng bỏ cuộc nhé! 🚀",
    ];

    final random = motivationalMessages[DateTime.now().day % motivationalMessages.length];

    await flutterLocalNotificationsPlugin.zonedSchedule(
      88888,
      "💡 Lời nhắc động viên",
      random,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'motivation_channel',
          'Lời động viên',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
} 
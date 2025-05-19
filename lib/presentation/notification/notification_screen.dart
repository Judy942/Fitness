import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/utils/app_colors.dart';
import '../../services/user_service.dart';
import '../../widgets/notification_row.dart';
import '../meal_planner/meal_schedule/meal_schedule.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // Đây là nơi xử lý khi người dùng nhấn thông báo từ background/terminated
  debugPrint(
      'Tapped notification (background): ${notificationResponse.payload}');
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List todayMeals = [];
  List lastWorkoutNotificationArr = [];

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void configureLocalNotification() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          debugPrint('Notification payload: ${response.payload}');
          // Xử lý payload ở đây nếu cần
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  Future<void> _requestExactAlarmPermission() async {
    final androidImpl =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImpl != null) {
      // This will show the system prompt (or take user to settings on Android 14+)
      final bool granted =
          await androidImpl.requestExactAlarmsPermission() ?? false;
      if (!granted) {
        // Fallback or inform the user:
        debugPrint(
            'Exact alarm permission not granted—using inexact scheduling');
      }
    }
  }

  Future<void> scheduleNotification({
  required int id,
  required String title,
  required String body,
  required DateTime scheduledTime,
}) async {
  final scheduledNotificationDateTime =
      tz.TZDateTime.from(scheduledTime, tz.local).subtract(Duration(minutes: 30));

  await flutterLocalNotificationsPlugin.zonedSchedule(
    id,
    title,
    body,
    scheduledNotificationDateTime,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'your_channel_id',
        'your_channel_name',
        importance: Importance.high,
        priority: Priority.high,
      ),
    ),
    matchDateTimeComponents: DateTimeComponents.time, androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle, // lặp hàng ngày
  );
}


  final UserService _userService = UserService(); // Create an instance

  Future<void> _fetchWorkoutNotification() async {
    List<dynamic> workouts = await _userService.fetchData(
        'http://192.168.133.103:8055/items/workout_schedule?fields=*,completed_exercise.*,workout_id.*&sort=-scheduled_execution_time');

    // Duyệt qua từng thông báo và tính toán thời gian nếu có trường scheduled_execution_time
    for (var nObj in workouts) {
      if (nObj["scheduled_execution_time"] != null) {
        try {
          nObj["time_difference_str"] =
              getNextEventTimeDifference(nObj["scheduled_execution_time"]);
          DateTime eventTime =
              DateTime.parse(nObj["scheduled_execution_time"]).toLocal();

          // Gọi hàm scheduleNotification để đặt lịch thông báo trước 30 phút
          scheduleNotification( id: 1, title: "Nhắc nhở tập luyện", body: "Bạn có buổi tập lúc ${eventTime.hour}:${eventTime.minute}. Hãy sẵn sàng nhé!", scheduledTime: eventTime);
        } catch (e) {
          print("Error processing notification: $e");
          nObj["time_difference_str"] = "Lỗi hiển thị";
        }
      } else {
        nObj["time_difference_str"] = "-";
      }
    }

    setState(() {
      lastWorkoutNotificationArr = workouts;
    });
  }

  String getNextEventTimeDifference(String scheduledTime) {
    try {
      // 1. Phân tích chuỗi scheduledTime (ví dụ: "2025-04-08T11:30:00.000Z")
      //    Lưu ý: Nếu scheduledTime có định dạng ISO nhưng bạn chỉ cần lấy thời gian, ta có thể chuyển đổi về múi giờ địa phương.
      DateTime scheduledDateTime = DateTime.parse(scheduledTime).toLocal();

      // 2. Lấy giờ, phút, giây từ scheduledDateTime
      int scheduledHour = scheduledDateTime.hour;
      int scheduledMinute = scheduledDateTime.minute;
      int scheduledSecond = scheduledDateTime.second;

      // 3. Tạo đối tượng DateTime của sự kiện theo thời gian hiện tại
      DateTime now = DateTime.now();
      DateTime nextEvent = DateTime(
        now.year,
        now.month,
        now.day,
        scheduledHour,
        scheduledMinute,
        scheduledSecond,
      );

      // 4. Nếu thời gian sự kiện của ngày hôm nay đã trôi qua, cộng thêm 1 ngày cho sự kiện kế tiếp
      if (nextEvent.isBefore(now)) {
        nextEvent = nextEvent.add(const Duration(days: 1));
      }

      // 5. Tính hiệu số thời gian giữa thời điểm hiện tại và sự kiện kế tiếp
      Duration difference = nextEvent.difference(now);
      difference = difference.abs(); // Dùng abs() để đảm bảo các giá trị dương

      int days = difference.inDays;
      int hours = difference.inHours % 24;
      int minutes = difference.inMinutes % 60;

      // 6. Xây dựng chuỗi kết quả dựa vào khoảng cách thời gian
      if (days > 0) {
        return "Còn $days ngày $hours giờ $minutes phút";
      } else if (hours > 0) {
        return "Còn $hours giờ $minutes phút";
      } else if (minutes > 0) {
        return "Còn $minutes phút";
      } else {
        return "Sắp diễn ra";
      }
    } catch (e) {
      print("Error in getNextEventTimeDifference: $e");
      return "Lỗi thời gian";
    }
  }

  Future<void> refreshData() async {
    await _fetchWorkoutNotification();
    final value = await getMealSchedule(DateTime.now().toString().substring(0, 10));
    if (!mounted) return;
    setState(() {
      todayMeals = value;
    });
  }

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon:
              Image.asset("assets/icons/back_icon.png", width: 15, height: 15),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Thông báo",
          style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: refreshData,
        child: lastWorkoutNotificationArr.isEmpty && todayMeals.isEmpty
            ? const Center(
                child: Text(
                  "Không có thông báo nào",
                  style: TextStyle(
                    color: AppColors.grayColor,
                    fontSize: 16,
                  ),
                ),
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                itemCount: lastWorkoutNotificationArr.length + todayMeals.length,
                itemBuilder: (context, index) {
                  if (index < lastWorkoutNotificationArr.length) {
                    var nObj = lastWorkoutNotificationArr[index]
                            as Map<String, dynamic>? ??
                        {};

                    return NotificationRow(nObj: nObj);
                  } else {
                    // Hiển thị thông báo từ lịch ăn uống
                    var mealObj =
                        todayMeals[index - lastWorkoutNotificationArr.length]
                                as Map<String, dynamic>? ??
                            {};
                    mealObj["time_difference_str"] = "Lịch ăn hôm nay";

                    return NotificationRow(nObj: mealObj);
                  }
                },
                separatorBuilder: (context, index) {
                  return Divider(
                      color: AppColors.grayColor.withOpacity(0.5), height: 1);
                },
              ),
      ),
    );
  }
}

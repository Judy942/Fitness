import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../core/utils/app_colors.dart';
import '../../widgets/notification_row.dart';
import '../onboarding_screen/start_screen.dart';

  Future<List> getNotification() async {
    String? token = await getToken(); // Đảm bảo phương thức này đã được định nghĩa
    final response = await http.get(
      Uri.parse('http://162.248.102.236:8055/api/activity/nearest?limit=5'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      print('Failed to load notification');
      return [];
    }
  }
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<dynamic> notificationArr = [];


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void configureLocalNotification() {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> scheduleNotification(DateTime eventTime, String title, String body) async {
  tz.initializeTimeZones();
  final tz.TZDateTime scheduledDate =
      tz.TZDateTime.from(eventTime, tz.local).subtract(const Duration(minutes: 15));

  await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    title,
    body,
    scheduledDate,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'channel_id',
        'channel_name',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
    // androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time, androidScheduleMode: AndroidScheduleMode.exact,
  );
}

Future<List> getNotification() async {
  String? token = await getToken(); // Đảm bảo phương thức này đã được định nghĩa
  final response = await http.get(
    Uri.parse('http://162.248.102.236:8055/api/activity/nearest?limit=5'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    List activities = data['data'];

    // Lên lịch thông báo cho từng lịch tập
    for (var activity in activities) {
      DateTime eventTime = DateTime.parse(activity['start_time']); // Giả sử có trường start_time
      String title = 'Lịch tập sắp tới';
      String body = 'Buổi tập "${activity['title']}" sẽ diễn ra trong 15 phút nữa.';
      scheduleNotification(eventTime, title, body);
    }

    return activities;
  } else {
    print('Failed to load notification');
    return [];
  }
}

  // Future<void> getNotification() async {
  //   String? token = await getToken(); // Đảm bảo phương thức này đã được định nghĩa
  //   final response = await http.get(
  //     Uri.parse('http://162.248.102.236:8055/api/activity/nearest?limit=5'),
  //     headers: {'Authorization': 'Bearer $token'},
  //   );

  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     setState(() {
  //       notificationArr = data['data'];
  //             print(data);
  //     });
  //   } else {
  //     print('Failed to load notification');
  //   }
  // }

  @override
  void initState() {
    super.initState();
      configureLocalNotification();

    getNotification().then((value) {
      setState(() {
        notificationArr = value;
      });
    });
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
          icon: Image.asset("assets/icons/back_icon.png", width: 15, height: 15),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Notification",
          style: TextStyle(color: AppColors.blackColor, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        itemCount: notificationArr.length,
        itemBuilder: (context, index) {
          var nObj = notificationArr[index] as Map<String, dynamic>? ?? {};
          return NotificationRow(nObj: nObj);
        },
        separatorBuilder: (context, index) {
          return Divider(color: AppColors.grayColor.withOpacity(0.5), height: 1);
        },
      ),
    );
  }
}

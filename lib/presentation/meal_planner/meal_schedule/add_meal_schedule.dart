import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/presentation/meal_planner/meal_schedule/meal_schedule.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/date_and_time.dart';
import '../../../main.dart';
import '../../../services/push_notification/NotificationCacheService.dart';
import '../../../services/push_notification/NotificationSyncService.dart';
import '../../../services/user_service.dart';
import '../../../widgets/icon_title_next_row.dart';
import '../../../widgets/round_gradient_button.dart';
import '../../workout/workout_schedule_view/add_schedule_view.dart';
import '../meal_planner_screen.dart';

class AddMealSchedule extends StatefulWidget {
  DateTime date;
  Map? obj;
  String? url;
  bool? isEdit;
  AddMealSchedule(
      {super.key, required this.date, this.obj, this.url, this.isEdit});

  @override
  State<AddMealSchedule> createState() => _AddMealScheduleState();
}

class _AddMealScheduleState extends State<AddMealSchedule> {
  bool isLoading = true; // Biến để theo dõi trạng thái tải dữ liệu
  int mealSelected = 0;
  List recommendationArr = [];

  @override
  void initState() {
    super.initState();
    getListPopular().then((value) {
      recommendationArr = value;
      if (widget.obj != null) {
        final editId = widget.obj!['dish_id']['id'] as int;
        final idx = recommendationArr.indexWhere((e) => e['id'] == editId);
        if (idx >= 0) mealSelected = idx;
      }
      isLoading = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const MealSchedule()));
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: AppColors.lightGrayColor,
                borderRadius: BorderRadius.circular(10)),
            child: Image.asset(
              "assets/icons/closed_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: const Text(
          "Lịch bữa ăn",
          style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
      ),
      backgroundColor: AppColors.whiteColor,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Hiển thị khi đang tải
          : Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          "assets/icons/date.png",
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          dateToString(widget.date,
                              formatStr: "E, dd MMMM yyyy"),
                          style: const TextStyle(
                              color: AppColors.grayColor, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "Thời gian",
                      style: TextStyle(
                          color: AppColors.blackColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: media.width * 0.35,
                      child: CupertinoDatePicker(
                        onDateTimeChanged: (newDate) {
                          // Kết hợp ngày đã chọn với giờ hiện tại
                          widget.date = DateTime(
                            widget.date.year,
                            widget.date.month,
                            widget.date.day,
                            newDate.hour,
                            newDate.minute,
                            newDate.second,
                          );
                          print(widget.date);
                        },
                        initialDateTime: widget.date,
                        use24hFormat: false,
                        minuteInterval: 1,
                        mode: CupertinoDatePickerMode.time,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "Chi tiết bữa ăn",
                      style: TextStyle(
                          color: AppColors.blackColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    IconTitleNextRow(
                      icon: "assets/icons/difficulity_icon.png",
                      title: "Bữa ăn",
                      time: (recommendationArr.isNotEmpty &&
                              recommendationArr[mealSelected] != null)
                          ? recommendationArr[mealSelected]['name']
                          : '',
                      color: AppColors.lightGrayColor,
                      onPressed: () async {
                        int? resultId =
                            await showWorkoutDialog(context, recommendationArr);
                        if (resultId != null) {
                          final newIndex = recommendationArr
                              .indexWhere((e) => e['id'] == resultId);
                          if (newIndex >= 0) {
                            setState(() {
                              mealSelected = newIndex;
                            });
                          }
                        }
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Spacer(),
                    RoundGradientButton(
                        title: "Lưu",
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });
                          print(widget.date);
                          DateTime utcDateTime = widget.date.toUtc();
                          String formattedTime = utcDateTime
                              .toIso8601String(); // không cần thêm 'Z'

                          Map<String, dynamic> data = {
                            "meal_time": formattedTime,
                            "dish_id": recommendationArr[mealSelected]['id'],
                          };

                          print(data);
                          if (widget.isEdit == true) {
                            // try {
                              await editSchedule(context, data, widget.url!);
                              print("Edit");
                              
                              
                            // } on FormatException catch (e) {
                            //   print('Có lỗi xảy ra khi chỉnh sửa: FormatException: $e');
                            // } catch (e) {
                            //   print('Có lỗi xảy ra khi chỉnh sửa: $e');
                            // }
                          } else {
                            await addMealSchedule(data, context);
                          }
                          setState(() {
                            isLoading = false;
                          });
                        }),
                    const SizedBox(
                      height: 20,
                    ),
                  ]),
            ),
    );
  }
}

Future<void> addMealSchedule(
    Map<String, dynamic> data, BuildContext context) async {
  String? token = await getToken(); // Giả định bạn đã định nghĩa hàm getToken()
  String json = jsonEncode(data);
  final response = await http.post(
    Uri.parse(
        'http://192.168.133.102:8055/items/meal_schedule?fields=*,dish_id.*'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    },
    body: json,
  );
  if (response.statusCode == 200) {
    print(response.body);
    // Phân tích cú pháp JSON từ response.body
    final Map<String, dynamic> responseData = jsonDecode(response.body);

    // Sử dụng dữ liệu đã phân tích cú pháp
    DateTime mealTime = DateTime.parse(data['meal_time']);
    int notificationId = mealTime.millisecondsSinceEpoch ~/ 1000;
    String mealName = responseData['data']['dish_id']['name'];
    await NotificationSyncService.scheduleMealNotification(
        mealTime, mealName, notificationId); // hoặc workout
    await NotificationCacheService.saveMealNotificationId(
        responseData['data']['id'].toString(), notificationId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thêm lịch thành công'),
      ),
    );
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const MealSchedule()));
  } else {
    print(response.body);

    print('Có lỗi xảy ra: ${response.statusCode} - ${response.reasonPhrase}');
  }
}

// Future<void> scheduleMealNotification(
//   DateTime mealTime,
//   String mealName,
//   int notificationId,
// ) async {
//   tz.initializeTimeZones();
//   final tz.TZDateTime scheduledDate = tz.TZDateTime.from(mealTime, tz.local)
//       .subtract(const Duration(minutes: 30));
  
//   // Định dạng thời gian theo 12 giờ với AM/PM và chuyển đổi sang giờ địa phương
//   String formattedTime = DateFormat('hh:mm a').format(mealTime.toLocal());
  
//   await flutterLocalNotificationsPlugin.zonedSchedule(
//     notificationId,
//     "Đến giờ ăn rồi 🍽️",
//     "Hôm nay bạn có bữa $mealName sau 30 phút nữa",
//     scheduledDate,
//     const NotificationDetails(
//       android: AndroidNotificationDetails(
//         'meal_channel_id',
//         'Nhắc nhở ăn uống',
//         importance: Importance.high,
//         priority: Priority.high,
//         icon: 'app_icon',
//       ),
//     ),
//     matchDateTimeComponents: DateTimeComponents.time,
//     androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
//   );
// }

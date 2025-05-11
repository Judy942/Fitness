// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/presentation/meal_planner/meal_schedule/meal_schedule.dart';
import 'package:flutter_application_fitness/presentation/workout/workout_schedule_view/workout_schedule_view.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/timezone.dart' as tz;

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/date_and_time.dart';
import '../../../main.dart';
import '../../../services/push_notification/NotificationCacheService.dart';
import '../../../services/user_service.dart';
import '../../../widgets/icon_title_next_row.dart';
import '../../../widgets/round_gradient_button.dart';
import '../../meal_planner/meal_schedule/add_meal_schedule.dart';
import '../../onboarding_screen/start_screen.dart';

class AddScheduleView extends StatefulWidget {
  DateTime date;
  Map? obj = {};
  String? url;
  bool? isEdit;
  AddScheduleView(
      {super.key, required this.date, this.obj, this.url, this.isEdit});

  @override
  State<AddScheduleView> createState() => _AddScheduleViewState();
}

class _AddScheduleViewState extends State<AddScheduleView> {
  List whatArr = [];
  bool isLoading = true; // Biến để theo dõi trạng thái tải dữ liệu
  int workoutSelected = 0;

  Future<void> getListWorkout() async {
    String? token = await getToken(); // Giả định bạn đã định nghĩa hàm getToken()

    final response = await http.get(
      Uri.parse('http://192.168.194.186:8055/items/workout?limit=5&page=1&meta=*'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      setState(() {
        whatArr = (jsonResponse['data'] as List).map((item) {
          return {
            'id': item['id'],
            'image': item['image'],
            "title": item['name'],
            "exercises": "${item['exercises'].length} Exercises",
            "time": "${item['time']} mins"
          };
        }).toList();
        isLoading = false; // Đánh dấu rằng dữ liệu đã được tải
      });
    } else {
      // Xử lý lỗi
      print('Có lỗi xảy ra: ${response.body}');
      setState(() {
        isLoading = false; // Cũng đánh dấu là đã xong
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getListWorkout().then((_) {
      if (widget.obj != null) {
        if (widget.obj!['workout_id'] != null) {
          workoutSelected = whatArr
              .indexWhere((item) => item['id'] == widget.obj!['workout_id']);
        }
      }
      setState(() {}); // để rebuild UI sau khi load dữ liệu
    });
  }
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != widget.date) {
      setState(() {
        widget.date = DateTime(
          picked.year,
          picked.month,
          picked.day,
          widget.date.hour,
          widget.date.minute,
          widget.date.second,
        );
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    print("workoutSelected: $workoutSelected");
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
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
          "Add Schedule",
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
                    GestureDetector(
                    onTap: _pickDate,
                      child: Row(
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
                      
                            const SizedBox(
                            width: 18,
                          ),
                            const Icon(Icons.edit, size: 18, color: Colors.grey),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "Time",
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
                          // widget.date = DateTime(
                          //   widget.date.year,
                          //   widget.date.month,
                          //   widget.date.day,
                          //   newDate.hour,
                          //   newDate.minute,
                          //   newDate.second,
                          // );

                          setState(() {
                            widget.date = DateTime(
                              widget.date.year,
                              widget.date.month,
                              widget.date.day,
                              newDate.hour,
                              newDate.minute,
                              newDate.second,
                            );
                          });
                          print(widget.date);
                        },
                        initialDateTime: widget.date, //DateTime.now(),
                        use24hFormat: false,
                        minuteInterval: 1,
                        mode: CupertinoDatePickerMode.time,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "Details Workout",
                      style: TextStyle(
                          color: AppColors.blackColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    IconTitleNextRow(
                      icon: "assets/icons/choose_workout.png",
                      title: "Choose Workout",
                      time: whatArr.isNotEmpty
                          ? whatArr[workoutSelected]['title']
                          : '',
                      color: AppColors.lightGrayColor,
                      onPressed: () async {
                        int? selectedId =
                            await showWorkoutDialog(context, whatArr);
                        if (selectedId != null) {
                          workoutSelected = whatArr
                              .indexWhere((item) => item['id'] == selectedId);
                          setState(() {});
                        }
                      },
                    ),
                  
                    const Spacer(),
                    RoundGradientButton(
                        title: "Save",
                        onPressed: () {
                          String formattedTime =
                              '${widget.date.toIso8601String()}+07:00';
                          Map<String, dynamic> data = {
                            "scheduled_execution_time": formattedTime,
                            "workout_id": whatArr[workoutSelected]['id'],
                            // "difficulty_id": diffArr[diffSelected]['id'],
                          };
                          print(data);
                          if (widget.isEdit == true) {
                            editSchedule(context, data, widget.url!);
                            print("Edit");
                          } else {
                            addWorkoutSchedule(data, context);
                            print("Add");
                          }
                        }),
                    const SizedBox(
                      height: 20,
                    ),
                  ]),
            ),
    );
  }
}

// Future<void> editSchedule(
//     BuildContext context, Map<String, dynamic> eObj, String url) async {
//   String? token = await getToken();
//   final response = await http.patch(
//     Uri.parse(url),
//     headers: {
//       'Authorization': 'Bearer $token',
//       'Content-Type': 'application/json',
//     },
//     body: jsonEncode(eObj),
//   );
//   if (response.statusCode == 200 ||
//       response.statusCode == 204 ||
//       response.statusCode == 201) {
//     // Gọi hàm edit ở đây
//     // print("Edit workout: ${response.body}");
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Edit successfully!'),
//       ),
//     );
//     final Map<String, dynamic> responseData = jsonDecode(response.body);

//     final notificationId = await NotificationCacheService.getNotificationId(
//         responseData['data']['id'],
//         isWorkout: true);
//     if (notificationId != null) {
//       await flutterLocalNotificationsPlugin.cancel(notificationId);
//       await NotificationCacheService.removeNotificationId(
//           responseData['data']['id'],
//           isWorkout: true);
//     }

//     if (eObj["workout_id"] != null) {
//        DateTime workoutTime = DateTime.parse(eObj['scheduled_execution_time']);
//     int newNotificationId = workoutTime.millisecondsSinceEpoch ~/ 1000;
//     String workoutName = responseData['data']['workout_id']['name'];

//     await scheduleWorkoutNotification(
//         workoutTime, workoutName, newNotificationId);
//     await NotificationCacheService.saveWorkoutNotificationId(
//         responseData['data']['id'], newNotificationId);

//       Navigator.pushReplacement(context,
//           MaterialPageRoute(builder: (context) => const WorkoutScheduleView()));
//     } else {
//        DateTime mealTime = DateTime.parse( responseData['data']['meal_time']);
//     int newNotificationId = mealTime.millisecondsSinceEpoch ~/ 1000;
//     String workoutName = responseData['data']['dish_id']['name'];

//     await scheduleMealNotification(
//         mealTime, workoutName, newNotificationId);
//     await NotificationCacheService.saveWorkoutNotificationId(
//         responseData['data']['id'], newNotificationId);

//       Navigator.pushReplacement(context,
//           MaterialPageRoute(builder: (context) => const MealSchedule()));
//     }
//   } else {
//     print("Failed to get workout: ${response.body}");
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Failed to edit!'),
//       ),
//     );
//     Navigator.pop(context);
//     Navigator.pop(context);
//   }
// }

Future<void> editSchedule(
    BuildContext context, Map<String, dynamic> eObj, String url) async {
  final token = await getToken();
  final response = await http.patch(
    Uri.parse('$url?fields=*,workout_id.*,dish_id.*'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(eObj),
  );

  if (response.statusCode == 200 ||
      response.statusCode == 201 ||
      response.statusCode == 204) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit successfully!')),
    );

    final data = jsonDecode(response.body)['data'];
    // Huỷ và xóa cache notification cũ
    final oldId = await NotificationCacheService.getNotificationId(data['id'],
        isWorkout: eObj.containsKey('workout_id'));
    if (oldId != null) {
      await flutterLocalNotificationsPlugin.cancel(oldId);
      await NotificationCacheService.removeNotificationId(data['id'],
          isWorkout: eObj.containsKey('workout_id'));
    }

    if (eObj.containsKey("workout_id")) {
      // Workout branch
      final workoutTime =
          DateTime.parse(eObj['scheduled_execution_time']).toLocal();
      // String formattedTime = '${workoutTime.toIso8601String()}-07:00';
      final newId = workoutTime.millisecondsSinceEpoch ~/ 1000;
      final workoutName = data['workout_id']['name'];
      await scheduleWorkoutNotification(workoutTime, workoutName, newId);
      await NotificationCacheService.saveWorkoutNotificationId(
          data['id'], newId);

      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const WorkoutScheduleView()));
    } else {
      // Meal branch
      final mealTime = DateTime.parse(data['meal_time']);
      final newId = mealTime.millisecondsSinceEpoch ~/ 1000;
      final mealName = data['dish_id']['name'];
      await scheduleMealNotification(mealTime, mealName, newId);
      await NotificationCacheService.saveMealNotificationId(data['id'], newId);

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const MealSchedule()));
    }
  } else {
    debugPrint("Edit failed: ${response.body}");
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Failed to edit!')));
  }
}

Future<void> addWorkoutSchedule(
    Map<String, dynamic> data, BuildContext context) async {
  String? token = await getToken(); // Giả định bạn đã định nghĩa hàm getToken()
  String json = jsonEncode(data);
  final response = await http.post(
    Uri.parse(
        'http://192.168.194.186:8055/items/workout_schedule?fields=*,workout_id.*'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    },
    body: json,
  );
  if (response.statusCode == 200) {
    print(response.body);
    //hiển thị thông báo
    final responseData = jsonDecode(response.body)['data'];
    DateTime workoutTime =
        DateTime.parse(responseData['scheduled_execution_time']);
    int notificationId = workoutTime.millisecondsSinceEpoch ~/ 1000;
    String workoutName = responseData['workout_id']
        ['name']; // nếu server trả về tên, hoặc lưu sẵn ở client
    await scheduleWorkoutNotification(workoutTime, workoutName, notificationId);
    await NotificationCacheService.saveWorkoutNotificationId(
        responseData['id'], notificationId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add schedule success'),
      ),
    );
    // Navigator.pop(context);
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const WorkoutScheduleView()));
  } else {
    // Xử lý lỗi
    print('Có lỗi xảy ra: ${response.statusCode} - ${response.reasonPhrase}');
  }
}

Future<int?> showWorkoutDialog(BuildContext context, List itemList) async {
  int? selectedId;
  print('itemList $itemList');
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Select'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                    itemList[index]['title'] ?? itemList[index]['name'] ?? ''),
                onTap: () {
                  selectedId = itemList[index]['id'];
                  Navigator.of(context).pop();
                },
              );
            },
            separatorBuilder: (context, index) => const Divider(),
            itemCount: itemList.length,
          ),
        ),
      );
    },
  );
  return selectedId;
}

Future<void> scheduleWorkoutNotification(
    DateTime workoutTime, String workoutName, int notificationId) async {
  print("workoutTime: $workoutTime");
  final tz.TZDateTime scheduledDate = tz.TZDateTime.from(workoutTime, tz.local)
      .subtract(const Duration(minutes: 30));
  await flutterLocalNotificationsPlugin.zonedSchedule(
    notificationId,
    "Đến giờ tập rồi 🏋️",
    "Hôm nay bạn có lịch tập $workoutName lúc ${workoutTime.hour}:${workoutTime.minute}",
    scheduledDate,
    const NotificationDetails(
      android: AndroidNotificationDetails(
          'workout_channel_id', 'Nhắc nhở tập luyện',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'app_icon'),
    ),
    matchDateTimeComponents: DateTimeComponents.time,
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
  );
}

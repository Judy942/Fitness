import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/date_and_time.dart';
import '../../../widgets/icon_title_next_row.dart';
import '../../../widgets/round_gradient_button.dart';
import '../../onboarding_screen/start_screen.dart';
import '../../workout/workout_schedule_view/add_schedule_view.dart';
import '../meal_planner_detail/meal_planner_detail_screen.dart';

class AddMealSchedule extends StatefulWidget {
  DateTime date;

  AddMealSchedule({super.key, required this.date});

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
    getRecommendation().then((value) {
      setState(() {
        recommendationArr = value;
        isLoading = false;
      });
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
                        initialDateTime: DateTime.now(),
                        use24hFormat: false,
                        minuteInterval: 1,
                        mode: CupertinoDatePickerMode.time,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "Details meal",
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
                        title: "Meal",
                        time: (recommendationArr.isNotEmpty &&
                                recommendationArr[0] != null)
                            ? recommendationArr[0]['name']
                            : '',
                        color: AppColors.lightGrayColor,
                        onPressed: () async {
                          mealSelected = await showWorkoutDialog(
                                  context, recommendationArr) -
                              1;
                          print(mealSelected);
                          setState(() {});
                        }),
                    const SizedBox(
                      height: 10,
                    ),
                    const Spacer(),
                    RoundGradientButton(
                        title: "Save",
                        onPressed: () {
                          print(widget.date);

                          // String formattedTime =
                          //     '${widget.date.toIso8601String()}+07:00';
                          // Map<String, dynamic> data = {
                          //   "meal_time": formattedTime,
                          //   "dish_id": recommendationArr[mealSelected]['id'],
                          //   // "difficulty_id": diffArr[diffSelected]['id'],
                          // };
                          // print(data);
                          // addMealSchedule(data, context);
                          DateTime utcDateTime = widget.date.toUtc();
                          String formattedTime = utcDateTime
                              .toIso8601String(); // không cần thêm 'Z'

                          Map<String, dynamic> data = {
                            "meal_time": formattedTime,
                            "dish_id": recommendationArr[mealSelected]['id'],
                          };

                          print(data);
                          addMealSchedule(data, context);
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
    Uri.parse('http://162.248.102.236:8055/items/meal_schedule'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    },
    body: json,
  );
  if (response.statusCode == 200) {
    print(response.body);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add schedule success'),
      ),
    );
    Navigator.pop(context);
  } else {
    print(response.body);

    print('Có lỗi xảy ra: ${response.statusCode} - ${response.reasonPhrase}');
  }
}

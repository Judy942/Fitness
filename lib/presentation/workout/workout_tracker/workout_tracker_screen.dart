import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/presentation/workout/workout_schedule_view/workout_schedule_view.dart';
import 'package:http/http.dart' as http;

import '../../../core/utils/app_colors.dart';
import '../../../services/user_service.dart';
import '../../../widgets/round_button.dart';
import '../../../widgets/what_train_row.dart';
import '../../onboarding_screen/start_screen.dart';

Future<List> getListWorkout() async {
  String? token = await getToken(); // Giả định bạn đã định nghĩa hàm getToken()
  List whatArr = [];
  final response = await http.get(
    // Uri.parse('http://192.168.133.103:8055/items/workout?limit=5&page=1&meta=*'),
        Uri.parse('http://192.168.133.103:8055/items/workout'),

    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    print(jsonResponse);
    whatArr = (jsonResponse['data'] as List).map((item) {
      return {
        'type': item['type'],
        'id': item['id'],
        'image': item['image'],
        "title": item['name'],
        "exercises": "${item['exercises'].length} Exercises",
        "time": "${item['time'] ?? 'null'} mins" // Cập nhật để hiển thị 'null' nếu không có thời gian
      };
    }).toList();
  } else {
    // Xử lý lỗi
    print('Có lỗi xảy ra: ${response.statusCode} - ${response.reasonPhrase}');
  }
  return whatArr;
}

class WorkoutTrackerScreen extends StatefulWidget {
  const WorkoutTrackerScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutTrackerScreen> createState() => _WorkoutTrackerScreenState();
}

class _WorkoutTrackerScreenState extends State<WorkoutTrackerScreen> {
  List whatArr = [];
  List workoutSuggestion = [];

  Future<void> refreshData() async {
    final value = await getListWorkout();
    String? bmi = await getBmi();
    double bmiValue = double.tryParse(bmi) ?? 0.0;
    
    setState(() {
      whatArr = value;
      if (bmiValue < 18.5) {
        workoutSuggestion = whatArr.where((item) => item['type'] == 1).toList();
      } else if (bmiValue >= 18.5 && bmiValue < 23) {
        workoutSuggestion = whatArr.where((item) => item['type'] == 0).toList();
      } else {
        workoutSuggestion = whatArr.where((item) => item['type'] == 2).toList();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Container(
      decoration:
          BoxDecoration(gradient: LinearGradient(colors: AppColors.primary)),
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            const SliverAppBar(
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
              title: Text(
                "Workout Tracker",
                style: TextStyle(
                    color: AppColors.whiteColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
            ),
            SliverAppBar(
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
              leadingWidth: 0,
              leading: const SizedBox(),
              expandedHeight: media.height * 0.05,
              flexibleSpace: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                height: media.width * 0.5,
                width: double.maxFinite,
              ),
            )
          ];
        },
        body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: const BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25))),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: RefreshIndicator(
                onRefresh: refreshData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 50,
                        height: 4,
                        decoration: BoxDecoration(
                            color: AppColors.grayColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(3)),
                      ),
                      SizedBox(
                        height: media.width * 0.05,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 15),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor2.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Daily Workout Schedule",
                              style: TextStyle(
                                  color: AppColors.blackColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700),
                            ),
                            SizedBox(
                              width: 80,
                              height: 30,
                              child: RoundButton(
                                type: RoundButtonType.primaryBG,
                                title: "Check",
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const WorkoutScheduleView()));
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: media.width * 0.05,
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Workouts for you",
                            style: TextStyle(
                                color: AppColors.blackColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      ListView.builder(
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: workoutSuggestion.length,
                          itemBuilder: (context, index) {
                            var wObj = workoutSuggestion[index] as Map? ?? {};
                            return WhatTrainRow(
                              wObj: wObj,
                            );
                          }),
                      SizedBox(
                        height: media.width * 0.05,
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "All workouts",
                            style: TextStyle(
                                color: AppColors.blackColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      ListView.builder(
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: whatArr.length,
                          itemBuilder: (context, index) {
                            var wObj = whatArr[index] as Map? ?? {};
                            return WhatTrainRow(
                              wObj: wObj,
                            );
                          }),
                      SizedBox(
                        height: media.width * 0.1,
                      ),
                    ],
                  ),
                ),
              ),
            )),
      ),
    );
  }
}

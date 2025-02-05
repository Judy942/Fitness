import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/presentation/workout/workout_schedule_view/workout_schedule_view.dart';
import 'package:http/http.dart' as http;

import '../../../core/utils/app_colors.dart';
import '../../../widgets/round_button.dart';
import '../../../widgets/what_train_row.dart';
import '../../notification/notification_screen.dart';
import '../../onboarding_screen/start_screen.dart';


Future<List> getListWorkout() async {
    String? token = await getToken(); // Giả định bạn đã định nghĩa hàm getToken()
    List whatArr = [];
    final response = await http.get(
      Uri.parse(
          'http://192.168.95.1:8055/items/workout?limit=5&page=1&meta=*'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      print(jsonResponse);
      // setState(() {
        whatArr = (jsonResponse['data'] as List).map((item) {
          return {
            'id': item['id'],
            'image': item['image'],
            "title": item['name'],
            "exercises": "${item['exercises'].length} Exercises",
            "time": "${item['time']} mins"
            // Bạn có thể thêm bất kỳ trường nào bạn muốn ở đây
          };
        }).toList();
      // });
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
  List latestArr = [
  ];

  List whatArr = [];

  @override
  void initState() {
    super.initState();
    getListWorkout().then((value) {
      setState(() {
        whatArr = value;
      });
    });
    getNotification().then((value) {
      setState(() {
        latestArr = value;
      });
    });
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
            SliverAppBar(
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
              // pinned: true,
              title: const Text(
                "Workout Tracker",
                style: TextStyle(
                    color: AppColors.whiteColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              actions: [
                InkWell(
                  onTap: () {},
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    height: 40,
                    width: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: AppColors.lightGrayColor,
                        borderRadius: BorderRadius.circular(10)),
                    child: Image.asset(
                      "assets/icons/more_icon.png",
                      width: 15,
                      height: 15,
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              ],
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
              body: SingleChildScrollView(
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
                                // Navigator.pushNamed(
                                //     context, '/workoutScheduleView');

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
                    SizedBox(
                      height: media.width * 0.05,
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "What Do You Want to Train",
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
            )),
      ),
    );
  }


}

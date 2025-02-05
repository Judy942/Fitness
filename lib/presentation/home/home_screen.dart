
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/presentation/activity_tracker/activity_tracker_screen.dart';
import 'package:flutter_application_fitness/presentation/notification/notification_screen.dart';
import 'package:http/http.dart' as http;

import '../../core/utils/app_colors.dart';
import '../../widgets/round_button.dart';
import '../../widgets/workout_row.dart';
import '../onboarding_screen/start_screen.dart';
import 'how_to_calculate_bmi.dart';

 Future<Map<String, dynamic>> getUserData() async {
    String? token = await getToken();
    Map<String, dynamic> userData = {};

    if (token != null) {
      // Gọi API để lấy thông tin người dùng
      final response = await http.get(
        Uri.parse('http://192.168.95.1:8055/users/me'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        userData = responseData['data'];
        return userData;
      } else {
        await clearLocalData();
        return userData;
      }
    } else {
      return userData;
    }
  }

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

    Map<String, dynamic> userData = {};
    String bmi = '0';
  @override
  void initState() {
    super.initState();
    getUserData().then((data) {
      setState(() {
        userData = data;
      });
    });
    getBmi().then((value) {
      setState(() {
        bmi = value =="null"? '0': value;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    // final prefsNotifier = Provider.of<PreferencesNotifier>(context);

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 TopBar(userData['last_name'] ?? ""),
                SizedBox(height: media.width * 0.05),
                 ContainerBmi(bmi: bmi),
                SizedBox(height: media.width * 0.05),
                const TodayTargetSection(),
                SizedBox(height: media.width * 0.05),
                LatestWorkoutSection(),
                SizedBox(height: media.width * 0.1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TopBar extends StatelessWidget {
  final String name;
  const TopBar(this.name, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome Back,",
              style: TextStyle(
                color: AppColors.midGrayColor,
                fontSize: 12,
              ),
            ),
            Text(
              name,
              style: const TextStyle(
                color: AppColors.blackColor,
                fontSize: 20,
                fontFamily: "Poppins",
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            // Navigator.pushNamed(context, '/notificationScreen');
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const NotificationScreen();
            }));
          },
          icon: Image.asset(
            "assets/icons/notification_icon.png",
            width: 25,
            height: 25,
            fit: BoxFit.fitHeight,
          ),
        ),
      ],
    );
  }
}

class ContainerBmi extends StatelessWidget {
  String bmi;
  ContainerBmi({super.key, required this.bmi});

  @override
  Widget build(BuildContext context) {
    List<PieChartSectionData> showingSections(String bmi) {
                const color0 = AppColors.secondaryColor2;
          const color1 = AppColors.whiteColor;
      return List.generate(
        2,
        (i) {


          switch (i) {
            case 0:
              return PieChartSectionData(
                  color: color0,
                  value: 33,
                  title: '',
                  radius: 55,
                  titlePositionPercentageOffset: 0.55,
                  badgeWidget: Text(
                    bmi,
                    style: const TextStyle(
                        color: AppColors.whiteColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12),
                  ));
            case 1:
              return PieChartSectionData(
                color: color1,
                value: 75,
                title: '',
                radius: 42,
                titlePositionPercentageOffset: 0.55,
              );
            default:
              throw Error();
          }
        },
      );
    }

    return Container(
      height: MediaQuery.of(context).size.width * 0.4,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AppColors.primary),
        borderRadius:
            BorderRadius.circular(MediaQuery.of(context).size.width * 0.065),
      ),
      child: _buildBMIContent(bmi , context)
    );
  }

  Widget _buildBMIContent(String bmi, BuildContext context) {
        // final prefsNotifier = Provider.of<PreferencesNotifier>(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          "assets/icons/bg_dots.png",
          height: MediaQuery.of(context).size.width * 0.4,
          width: double.maxFinite,
          fit: BoxFit.fitHeight,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "BMI (Body Mass Index)",
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    bmi == "0" ? "Enter your height and weight": bmi,
                    style: TextStyle(
                      color: AppColors.whiteColor.withOpacity(0.7),
                      fontSize: 12,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.width * 0.05),
                  Padding(
                    padding: const EdgeInsets.all(0),
                    child: SizedBox(
                      height: 35,
                      width: 100,
                      child: RoundButton(
                        title: "View More",
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return const AlertDialog(
                                title: Text("How to calculate BMI"),
                                content: HowToCalculateBmi(),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              AspectRatio(
                aspectRatio: 1,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                    ),
                    startDegreeOffset: 250,
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 1,
                    centerSpaceRadius: 0,
                    sections: showingSections(bmi), // Use the BMI value here
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> showingSections(String bmi) {
    return List.generate(
      2,
      (i) {
        const color0 = AppColors.secondaryColor2;
        const color1 = AppColors.whiteColor;

        switch (i) {
          case 0:
            return PieChartSectionData(
                color: color0,
                // color: AppColors.blackColor,
                value: double.parse(bmi),
                title: '',
                radius: 55,
                titlePositionPercentageOffset: 0.55,
                // badgeWidget: const Text("20.1", style: TextStyle(
                badgeWidget: Text(
                  bmi,
                  style: const TextStyle(
                      color: AppColors.whiteColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12),
                ));
          case 1:
            return PieChartSectionData(
              color: color1,
              value: 100 - double.parse(bmi),
              title: '',
              radius: 42,
              titlePositionPercentageOffset: 0.55,
            );
          default:
            throw Error();
        }
      },
    );
  }
}
class TodayTargetSection extends StatelessWidget {
  const TodayTargetSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: AppColors.primaryColor1.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Today Target",
            style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(
            width: 75,
            height: 30,
            child: RoundButton(
              title: "Check",
              type: RoundButtonType.primaryBG,
              onPressed: () {
              // Navigator.pushNamed(context, AppRoutes.activityTrackerScreen);
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const ActivityTrackerScreen();
              }));

              },
            ),
          ),
        ],
      ),
    );
  }
}

class LatestWorkoutSection extends StatelessWidget {
  List lastWorkoutArr = [
    {
      "name": "Full Body Workout",
      "image": "assets/images/Workout1.png",
      "kcal": "180",
      "time": "20",
      "progress": 0.3
    },
    {
      "name": "Lower Body Workout",
      "image": "assets/images/Workout2.png",
      "kcal": "200",
      "time": "30",
      "progress": 0.4
    },
    {
      "name": "Ab Workout",
      "image": "assets/images/Workout3.png",
      "kcal": "300",
      "time": "40",
      "progress": 0.7
    },
  ];

  LatestWorkoutSection({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Latest Workout", style: sectionTitleStyle),
            TextButton(
              onPressed: () {},
              child: const Text(
                "See More",
                style: TextStyle(
                  color: AppColors.grayColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        ListView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: lastWorkoutArr.length,
          itemBuilder: (context, index) {
            var wObj = lastWorkoutArr[index] as Map? ?? {};
            return WorkoutRow(wObj: wObj);
          },
        ),
      ],
    );
  }
}

const TextStyle sectionTitleStyle = TextStyle(
  color: AppColors.blackColor,
  fontSize: 16,
  fontWeight: FontWeight.w600,
);

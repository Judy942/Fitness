// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/presentation/activity_tracker/activity_tracker_screen.dart';
import 'package:flutter_application_fitness/presentation/notification/notification_screen.dart';
import 'package:http/http.dart' as http;

import '../../core/utils/app_colors.dart';
import '../../services/user_service.dart';
import '../../widgets/round_button.dart';
import '../../widgets/workout_row.dart';
import '../onboarding_screen/start_screen.dart';

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
                const LatestWorkoutSection(),
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

  String _getBMICategory(String bmiValue) {
    if (bmiValue == "0") return "Chưa có dữ liệu";
    
    double bmiDouble;
    try {
      bmiDouble = double.parse(bmiValue);
    } catch (e) {
      return "Không hợp lệ";
    }
    
    if (bmiDouble < 18.5) return "Bạn nên tăng cân";
    if (bmiDouble < 23) return "Nên duy trì chế độ ăn uống và tập luyện";
    if (bmiDouble < 30) return "Bạn nên giảm cân";
    return "Bạn cần giảm cân";
  }

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
      height: MediaQuery.of(context).size.width * 0.38,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AppColors.primary),
        borderRadius:
            BorderRadius.circular(MediaQuery.of(context).size.width * 0.065),
      ),
      child: _buildBMIContent(bmi , context)
    );
  }

  Widget _buildBMIContent(String bmi, BuildContext context) {
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
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
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
                    bmi == "0" ? "Enter your height and weight" : bmi,
                    style: TextStyle(
                      color: AppColors.whiteColor.withOpacity(0.7),
                      fontSize: 14,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.width * 0.05),
                  Text(
                    _getBMICategory(bmi).replaceAllMapped(
                      RegExp(r'(.{1,25})(\s|$)'),
                      (match) => '${match.group(0)}\n',
                    ),
                    style: TextStyle(
                      color: AppColors.whiteColor.withOpacity(0.8),
                      fontSize: 14,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
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
                    sections: showingSections(bmi),
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
                value: double.parse(bmi),
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
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return  const ActivityTrackerScreen();
              }));

              },
            ),
          ),
        ],
      ),
    );
  }
}

class LatestWorkoutSection extends StatefulWidget {
  const LatestWorkoutSection({super.key});

  @override
  State<LatestWorkoutSection> createState() => _LatestWorkoutSectionState();
}

class _LatestWorkoutSectionState extends State<LatestWorkoutSection> {
  final UserService _userService = UserService(); // Create an instance
  List lastWorkoutArr = [];

  @override
  void initState() {
    super.initState();
    _fetchWorkoutData();
  }

Future<void> _fetchWorkoutData() async {
  List<dynamic> workouts = await _userService.fetchData(
    // 'http://192.168.95.1:8055/items/workout_schedule?fields=*,completed_exercise.exercise_id.*,workout_id.*&sort=-scheduled_execution_time'
    'http://192.168.95.1:8055/items/workout_schedule?fields=*,completed_exercise.*,workout_id.*&sort=-scheduled_execution_time'
  );

  setState(() {
    lastWorkoutArr = workouts;
  });
} 


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Your Activity", style: sectionTitleStyle),
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

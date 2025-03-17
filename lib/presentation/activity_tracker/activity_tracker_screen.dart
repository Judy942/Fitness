import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/presentation/dashboard/dashboard_screen.dart';
import 'package:http/http.dart' as http;
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/app_colors.dart';
import '../../widgets/latest_activity_row.dart';
import '../meal_planner/meal_schedule/meal_schedule.dart';
import '../onboarding_screen/start_screen.dart';

class ActivityTrackerScreen extends StatefulWidget {
  const ActivityTrackerScreen({Key? key}) : super(key: key);

  @override
  State<ActivityTrackerScreen> createState() => _ActivityTrackerScreenState();
}

class _ActivityTrackerScreenState extends State<ActivityTrackerScreen> {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '?', _steps = '0';
  int touchedIndex = -1;
  int totalStepsToday = 0;
  int totalRunSteps = 0;
  int totalSleepHours = 0;

  Future<void> checkAndResetSteps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastDate = prefs.getString('lastDate');

    String today =
        DateTime.now().toIso8601String().substring(0, 10); // Lấy ngày hiện tại

    if (lastDate != today) {
      // Nếu ngày đã thay đổi, reset tổng số bước
      totalStepsToday = 0;
      prefs.setString('lastDate', today); // Cập nhật ngày
    }
  }

  Future<void> requestLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      await Permission.location.request();
    }
  }

  Future<List> latestActivity() async {
    String? token =
        await getToken(); // Giả định bạn đã định nghĩa hàm getToken()

    final response = await http.get(
      Uri.parse('http://192.168.95.1:8055/api/activity/latest?limit=5'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic> && data['data'] != null) {
        return List.from(data['data']); // Trả về List từ trường 'data'
      } else {
        throw Exception('Invalid data format');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  List latestArr = [];

  int calories = 0;

  @override
  void initState() {
    super.initState();
    // checkAndResetSteps();
    // initPlatformState();
    getMealSchedule(DateTime.now().toString().substring(0, 10)).then((value) {
      setState(() {
        for (var wObj in value) {
          wObj["meals"].forEach((sObj) {
            calories += (sObj["dish_id"]["nutritions"][0]["value"] as int);
          });
        }
      });
    });
    latestActivity().then((value) {
      setState(() {
        latestArr = value;
      });
    });
  }

  void onStepCount(StepCount event) {
    print(event);
    setState(() {
      totalStepsToday = event.steps; // Cộng số bước mới vào tổng
      _steps = event.steps.toString();
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    print(event);
    setState(() {
      _status = event.status;
    });
  }

  void onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    print(_status);
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      _steps = 'Not available';
    });
  }

  Future<bool> _checkActivityRecognitionPermission() async {
    bool granted = await Permission.activityRecognition.isGranted;

    if (!granted) {
      granted = await Permission.activityRecognition.request() ==
          PermissionStatus.granted;
    }

    return granted;
  }

  Future<void> requestPermissions() async {
    // Yêu cầu quyền truy cập vị trí
    var locationStatus = await Permission.location.request();
    if (locationStatus.isDenied) {
      // Nếu người dùng từ chối quyền, có thể hiển thị thông báo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission is required.')),
      );
    } else if (locationStatus.isPermanentlyDenied) {
      // Nếu người dùng từ chối vĩnh viễn, hướng dẫn họ mở cài đặt
      openAppSettings();
    }

    // Yêu cầu quyền nhận diện hoạt động
    var activityStatus = await Permission.activityRecognition.request();
    if (activityStatus.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Activity recognition permission is required.')),
      );
    } else if (activityStatus.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> initPlatformState() async {
    bool granted = await _checkActivityRecognitionPermission();
    if (!granted) {
      await requestPermissions();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Permission to access activity recognition is required.')),
      );
    }

    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    (_pedestrianStatusStream.listen(onPedestrianStatusChanged))
        .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const DashboardScreen(),
              ),
              (route) => false, // Xóa tất cả các route trong stack
            );
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: AppColors.lightGrayColor,
                borderRadius: BorderRadius.circular(10)),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: AppColors.blackColor,
                size: 20,
              ),
              onPressed: () {
                // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DashboardScreen(),
                  ),
                  (route) => false, // Xóa tất cả các route trong stack
                );
              },
            ),
          ),
        ),
        title: const Text(
          "Activity Tracker",
          style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppColors.primaryColor2.withOpacity(0.3),
                  AppColors.primaryColor1.withOpacity(0.3)
                ]),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Expanded(
                child: SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: double.maxFinite,
                          height: MediaQuery.of(context).size.width * 0.45,
                          padding: const EdgeInsets.symmetric(
                              vertical: 25, horizontal: 20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.black12, blurRadius: 2)
                              ]),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Sleep",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700),
                                ),
                                ShaderMask(
                                  blendMode: BlendMode.srcIn,
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                            colors: AppColors.primary,
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight)
                                        .createShader(Rect.fromLTRB(0, 0,
                                            bounds.width, bounds.height));
                                  },
                                  child: Text(
                                    "8h 20m",
                                    style: TextStyle(
                                        color: AppColors.whiteColor
                                            .withOpacity(0.7),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14),
                                  ),
                                ),
                                // const Spacer(),
                                Image.asset("assets/images/sleep_graph.png",
                                    height: 100,
                                    width:
                                        MediaQuery.of(context).size.width *
                                            0.8,
                                    fit: BoxFit.fill),
                              ]),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoCard(Icons.favorite, 'Heart Pts',
                                '60/100', Colors.grey[500]),
                            _buildInfoCard(Icons.directions_walk, 'Steps',
                                '8225', Colors.pink[100],
                                textColor: Colors.pink),
                            
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoCard(null, 'Cal', '300', Colors.white,
                                textColor: Colors.black),
                            _buildInfoCard(null, 'km', '15', Colors.white,
                                textColor: Colors.black),
                            _buildInfoCard(
                                null, 'Move Min', '56', Colors.white,
                                textColor: Colors.black),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Latest Activity",
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
                            itemCount: latestArr.length,
                            itemBuilder: (context, index) {
                              var wObj = latestArr[index] as Map? ?? {};
                              return LatestActivityRow(wObj: wObj);
                            }),
                        SizedBox(
                          height: media.width * 0.1,
                        ),
                      ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      IconData? icon, String title, String value, Color? color,
      {Color textColor = Colors.black}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            const BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            if (icon != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: textColor),
                  const SizedBox(width: 8),
                  Text(title, style: TextStyle(color: textColor, fontSize: 18)),
                ],
              ),
              const SizedBox(height: 6),
            ] else
              Text(title, style: TextStyle(color: textColor, fontSize: 18)),
            Text(value,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor)),
          ],
        ),
      ),
    );
  }
}

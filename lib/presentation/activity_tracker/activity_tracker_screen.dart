import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/presentation/dashboard/dashboard_screen.dart';
import 'package:health/health.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;

import '../../core/utils/app_colors.dart';
import '../../services/user_service.dart';
import '../../widgets/latest_activity_row.dart';
import '../../widgets/round_button.dart';
import '../meal_planner/meal_planner_screen.dart';
import 'statistics_screen.dart';

class ActivityTrackerScreen extends StatefulWidget {
  const ActivityTrackerScreen({Key? key}) : super(key: key);

  @override
  State<ActivityTrackerScreen> createState() => _ActivityTrackerScreenState();
}

class _ActivityTrackerScreenState extends State<ActivityTrackerScreen> {
  int totalStepsToday = 0;
  double totalDistance = 0;
  double totalBurnCal = 0; // Đổi tên biến
  List latestArr = [];
  bool isLoadingHealth = false;
  bool isLoadingActivities = false;
  final Health _health = Health();
  final List<HealthDataType> _dataTypes = [
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.TOTAL_CALORIES_BURNED, // Thêm loại dữ liệu cho calo
  ];

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _requestPermissions();
      await _loadHealthDataEnhanced();
      await _loadLatestActivity();
    });
  }

  Future<void> _requestPermissions() async {
    try {
      await Permission.activityRecognition.request();
      await Permission.sensors.request();
      await Permission.location.request();
      bool requested = await _health.requestAuthorization(_dataTypes);
      if (!requested && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Health permissions denied')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error requesting permissions: $e')),
        );
      }
    }
  }

  Future<void> _loadHealthDataEnhanced() async {
    setState(() => isLoadingHealth = true);
    try {
      final now = DateTime.now();
      final startOfDayUtc = DateTime(now.year, now.month, now.day).toUtc();
      final nowUtc = now.toUtc();
      Map<HealthDataType, List<HealthDataPoint>> dataByType = {};
      for (var type in _dataTypes) {
        try {
          final data = await _health.getHealthDataFromTypes(
            types: [type],
            startTime: startOfDayUtc,
            endTime: nowUtc,
          );
          dataByType[type] = data;
        } catch (e) {
          dataByType[type] = [];
        }
      }
      int steps = 0;
      double distance = 0.0;
      double burnCal = 0.0; // Biến cho calo
      var stepsData = dataByType[HealthDataType.STEPS] ?? [];
      for (var point in stepsData) {
        if (point.value is NumericHealthValue) {
          var value = (point.value as NumericHealthValue).numericValue;
          if (value > 0) steps += value.toInt();
        }
      }
      var distanceData = dataByType[HealthDataType.DISTANCE_DELTA] ?? [];
      for (var point in distanceData) {
        if (point.value is NumericHealthValue) {
          var value = (point.value as NumericHealthValue).numericValue;
          if (value > 0) distance += value;
        }
      }
      var burnCalData = dataByType[HealthDataType.TOTAL_CALORIES_BURNED] ?? [];
      for (var point in burnCalData) {
        if (point.value is NumericHealthValue) {
          var value = (point.value as NumericHealthValue).numericValue;
          if (value > 0) burnCal += value;
        }
      }
      setState(() {
        totalStepsToday = steps;
        totalDistance = distance;
        totalBurnCal = burnCal; // Cập nhật calo
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Health data error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoadingHealth = false);
    }
  }

  Future<void> _loadLatestActivity() async {
    setState(() => isLoadingActivities = true);
    try {
      String? token = await getToken();
      final response = await http.get(
        Uri.parse('http://192.168.133.103:8055/api/activity/latest?limit=15'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final list = (json['data'] is List) ? List.from(json['data']) : [];
        if (mounted) setState(() => latestArr = list);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoadingActivities = false);
    }
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
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.blackColor),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
              (route) => false,
            );
          },
        ),
        title: const Text('Activity Tracker',
            style: TextStyle(color: AppColors.blackColor)),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              await _loadHealthDataEnhanced();
              await _loadLatestActivity();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(

                children: [
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoCard(Icons.directions_walk, 'Steps',
                          totalStepsToday.toString(), Colors.pink[100],
                          textColor: Colors.pink),
                      _buildInfoCard(Icons.directions_walk, 'Distance (m)',
                          (totalDistance).toStringAsFixed(0), Colors.white),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoCard(null, 'Total Burn Cal', // Đổi tên
                          totalBurnCal.toStringAsFixed(0), Colors.grey[300]), // Đổi tên biến
                    ],
                  ),
                  const SizedBox(height: 10),
                   Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 10),
                    // margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor2.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Daily Workout Schedule',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700)),
                        SizedBox(
                          width: 80,
                          height: 30,
                          child: RoundButton(
                            type: RoundButtonType.primaryBG,
                            title: 'Check',
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const MealPlannerScreen()),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Latest Activity',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  if (isLoadingActivities || isLoadingHealth)
                    const Center(child: CircularProgressIndicator())
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: latestArr.length,
                      itemBuilder: (_, i) =>
                          LatestActivityRow(wObj: latestArr[i]),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Flexible _buildInfoCard(IconData? icon, String title, String value, Color? bg,
      {Color textColor = Colors.black}) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StatisticsScreen(
                title: title,
                type: _getStatisticsType(title),
              ),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
          ),
          child: Column(
            children: [
              if (icon != null) Icon(icon, color: textColor),
              Text(title, style: TextStyle(color: textColor)),
              Text(value,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor)),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatisticsType(String title) {
    switch (title.toLowerCase()) {
      case 'steps':
        return 'steps';
      case 'distance (m)':
        return 'distance';
      case 'total burn cal': // Đổi tên
        return 'total_burn_cal'; // Đổi tên
      default:
        return '';
    }
  }
}
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/presentation/dashboard/dashboard_screen.dart';
import 'package:health/health.dart';
// import 'package:flutter_health_connect/flutter_health_connect.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import '../../core/utils/app_colors.dart';
import '../../services/user_service.dart';
import '../../widgets/latest_activity_row.dart';
import '../../widgets/round_button.dart';
import '../meal_planner/meal_planner_screen.dart';

class ActivityTrackerScreen extends StatefulWidget {
  const ActivityTrackerScreen({Key? key}) : super(key: key);

  @override
  State<ActivityTrackerScreen> createState() => _ActivityTrackerScreenState();
}

class _ActivityTrackerScreenState extends State<ActivityTrackerScreen> {
  int totalStepsToday = 0;
  double totalDistance = 0;
  double totalCalories = 0;
  double totalSleepDeep = 0;
  double totalHeartRate = 0;

  List latestArr = [];

  bool isLoadingHealth = false;
  bool isLoadingActivities = false;

  final Health _health = Health();
  final List<HealthDataType> _dataTypes = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.HEART_RATE,
  ];

  Future<void> _requestPermissions() async {
    await Permission.activityRecognition.request();
    await Permission.sensors.request();
    await Permission.location.request();
    bool requested = await _health.requestAuthorization(_dataTypes);
    if (!requested && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Health permissions denied')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _requestPermissions();
      await _loadHealthData();
      await _loadLatestActivity();
    });
  }

  Future<void> _loadHealthData() async {
    setState(() => isLoadingHealth = true);
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(hours: 24));

    try {
      final healthData = await _health.getHealthDataFromTypes(
        types: _dataTypes,
        startTime: yesterday,
        endTime: now,
      );

      int steps = 0;
      double distance = 0.0;
      double activeEnergyBurned = 0.0;
      double sleepDeep = 0.0;
      double heartRate = 0.0;

      for (var point in healthData) {
        print(
            'point data: ${point.type}: ${(point.value as NumericHealthValue).numericValue} ${point.unit}');
        if (point.value is NumericHealthValue) {
          final value = (point.value as NumericHealthValue).numericValue;
          switch (point.type) {
            case HealthDataType.STEPS:
              steps += value.toInt();
              break;
            case HealthDataType.DISTANCE_DELTA:
              distance += value;
              break;
            case HealthDataType.ACTIVE_ENERGY_BURNED:
              activeEnergyBurned += value;
              break;
            case HealthDataType.SLEEP_DEEP:
              sleepDeep += value;
              break;
            case HealthDataType.HEART_RATE:
              heartRate += value;
              break;
            default:
              break;
          }
        }
      }

      setState(() {
        print("Fetched ${healthData}");
        for (var point in healthData) {
          print('${point.type} = ${point.value}');
        }
        totalStepsToday = steps;
        totalDistance = distance;
        totalCalories = activeEnergyBurned;
        totalSleepDeep = sleepDeep;
        totalHeartRate = heartRate;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading health data: $e')),
        );
      }
      print('Error loading health data: $e');
    } finally {
      if (mounted) setState(() => isLoadingHealth = false);
    }
  }

  Future<void> _loadLatestActivity() async {
    setState(() => isLoadingActivities = true);
    try {
      String? token = await getToken();
      final response = await http.get(
        Uri.parse('http://192.168.64.186:8055/api/activity/latest?limit=15'),
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
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
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
              await _loadHealthData();
              await _loadLatestActivity();
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoCard(Icons.favorite, 'Heart Pts',
                          totalHeartRate.toString(), Colors.grey.shade500),
                      _buildInfoCard(Icons.directions_walk, 'Steps',
                          totalStepsToday.toString(), Colors.pink[100],
                          textColor: Colors.pink),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoCard(null, 'Calories', totalCalories.toString(),
                          Colors.white),
                      _buildInfoCard(null, 'Distance (m)',
                          totalDistance.toStringAsFixed(0), Colors.white),
                      _buildInfoCard(null, 'Sleep Deep',
                          totalSleepDeep.toString(), Colors.white),
                    ],
                  ),
                  // ... rest unchanged
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 10),
                    margin: const EdgeInsets.all(10),
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
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
          if (isLoadingHealth)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Flexible _buildInfoCard(IconData? icon, String title, String value, Color? bg,
      {Color textColor = Colors.black}) {
    return Expanded(
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
    );
  }
}

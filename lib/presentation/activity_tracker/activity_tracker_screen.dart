import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/presentation/dashboard/dashboard_screen.dart';
import 'package:health/health.dart';
// import 'package:flutter_health_connect/flutter_health_connect.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;

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
    HealthDataType.TOTAL_CALORIES_BURNED,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.HEART_RATE,
    HealthDataType.RESTING_HEART_RATE,
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
      print('Error requesting permissions: $e');
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
      final startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
      final startOfDayUtc = startOfDay.toUtc();
      final nowUtc = now.toUtc();

      print('=== HEALTH DATA DEBUG ===');
      print('Time range: ${startOfDay.toIso8601String()} to ${now.toIso8601String()}');
      
      // 1. Kiểm tra permissions trước
      Map<HealthDataType, bool> permissions = {};
      for (var type in _dataTypes) {
        bool? hasPermission = await _health.hasPermissions([type]);
        permissions[type] = hasPermission ?? false;
        print('$type permission: $hasPermission');
      }
      
      // 2. Request permissions cho những loại chưa có
      var missingPermissions = permissions.entries
          .where((entry) => !entry.value)
          .map((entry) => entry.key)
          .toList();
      
      if (missingPermissions.isNotEmpty) {
        print('Requesting permissions for: $missingPermissions');
        bool granted = await _health.requestAuthorization(missingPermissions);
        print('Additional permissions granted: $granted');
      }
      
      // 3. Lấy data cho từng loại riêng biệt
      Map<HealthDataType, List<HealthDataPoint>> dataByType = {};
      
      for (var type in _dataTypes) {
        try {
          final data = await _health.getHealthDataFromTypes(
            types: [type],
            startTime: startOfDayUtc,
            endTime: nowUtc,
          );
          dataByType[type] = data;
          print('$type: ${data.length} records');
          
          if (data.isNotEmpty) {
            // In ra vài sample để debug
            for (int i = 0; i < math.min(3, data.length); i++) {
              var point = data[i];
              if (point.value is NumericHealthValue) {
                var value = (point.value as NumericHealthValue).numericValue;
                print('  Sample $i: $value ${point.unit} at ${point.dateFrom}');
              }
            }
          }
        } catch (e) {
          print('Error getting $type: $e');
          dataByType[type] = [];
        }
      }
      
      // 4. Xử lý dữ liệu với logic cải thiện
      int steps = 0;
      double distance = 0.0;
      double activeEnergyBurned = 0.0;
      double basalEnergyBurned = 0.0;
      double sleepMinutes = 0.0;
      List<double> heartRates = [];

      // Xử lý Steps
      var stepsData = dataByType[HealthDataType.STEPS] ?? [];
      for (var point in stepsData) {
        if (point.value is NumericHealthValue) {
          var value = (point.value as NumericHealthValue).numericValue;
          if (value > 0) steps += value.toInt();
        }
      }
      
      // Xử lý Distance - thử cả DISTANCE_DELTA và DISTANCE_WALKING_RUNNING
      var distanceData = dataByType[HealthDataType.DISTANCE_DELTA] ?? [];
      for (var point in distanceData) {
        if (point.value is NumericHealthValue) {
          var value = (point.value as NumericHealthValue).numericValue;
          if (value > 0) {
            // Convert từ different units về mét
            // if (point.unit?.toLowerCase().contains('km') == true) {
              // distance += value * 1000;
            // } else {
              distance += value;
            // }
          }
        }
      }
      
      // Xử lý Calories - thử cả ACTIVE và BASAL
      var activeCaloriesData = dataByType[HealthDataType.ACTIVE_ENERGY_BURNED] ?? [];
      for (var point in activeCaloriesData) {
        if (point.value is NumericHealthValue) {
          var value = (point.value as NumericHealthValue).numericValue;
          if (value > 0) activeEnergyBurned += value;
        }
      }
      
      // Thử BASAL energy nếu ACTIVE không có
      if (activeEnergyBurned == 0) {
        try {
          var basalData = await _health.getHealthDataFromTypes(
            types: [HealthDataType.BASAL_ENERGY_BURNED],
            startTime: startOfDayUtc,
            endTime: nowUtc,
          );
          for (var point in basalData) {
            if (point.value is NumericHealthValue) {
              var value = (point.value as NumericHealthValue).numericValue;
              if (value > 0) basalEnergyBurned += value;
            }
          }
          print('Using BASAL_ENERGY_BURNED: $basalEnergyBurned');
        } catch (e) {
          print('Could not get BASAL_ENERGY_BURNED: $e');
        }
      }
      
      // Xử lý Sleep - thử nhiều loại sleep data
      var sleepDeepData = dataByType[HealthDataType.SLEEP_ASLEEP] ?? [];
      for (var point in sleepDeepData) {
        if (point.value is NumericHealthValue) {
          var value = (point.value as NumericHealthValue).numericValue;
          if (value > 0) {
            // if (point.unit?.toLowerCase().contains('hour') == true) {
              sleepMinutes += value * 60;
            // } else {
            //   sleepMinutes += value;
            // }
          }
        }
      }
      
      // Nếu không có SLEEP_DEEP, thử tổng hợp tất cả loại sleep
      if (sleepMinutes == 0) {
        try {
          var allSleepTypes = [
            HealthDataType.SLEEP_LIGHT,
            HealthDataType.SLEEP_REM,
            HealthDataType.SLEEP_ASLEEP,
          ];
          
          for (var sleepType in allSleepTypes) {
            try {
              var sleepData = await _health.getHealthDataFromTypes(
                types: [sleepType],
                startTime: startOfDayUtc.subtract(Duration(hours: 12)), // Mở rộng thời gian
                endTime: nowUtc,
              );
              
              for (var point in sleepData) {
                if (point.value is NumericHealthValue) {
                  var value = (point.value as NumericHealthValue).numericValue;
                  if (value > 0) {
                    // if (point.unit?.toLowerCase().contains('hour') == true) {
                      sleepMinutes += value * 60;
                    // } else {
                    //   sleepMinutes += value;
                    // }
                  }
                }
              }
            } catch (e) {
              print('Error getting $sleepType: $e');
            }
          }
          print('Total sleep from all types: $sleepMinutes minutes');
        } catch (e) {
          print('Error getting combined sleep data: $e');
        }
      }
      
      // Xử lý Heart Rate - thử nhiều loại dữ liệu tim mạch
      heartRates = [];
      
      // Thử lấy HEART_RATE trước
      var heartRateData = dataByType[HealthDataType.HEART_RATE] ?? [];
      for (var point in heartRateData) {
        if (point.value is NumericHealthValue) {
          var value = (point.value as NumericHealthValue).numericValue;
          if (value > 0 && value < 200) { // Filter invalid heart rates
            heartRates.add(value.toDouble());
          }
        }
      }
      
      // Nếu không có HEART_RATE, thử RESTING_HEART_RATE
      if (heartRates.isEmpty) {
        try {
          var restingHRData = await _health.getHealthDataFromTypes(
            types: [HealthDataType.RESTING_HEART_RATE],
            startTime: startOfDayUtc,
            endTime: nowUtc,
          );
          for (var point in restingHRData) {
            if (point.value is NumericHealthValue) {
              var value = (point.value as NumericHealthValue).numericValue;
              if (value > 0 && value < 200) {
                heartRates.add(value.toDouble());
              }
            }
          }
          print('Using RESTING_HEART_RATE: ${heartRates.length} records');
        } catch (e) {
          print('Could not get RESTING_HEART_RATE: $e');
        }
      }

      // 5. Cập nhật UI với dữ liệu mới
      setState(() {
        totalStepsToday = steps;
        totalDistance = distance;
        double calories = sumCalories(dataByType[HealthDataType.ACTIVE_ENERGY_BURNED] ?? [], HealthDataType.ACTIVE_ENERGY_BURNED);
        if (calories == 0.0) {
          calories = sumCalories(dataByType[HealthDataType.TOTAL_CALORIES_BURNED] ?? [], HealthDataType.TOTAL_CALORIES_BURNED);
        }
        if (calories == 0.0) {
          calories = sumCalories(dataByType[HealthDataType.BASAL_ENERGY_BURNED] ?? [], HealthDataType.BASAL_ENERGY_BURNED);
        }
        totalCalories = calories;
        totalSleepDeep = sleepMinutes;
        totalHeartRate = heartRates.isEmpty ? 0 : heartRates.reduce((a, b) => a + b) / heartRates.length;
      });
      
      print('=== FINAL RESULTS ===');
      print('Steps: $totalStepsToday');
      print('Distance: ${totalDistance}m');
      print('Active Calories: ${sumCalories(dataByType[HealthDataType.ACTIVE_ENERGY_BURNED] ?? [], HealthDataType.ACTIVE_ENERGY_BURNED)}');
      print('Total Calories: ${sumCalories(dataByType[HealthDataType.TOTAL_CALORIES_BURNED] ?? [], HealthDataType.TOTAL_CALORIES_BURNED)}');
      print('Basal Calories: ${sumCalories(dataByType[HealthDataType.BASAL_ENERGY_BURNED] ?? [], HealthDataType.BASAL_ENERGY_BURNED)}');
      print('Sleep: ${totalSleepDeep}min');
      print('Heart Rate: $totalHeartRate avg from ${heartRates.length} readings');
    } catch (e) {
      print('Error in _loadHealthDataEnhanced: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Health data error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoadingHealth = false);
    }
  }

  Future<void> _loadHealthData() async {
    setState(() => isLoadingHealth = true);
    
    try {
      // Lấy thời gian hiện tại theo múi giờ địa phương
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);

      // Chuyển đổi sang UTC để tránh vấn đề múi giờ
      final startOfDayUtc = startOfDay.toUtc();
      final nowUtc = now.toUtc();

      print('Loading health data from ${startOfDay.toIso8601String()} to ${now.toIso8601String()}');
      print('UTC time: from ${startOfDayUtc.toIso8601String()} to ${nowUtc.toIso8601String()}');
      
      // Kiểm tra từng loại dữ liệu riêng lẻ
      for (var type in _dataTypes) {
        try {
          final data = await _health.getHealthDataFromTypes(
            types: [type],
            startTime: startOfDayUtc,
            endTime: nowUtc,
          );
          print('Data for $type: ${data.length} records');
          if (data.isNotEmpty) {
            print('Sample data for $type: ${data.first.value} ${data.first.unit}');
          }
        } catch (e) {
          print('Error getting data for $type: $e');
        }
      }

      final healthData = await _health.getHealthDataFromTypes(
        types: _dataTypes,
        startTime: startOfDayUtc,
        endTime: nowUtc,
      );

      print('Processing health data:');
      print('Total data points: ${healthData.length}');
      print('Data types available: ${healthData.map((e) => e.type).toSet()}');

      if (healthData.isEmpty) {
        print('No health data available');
        return;
      }

      int steps = 0;
      double distance = 0.0;
      double activeEnergyBurned = 0.0;
      double sleepDeepMinutes = 0.0;
      List<double> heartRates = [];

      // Phân loại dữ liệu theo loại
      final stepsData = healthData.where((point) => point.type == HealthDataType.STEPS).toList();
      final distanceData = healthData.where((point) => point.type == HealthDataType.DISTANCE_DELTA).toList();
      final caloriesData = healthData.where((point) => point.type == HealthDataType.ACTIVE_ENERGY_BURNED).toList();
      final sleepData = healthData.where((point) => point.type == HealthDataType.SLEEP_ASLEEP).toList();
      final heartRateData = healthData.where((point) => point.type == HealthDataType.HEART_RATE).toList();

      print('Found ${stepsData.length} steps records');
      print('Found ${distanceData.length} distance records');
      print('Found ${caloriesData.length} calories records');
      print('Found ${sleepData.length} sleep records');
      print('Found ${heartRateData.length} heart rate records');

      for (var point in healthData) {
        if (point.value is NumericHealthValue) {
          final value = (point.value as NumericHealthValue).numericValue;
          if (value < 0) continue;
          
          print('Processing ${point.type}: $value ${point.unit}');
          
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
            case HealthDataType.SLEEP_ASLEEP:
              if (point.unit == 'hours') {
                sleepDeepMinutes += value * 60;
              } else {
                sleepDeepMinutes += value;
              }
              break;
            case HealthDataType.HEART_RATE:
              heartRates.add(value.toDouble());
              break;
            default:
              break;
          }
        }
      }

      setState(() {
        totalStepsToday = steps;
        totalDistance = distance;
        totalCalories = sumCalories(healthData, HealthDataType.ACTIVE_ENERGY_BURNED);
        totalSleepDeep = sleepDeepMinutes;
        totalHeartRate = heartRates.isEmpty ? 0 : heartRates.reduce((a, b) => a + b) / heartRates.length;
        
        print('Updated totals:');
        print('Steps: $totalStepsToday');
        print('Distance: $totalDistance');
        print('Calories: $totalCalories');
        print('Sleep: $totalSleepDeep');
        print('Heart Rate: $totalHeartRate');
      });
    } catch (e) {
      print('Error loading health data: $e');
      if (mounted) {
        String errorMessage = 'Error loading health data: ';
        if (e is HealthException) {
          errorMessage += e.toString();
        } else {
          errorMessage += e.toString();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
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
        Uri.parse('http://192.168.1.6:8055/api/activity/latest?limit=15'),
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
              await _loadHealthDataEnhanced();
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
                      _buildInfoCard(null, 'Calories', totalCalories.toInt().toString(),
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

  double getHealthValue(List<HealthDataPoint> data, HealthDataType type) {
    final point = data.cast<HealthDataPoint?>().firstWhere(
      (e) => e != null && e.type == type,
      orElse: () => null,
    );
    if (point == null) return 0.0;
    final value = point.value;
    if (value is NumericHealthValue) {
      return value.numericValue.toDouble();
    }
    return 0.0;
  }

  double extractValue(List<HealthDataPoint> data, HealthDataType type) {
    final filtered = data.where((e) => e.type == type).toList();
    if (filtered.isEmpty) return 0.0;
    final value = filtered.first.value;
    if (value is NumericHealthValue) return value.numericValue.toDouble();
    return 0.0;
  }

  double sumCalories(List<HealthDataPoint> data, HealthDataType type) {
    return data
        .where((e) => e.type == type && e.value is NumericHealthValue)
        .map((e) => (e.value as NumericHealthValue).numericValue.toDouble())
        .fold(0.0, (a, b) => a + b);
  }
}
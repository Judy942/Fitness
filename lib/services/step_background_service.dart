import 'dart:async';

import 'package:health/health.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final health = Health();
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      // Lấy số bước từ Health API
      final steps = await health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: startOfDay,
        endTime: now,
      );

      int currentSteps = 0;
      for (var data in steps) {
        if (data.value is NumericHealthValue) {
          currentSteps += (data.value as NumericHealthValue).numericValue.toInt();
        }
      }

      return true;
    } catch (e) {
      print('Lỗi trong background service: $e');
      return false;
    }
  });
}

class StepBackgroundService {
  static final StepBackgroundService _instance = StepBackgroundService._internal();
  factory StepBackgroundService() => _instance;
  StepBackgroundService._internal();

  final Workmanager _workmanager = Workmanager();
  final Health _health = Health();
  Timer? _updateTimer;
  int _currentSteps = 0;

  Future<void> initialize() async {
    // Khởi tạo Workmanager
    await _workmanager.initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );

    // Đăng ký task định kỳ
    await _workmanager.registerPeriodicTask(
      'stepCounter',
      'updateSteps',
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );

    // Cập nhật số bước mỗi 30 giây
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      try {
        final now = DateTime.now();
        final startOfDay = DateTime(now.year, now.month, now.day);

        final steps = await _health.getHealthDataFromTypes(
          types: [HealthDataType.STEPS],
          startTime: startOfDay,
          endTime: now,
        );

        int currentSteps = 0;
        for (var data in steps) {
          if (data.value is NumericHealthValue) {
            currentSteps += (data.value as NumericHealthValue).numericValue.toInt();
          }
        }

        _currentSteps = currentSteps;
      } catch (e) {
        print('Lỗi khi cập nhật số bước: $e');
      }
    });
  }

  int get currentSteps => _currentSteps;

  void dispose() {
    _updateTimer?.cancel();
  }
} 
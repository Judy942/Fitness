import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'step_background_service.dart';

class StepNotificationService {
  static final StepNotificationService _instance = StepNotificationService._internal();
  factory StepNotificationService() => _instance;
  StepNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final Health _health = Health();
  final StepBackgroundService _backgroundService = StepBackgroundService();
  Timer? _updateTimer;
  int _lastStepCount = 0;
  int _stepGoal = 5000;

  Future<void> initialize() async {
    tz.initializeTimeZones();
    
    // Khởi tạo thông báo
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = 
        DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notifications.initialize(initSettings);

    // Tải mục tiêu số bước
    await _loadStepGoal();
    
    // Kiểm tra và yêu cầu quyền
    await _checkAndRequestPermissions();
    
    // Khởi tạo background service
    await _backgroundService.initialize();
    
    // Thiết lập thông báo định kỳ
    await _scheduleNotifications();
  }

  Future<void> _checkAndRequestPermissions() async {
    // Kiểm tra quyền thông báo
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // Kiểm tra quyền đặt báo thức chính xác
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }

    // Kiểm tra và yêu cầu quyền Health
    final types = [HealthDataType.STEPS];
    final authorized = await _health.requestAuthorization(types);
    if (!authorized) {
      print('Không có quyền truy cập dữ liệu sức khỏe');
    }
  }

  Future<void> _loadStepGoal() async {
    final prefs = await SharedPreferences.getInstance();
    _stepGoal = prefs.getInt('stepGoal') ?? 5000;
  }

  void _handleStepsUpdate(int currentSteps) {
    // Nếu số bước tăng lên và đạt mục tiêu
    if (currentSteps > _lastStepCount && currentSteps >= _stepGoal) {
      _sendGoalAchievedNotification(currentSteps);
    }
    _lastStepCount = currentSteps;
  }

  Future<void> _scheduleNotifications() async {
    await _notifications.cancelAll();

    // Thông báo 12:00
    await _scheduleNotification(
      id: 1,
      hour: 12,
      minute: 0,
      title: 'Cập nhật số bước buổi sáng',
    );

    // Thông báo 22:00
    await _scheduleNotification(
      id: 2,
      hour: 22,
      minute: 0,
      title: 'Cập nhật số bước buổi tối',
    );
  }

  Future<void> _scheduleNotification({
    required int id,
    required int hour,
    required int minute,
    required String title,
  }) async {
    try {
      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Lấy số bước từ background service
      final currentSteps = _backgroundService.currentSteps;
      final message = 'Bạn đã đi được $currentSteps bước. Mục tiêu: $_stepGoal bước. Cố gắng tiếp tục nhé!';

      // Kiểm tra quyền đặt báo thức chính xác
      final hasExactAlarmPermission = await Permission.scheduleExactAlarm.isGranted;

      if (hasExactAlarmPermission) {
        // Sử dụng zonedSchedule nếu có quyền
        await _notifications.zonedSchedule(
          id,
          title,
          message,
          tz.TZDateTime.from(scheduledDate, tz.local),
          NotificationDetails(
            android: AndroidNotificationDetails(
              'step_tracker_channel',
              'Step Tracker Notifications',
              channelDescription: 'Thông báo về số bước đi bộ',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: const DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } else {
        // Sử dụng show nếu không có quyền
        await _notifications.show(
          id,
          title,
          message,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'step_tracker_channel',
              'Step Tracker Notifications',
              channelDescription: 'Thông báo về số bước đi bộ',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: const DarwinNotificationDetails(),
          ),
        );
      }
    } catch (e) {
      // Xử lý lỗi một cách im lặng
      final currentSteps = _backgroundService.currentSteps;
      await _notifications.show(
        id,
        title,
        'Bạn đã đi được $currentSteps bước. Mục tiêu: $_stepGoal bước. Cố gắng tiếp tục nhé!',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'step_tracker_channel',
            'Step Tracker Notifications',
            channelDescription: 'Thông báo về số bước đi bộ',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
    }
  }

  Future<void> _sendGoalAchievedNotification(int steps) async {
    await _notifications.show(
      0,
      'Chúc mừng! 🎉',
      'Bạn đã đạt được mục tiêu $_stepGoal bước trong ngày!',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'step_tracker_channel',
          'Step Tracker Notifications',
          channelDescription: 'Thông báo về số bước đi bộ',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  void dispose() {
    _updateTimer?.cancel();
    _backgroundService.dispose();
  }
} 
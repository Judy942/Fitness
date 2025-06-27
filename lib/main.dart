// ignore_for_file: avoid_print

import 'dart:async';

import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/services/step_notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'presentation/onboarding_screen/start_screen.dart';
import 'services/push_notification/NotificationSyncService.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // Đây là nơi xử lý khi người dùng nhấn thông báo từ background/terminated
  debugPrint(
      'Tapped notification (background): ${notificationResponse.payload}');
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void initializeNotifications() async {
  const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings = InitializationSettings(
    android: androidInitSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);
  
  // Khởi tạo NotificationSyncService
  await NotificationSyncService.initialize();
}

void configureLocalNotification() {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      if (response.payload != null) {
        debugPrint('Notification payload: ${response.payload}');
        // Xử lý payload ở đây nếu cần
      }
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );
}

Future<void> requestPermissions() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings settings = InitializationSettings(
    android: androidSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(settings);
  
  // Lên lịch thông báo động viên
  await NotificationSyncService.scheduleMotivationalNotification();

  EmailOTP.config(
    appName: 'Fitness App',
    appEmail: 'trinhthuc130902@gmail.com',
    otpType: OTPType.numeric,
    emailTheme: EmailTheme.v1,
    expiry: 100000,
    otpLength: 5,
  );
  EmailOTP.setSMTP(
    host: 'smtp.gmail.com',
    emailPort: EmailPort.port587,
    secureType: SecureType.tls,
    username: 'trinhthuc130902@gmail.com',
    password: 'gkkt dvcr sbry mcya',
  );

  // Khởi động service thông báo
  await StepNotificationService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    configureLocalNotification();
    requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const StartScreen(),
    );
  }
}

// ignore_for_file: avoid_print

import 'dart:async';

import 'package:email_otp/email_otp.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import "package:flutter_gemini/flutter_gemini.dart";
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'chat_box/consts.dart';
import 'firebase_options.dart'; // File này được tạo tự động bởi FlutterFire CLI
import 'presentation/onboarding_screen/start_screen.dart';

// 1. Bắt sự kiện background
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

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
}

void _initFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  print('User granted: ${settings.authorizationStatus}');

  String? token = await messaging.getToken();
  print('FCM Token = $token');

  // Cấu hình local notification
  const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings = InitializationSettings(
    android: androidInitSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
    print('Foreground msg: ${msg.notification?.title}');

    RemoteNotification? notification = msg.notification;
    AndroidNotification? android = msg.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'channel_id',
            'channel_name',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false,
          ),
        ),
      );
    }
  });
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
  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions.currentPlatform, // Sử dụng file cấu hình tự động
  );
 const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings settings = InitializationSettings(
    android: androidSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(settings);

  // Đăng ký hàm xử lý tin nhắn nền
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  EmailOTP.config(
    appName: 'Fitness App',
    otpType: OTPType.numeric,
    emailTheme: EmailTheme.v1,
    expiry: 50000,
    otpLength: 6,
  );
  EmailOTP.setSMTP(
    host: 'smtp.gmail.com',
    // host: '162.248.102.236',
    emailPort: EmailPort.port587,
    secureType: SecureType.tls,
    username: 'trinhthuc130902@gmail.com',
    password: 'gkkt dvcr sbry mcya',
  );
  Gemini.init(
    apiKey: GEMINI_API_KEY,
  );
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
    _initFCM();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: 'Chat Box',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const StartScreen(),
    );
  }
}

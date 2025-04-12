
import 'package:flutter/material.dart';
import 'package:email_otp/email_otp.dart';

import "package:flutter_gemini/flutter_gemini.dart";
import 'chat_box/consts.dart';
import 'presentation/onboarding_screen/start_screen.dart';

void main() {
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
  Gemini.init(apiKey: GEMINI_API_KEY,);
  runApp(const MyApp());
}
class MyApp extends StatelessWidget{
  const MyApp({super.key});

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
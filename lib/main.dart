import "package:flutter/material.dart";
import "package:flutter_application_fitness/chat_box/consts.dart";
import "package:flutter_application_fitness/presentation/onboarding_screen/start_screen.dart";
import "package:flutter_gemini/flutter_gemini.dart";

void main() {
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
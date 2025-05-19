import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/core/utils/app_colors.dart';
import 'package:flutter_application_fitness/presentation/dashboard/dashboard_screen.dart';
import 'package:flutter_application_fitness/presentation/login/login_screen.dart';
import 'package:flutter_application_fitness/presentation/onboarding_screen/onboarding_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/user_service.dart';



Future<void> clearLocalData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // Xóa tất cả dữ liệu local
}

Future<String> getBmi() async {
  String? token = await getToken();
  print(token);
  try {
    final response = await http.get(
      Uri.parse(
          'http://192.168.133.103:8055/api/users/bmi'), // Thay đổi URL nếu cần
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final bmi = responseData['data']['bmi'];
      print(bmi);
      return bmi.toString();
    } else {
      return '0'; // Trả về giá trị mặc định nếu không lấy được dữ liệu
    }
  } catch (e) {
    return '0'; // Trả về giá trị mặc định nếu không lấy được dữ liệu
  }
}

class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  bool isLoading = false;

  Future<void> checkUser(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    String? token = await getToken();

    if (token != null) {
      // Gọi API để lấy thông tin người dùng
      final response = await http.get(
        Uri.parse('http://192.168.133.103:8055/users/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        // final responseData = json.decode(response.body);
        // Navigator.pushReplacementNamed(context, AppRoutes.dashboardScreen);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
          return const DashboardScreen();
        }));
      } else {
        // Lỗi, xóa dữ liệu local và yêu cầu đăng nhập lại
        await clearLocalData();
        // Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
          return const LoginScreen();
        }));
      }
    } else {
      // Không có token, chuyển đến Login
      // Navigator.pushReplacementNamed(context, AppRoutes.onboardingScreen);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return const OnboardingScreen();
      }));
    }
    // setState(() {
    //   isLoading = false;
    // }); // Kết thúc tải
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
        body: Container(
      width: media.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primary,
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
      ),
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator(
              semanticsLabel: "waiting",
            ) // Hiển thị loading indicator
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: "Fitness",
                          style: TextStyle(
                            color: AppColors.blackColor,
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: "X",
                          style: TextStyle(
                            color: AppColors.whiteColor,
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // const Text(
                  //   "Fitness",
                  //   style: TextStyle(
                  //     fontFamily: "Poppins",
                  //     fontSize: 36,
                  //     color: AppColors.blackColor,
                  //     fontWeight: FontWeight.w700,
                  //   ),
                  // ),
                  const Text(
                    "Everybody Can Train",
                    style: TextStyle(
                      color: Color(0xff7b6f72),
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: MaterialButton(
                      minWidth: double.maxFinite,
                      height: 50,
                      onPressed: () {
                        // Navigator.pushNamed(context, "/onboardingScreen");
                        checkUser(context);
                      },
                      color: AppColors.whiteColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      textColor: AppColors.primaryColor1,
                      child: const Text(
                        "Get Started",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                ],
              ),
      ),
    ));
  }
}

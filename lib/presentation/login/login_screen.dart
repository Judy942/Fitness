import 'dart:convert';

import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/presentation/camera/camera_screen.dart';
import 'package:flutter_application_fitness/presentation/profile/complete_profile_screen.dart';
import 'package:flutter_application_fitness/presentation/signup/signup_screen.dart';
import 'package:flutter_application_fitness/services/email_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/app_colors.dart';
import '../../widgets/round_gradient_button.dart';
import '../../widgets/round_textfield.dart';

const storage = FlutterSecureStorage();

Future<void> saveToken(String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('userToken', token);
}

Future<void> printAllStoredInfo() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // Lấy tất cả các key-value từ SharedPreferences
  final keys = prefs.getKeys();

  for (String key in keys) {
    final value = prefs.get(key);
    print('$key: $value');
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool hidePassword = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String email = "";
  String password = "";
  final EmailOTP myAuth = EmailOTP();
  bool isLoading = false;

void fetchData() async {
    setState(() {
    isLoading = true;
  });
  String url = "http://192.168.133.102:8055/auth/login";
  try {
    print(url);
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    print(response.body);

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final accessToken = responseBody["data"]?["access_token"];

      if (accessToken != null) {
        await saveToken(accessToken);
        
        // Tạo và lưu key/iv từ mật khẩu
        final keyAndIv = await generateKeyAndIvFromPassword(password);
        await storage.write(key: 'encryption_key', value: keyAndIv['key']);
        await storage.write(key: 'encryption_iv', value: keyAndIv['iv']);
        
        bool otpSent = await EmailService.sendOTPEmail(email);

        if (otpSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("OTP đã được gửi")),
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(
                email: email,
                responseBody: {"data": responseBody["data"]},
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Không thể gửi OTP")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy token truy cập')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email hoặc mật khẩu không hợp lệ')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  }finally {
    setState(() {
      isLoading = false;
    });
  }
}


  void _onLoginButtonPressed() {
    setState(() {
      email = emailController.text; // ✅ Fetch email from controller
      password = passwordController.text; // ✅ Fetch password from controller
    });

    fetchData(); // ✅ Call fetchData() after setting values
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: AppColors.whiteColor,
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    const Text(
                      "Xin chào,",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Chào Mừng Trở Lại",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 20,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: media.width * 0.05),
                    RoundTextField(
                        controller: emailController,
                        hintText: "Email",
                        icon: "assets/icons/message_icon.png",
                        textInputType: TextInputType.emailAddress),
                    SizedBox(height: media.width * 0.05),
                    RoundTextField(
                      hintText: "Mật khẩu",
                      icon: "assets/icons/lock_icon.png",
                      textInputType: TextInputType.text,
                      isObscureText: hidePassword,
                      controller: passwordController,
                      rightIcon: TextButton(
                          onPressed: () {
                            setState(() {
                              hidePassword = !hidePassword;
                            });
                          },
                          child: Container(
                              alignment: Alignment.center,
                              width: 20,
                              height: 20,
                              child: Icon(
                                hidePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.grayColor,
                                size: 20,
                              ))),
                    ),
                    
                    SizedBox(height: media.height * 0.5),
                    // Spacer(),
                    RoundGradientButton(
                      title: "Đăng Nhập",
                      onPressed: () {
                        _onLoginButtonPressed();
                      },
                    ),
                    // const SizedBox(

                    //   height: 2,
                    // ),
                    TextButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const SignupScreen();
                          }));
                        },
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                              style: TextStyle(
                                  color: AppColors.blackColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400),
                              children: [
                                TextSpan(
                                  text: "Chưa có tài khoản? ",
                                ),
                                TextSpan(
                                    text: "Đăng Ký",
                                    style: TextStyle(
                                        color: AppColors.secondaryColor1,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                              ]),
                        )),
                  ],
                )),
          ),
          
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            ]
        )
        );
  }
}

class OtpVerificationScreen extends StatelessWidget {
  final String email;
  final Map<String, dynamic> responseBody;

  OtpVerificationScreen({super.key, required this.email, required this.responseBody});

  final TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xác thực OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Nhập mã OTP đã được gửi đến $email",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: otpController,
              decoration: const InputDecoration(
                labelText: 'Mã OTP',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            // Resend OTP Button
            ElevatedButton(
              onPressed: () async {
                bool otpSent = await EmailService.sendOTPEmail(email);
                if (otpSent) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("OTP đã được gửi lại")));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Không thể gửi lại OTP")));
                }
              },
              child: const Text('Gửi lại OTP'),
            ),

            // Verify OTP Button
            ElevatedButton(
              onPressed: () async {
                print('Đang verify OTP: ${otpController.text}');
                bool isVerified = await EmailService.verifyOTP(email, otpController.text);
                print('Kết quả verify: $isVerified');
                
                if (isVerified) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Xác thực OTP thành công")),
                  );

                  final accessToken = responseBody["data"]["access_token"];
                  await saveToken(accessToken);

                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CompleteProfileScreen(
                                isBackToProfile: false,
                              )));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Mã OTP không hợp lệ hoặc đã hết hạn")),
                  );
                }
              },
              child: const Text('Xác thực OTP'),
            ),
          ],
        ),
      ),
    );
  }
}


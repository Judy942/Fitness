import 'dart:convert';

import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/presentation/profile/complete_profile_screen.dart';
import 'package:flutter_application_fitness/presentation/signup/signup_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/app_colors.dart';
import '../../widgets/round_gradient_button.dart';
import '../../widgets/round_textfield.dart';

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

void fetchData() async {
  String url = "http://192.168.95.1:8055/auth/login";
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final accessToken = responseBody["data"]?["access_token"];

      if (accessToken != null) {
        await saveToken(accessToken);

        // ✅ Send OTP directly using EmailOTP
        bool otpSent = await EmailOTP.sendOTP(email: email);

        if (otpSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("OTP has been sent")),
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
            const SnackBar(content: Text("Failed to send OTP")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Access token not found')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email or password')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Network error occurred')),
    );
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
        body: SafeArea(
            child: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  const Text(
                    "Hey there,",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Welcome Back",
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
                      // onChanged: (value) {
                      //   setState(() {
                      //     email = value;
                      //   });
                      // },
                      controller: emailController,
                      hintText: "Email",
                      icon: "assets/icons/message_icon.png",
                      textInputType: TextInputType.emailAddress),
                  SizedBox(height: media.width * 0.05),
                  RoundTextField(
                    // onChanged: (value) {
                    //   password = value;
                    //   // setPassword();
                    // },
                    hintText: "Password",
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
                  SizedBox(height: media.width * 0.03),
                  const Text("Forgot your password?",
                      style: TextStyle(
                        color: AppColors.grayColor,
                        fontSize: 10,
                      )),
                  SizedBox(height: media.width * 0.65),
                  RoundGradientButton(
                    title: "Login",
                    onPressed: () {
                      _onLoginButtonPressed();
                      // Navigator.pushNamed(context, '/completeProfileScreen');
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextButton(
                      onPressed: () {
                        // Navigator.pushNamed(context, '/signUpScreen');
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
                                text: "Don’t have an account yet? ",
                              ),
                              TextSpan(
                                  text: "Register",
                                  style: TextStyle(
                                      color: AppColors.secondaryColor1,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                            ]),
                      )),
                ],
              )),
        )));
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
      appBar: AppBar(title: const Text('OTP Verification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Enter the OTP sent to $email",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: otpController,
              decoration: const InputDecoration(
                labelText: 'OTP',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            // Resend OTP Button
            ElevatedButton(
              onPressed: () async {
                bool otpSent = await EmailOTP.sendOTP(email: email);
                if (otpSent) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("OTP has been resent")));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Failed to resend OTP")));
                }
              },
              child: const Text('Resend OTP'),
            ),

            // Verify OTP Button
            ElevatedButton(
              onPressed: () async {
                bool isVerified = EmailOTP.verifyOTP(otp: otpController.text);
                if (isVerified) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("OTP verified successfully")),
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
                    const SnackBar(content: Text("Invalid OTP")),
                  );
                }
              },
              child: const Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}

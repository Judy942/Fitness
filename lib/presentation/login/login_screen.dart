// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/app_colors.dart';
import '../../routes/app_routes.dart';
import '../../widgets/round_gradient_button.dart';
import '../../widgets/round_textfield.dart';
import '../onboarding_screen/start_screen.dart';

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
  final GoogleSignIn googleSignIn = GoogleSignIn();

  void fetchData() async {
  String url = "http://162.248.102.236:8055/auth/login";
  print("Email: $email");
  print("Password: $password");
  
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    print('Response: ${response.body}');
    print('Status Code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody["data"] != null && responseBody["data"]["access_token"] != null) {
    final accessToken = responseBody["data"]["access_token"];
    await saveToken(accessToken);
    // Lưu thông tin người dùng
        await saveUserData(responseBody["data"]);
        await printAllStoredInfo(); // In thông tin lưu trữ
    Navigator.pushReplacementNamed(context, AppRoutes.completeProfileScreen);
  } else {
    // Xử lý trường hợp không có access_token
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
    print("Error details: $e"); 
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Network error occurred')),
    );
  }
}




  // Future<bool> loginWithGoogle() async {
  //   try {
  //     GoogleSignIn googleSignIn = GoogleSignIn();
  //     GoogleSignInAccount? account = await googleSignIn.signIn();
  //     if(account == null )
  //       return false;
  //     GoogleSignInAuthentication googleSignInAuthentication = await account.authentication;
  //     AuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleSignInAuthentication.accessToken,
  //       idToken: googleSignInAuthentication.idToken,
  //     );
  //     await FirebaseAuth.instance.signInWithCredential(credential);
  //     return true;
  //   } catch (e) {
  //     print(e);
  //     return false;
  //   }
  //
  // }

  Future<UserCredential> loginWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  void _onLoginButtonPressed(
      dynamic email, BuildContext context, dynamic password) {
    fetchData();

    // Navigator.pushNamed(context, '/completeProfileScreen');
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
                      onChanged: (value) {
                        email = value;
                        // setEmail();
                      },
                      textEditingController: emailController,
                      hintText: "Email",
                      icon: "assets/icons/message_icon.png",
                      textInputType: TextInputType.emailAddress),
                  SizedBox(height: media.width * 0.05),
                  RoundTextField(
                    onChanged: (value) {
                      password = value;
                      // setPassword();
                    },
                    hintText: "Password",
                    icon: "assets/icons/lock_icon.png",
                    textInputType: TextInputType.text,
                    isObscureText: hidePassword,
                    textEditingController: passwordController,
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
                      _onLoginButtonPressed(email, context, password);
                      // Navigator.pushNamed(context, '/completeProfileScreen');
                    },
                  ),
                  SizedBox(height: media.width * 0.01),
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                        width: double.maxFinite,
                        height: 1,
                        color: AppColors.grayColor.withOpacity(0.5),
                      )),
                      const Text("  Or  ",
                          style: TextStyle(
                              color: AppColors.grayColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w400)),
                      Expanded(
                          child: Container(
                        width: double.maxFinite,
                        height: 1,
                        color: AppColors.grayColor.withOpacity(0.5),
                      )),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          loginWithGoogle();
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.primaryColor1.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Image.asset(
                            "assets/icons/google_icon.png",
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.primaryColor1.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Image.asset(
                            "assets/icons/facebook_icon.png",
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signUpScreen');
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


import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/utils/app_colors.dart';
import '../../widgets/round_gradient_button.dart';
import '../../widgets/round_textfield.dart';


class LoginScreen extends StatefulWidget{
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
  // http.get(API_USER_LIST);


void fetchData() async {
  // var url = Uri.parse('http://162.248.102.236:8055/auth/login');
  String url = "http://162.248.102.236:8055/auth/login";
  print("Email: $email");
  print("Password: $password");
  final response = await http.post(
    Uri.parse(url),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      "email": email,
      "password": password,
    }),
  );
    print(jsonDecode(response.body));
    print(response.statusCode);
    if (response.statusCode == 200) {
      Navigator.pushNamed(context, '/completeProfileScreen');
    } else if(response.statusCode == 400) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid email or password'),
        ),
      );
    }
}

  void _onLoginButtonPressed(dynamic email, BuildContext context, dynamic password) {
    // if (email.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Email is required'),
    //     ),
    //   );
    //   return;
    // }else if (password.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Password is required'),
    //     ),
    //   );
    //   return;
    // }
    //validate email
    fetchData();
    
    
    // Navigator.pushNamed(context, '/completeProfileScreen');
  }


  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        child: Column(
          children: [
              SizedBox(
                width: media.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: media.width*0.03,
                    ),
                    const Text(
                      "Hey there,",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: media.width*0.01),
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
                  ],
                ),
              ),
              SizedBox(height: media.width*0.05),
              RoundTextField(
                  onChanged: (value) {
                    email = value;
                    // setEmail();
                  },
                  textEditingController: emailController,
                  hintText: "Email",
                  icon: "assets/icons/message_icon.png",
                  textInputType: TextInputType.emailAddress
                  
                  ),
              SizedBox(height: media.width*0.05),
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
                        )
                        )),
              ),
              SizedBox(height: media.width*0.03),
              const Text("Forgot your password?",
                  style: TextStyle(
                    color: AppColors.grayColor,
                    fontSize: 10,
                  )),
              const Spacer(),
              RoundGradientButton(
                title: "Login",
                onPressed: () {
                  // Navigator.pushNamed(context, '/completeProfileScreen');
                  _onLoginButtonPressed(email, context, password);
                },
              ),
              SizedBox(height: media.width*0.01),
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

                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primaryColor1.withOpacity(0.5), width: 1, ),
                      ),
                      child: Image.asset("assets/icons/google_icon.png",width: 20,height: 20,),
                    ),
                  ),
                  const SizedBox(width: 30,),
                  GestureDetector(
                    onTap: () {

                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primaryColor1.withOpacity(0.5), width: 1, ),
                      ),
                      child: Image.asset("assets/icons/facebook_icon.png",width: 20,height: 20,),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context,'/signUpScreen' );
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
        )
      ))
    );
  }
  void setEmail() {
     email = emailController.text;
   }
  void setPassword() {
     password = passwordController.text;
  }
}


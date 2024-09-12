import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/utils/app_colors.dart';
import '../../widgets/round_gradient_button.dart';
import '../../widgets/round_textfield.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool isCheck = false;
  String email = "";
  String password = "";
  String firstName = "";
  String lastName = "";
  // TextEditingController emailController = TextEditingController();
  // TextEditingController passwordController = TextEditingController();
  // TextEditingController firstNameController = TextEditingController();
  // TextEditingController lastNameController = TextEditingController();

  void onRegisterButtonPressed() {
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email and password are required'),
        ),
      );
      return;
    } 
    if(!email.contains('@')||!email.contains('.')||email.characters.last=='.'||email.characters.last=='@'||email.characters.first=='.'||email.characters.first=='@'){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid email'),
        ),
      );
      return;
    }
    //password validation: gồm cả số , chữ hoa, chữ thường, ký tự đặc biệt
    if(password.length<6||!password.contains(RegExp(r'[0-9]'))||!password.contains(RegExp(r'[A-Z]'))||!password.contains(RegExp(r'[a-z]'))||!password.contains(RegExp(r'[!@#%^&*(),.?":{}|<>]'))){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must contain at least 6 characters, including uppercase, lowercase, number and special character'),
        ),
      );
      return;
    }

    fetchData();
  }

  void fetchData() async {
    // var url = Uri.parse('http://162.248.102.236:8055/auth/login');
    String url = "http://162.248.102.236:8055/users/register";
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
    } else if (response.statusCode == 400) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid email or password'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  "Hey there,",
                  style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Create an Account",
                  style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 20,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                RoundTextField(
                  onChanged: (value) {
                    setState(() {
                      firstName = value;
                    });
                  },
                  hintText: "First Name",
                  icon: "assets/icons/profile_icon.png",
                  textInputType: TextInputType.name,
                ),
                const SizedBox(
                  height: 15,
                ),
                RoundTextField(
                    onChanged: (p0) {
                      setState(() {
                        lastName = p0;
                      });
                    },
                    hintText: "Last Name",
                    icon: "assets/icons/profile_icon.png",
                    textInputType: TextInputType.name),
                const SizedBox(
                  height: 15,
                ),
                RoundTextField(
                    onChanged: (p0) {
                      setState(() {
                        email = p0;
                      });
                    },
                    hintText: "Email",
                    icon: "assets/icons/message_icon.png",
                    textInputType: TextInputType.emailAddress),
                const SizedBox(
                  height: 15,
                ),
                RoundTextField(
                  onChanged: (p0) {
                    setState(() {
                      password = p0;
                    });
                  },
                  hintText: "Password",
                  icon: "assets/icons/lock_icon.png",
                  textInputType: TextInputType.text,
                  isObscureText: true,
                  rightIcon: TextButton(
                      onPressed: () {},
                      child: Container(
                          alignment: Alignment.center,
                          width: 20,
                          height: 20,
                          child: Image.asset(
                            "assets/icons/hide_pwd_icon.png",
                            width: 20,
                            height: 20,
                            fit: BoxFit.contain,
                            color: AppColors.grayColor,
                          ))),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                        onPressed: () {
                          setState(() {
                            isCheck = !isCheck;
                          });
                        },
                        icon: Icon(
                          isCheck
                              ? Icons.check_box_outline_blank_outlined
                              : Icons.check_box_outlined,
                          color: AppColors.grayColor,
                        )),
                    const Expanded(
                      child: Text(
                          "By continuing you accept our Privacy Policy and\nTerm of Use",
                          style: TextStyle(
                            color: AppColors.grayColor,
                            fontSize: 10,
                          )),
                    )
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                RoundGradientButton(
                  title: "Register",
                  onPressed: () {
                    // Navigator.pushNamed(context, '/completeProfileScreen');
                    onRegisterButtonPressed();
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
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
                      Navigator.pop(context);
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
                              text: "Already have an account? ",
                            ),
                            TextSpan(
                                text: "Login",
                                style: TextStyle(
                                    color: AppColors.secondaryColor1,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800)),
                          ]),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

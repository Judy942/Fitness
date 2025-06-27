import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/presentation/login/login_screen.dart';
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

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegex.hasMatch(email);
  }

  bool isValidPassword(String password) {
    return password.length >= 8 &&
        password.contains(RegExp(r'[0-9]')) &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[!@#%^&*(),.?":{}|<>]'));
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void onRegisterButtonPressed() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (!isCheck) {
      showSnackBar('Vui lòng chấp nhận Điều khoản và Chính sách Bảo mật');
      return;
    }

    if (email.isEmpty || password.isEmpty) {
      showSnackBar('Email và mật khẩu là bắt buộc');
      return;
    }

    if (!isValidEmail(email)) {
      showSnackBar('Định dạng email không hợp lệ');
      return;
    }

    if (!isValidPassword(password)) {
      showSnackBar('Mật khẩu phải có ít nhất 8 ký tự, bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt');
      return;
    }

    await registerUser(email, password);
  }

  Future<void> registerUser(String email, String password) async {
    const String url = "http://192.168.102.186:8055/users/register";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        showSnackBar('Đăng ký thành công, vui lòng kiểm tra email để xác thực tài khoản');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        showSnackBar('Đăng ký thất bại: ${jsonDecode(response.body)['message'] ?? "Lỗi không xác định"}');
      }
    } catch (e) {
      showSnackBar('Không thể đăng ký. Vui lòng thử lại sau.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text("Tạo Tài Khoản",
                  style: TextStyle(color: AppColors.blackColor, fontSize: 20, fontFamily: "Poppins", fontWeight: FontWeight.w700)),
              const SizedBox(height: 15),

              RoundTextField(
                controller: firstNameController,
                hintText: "Tên",
                icon: "assets/icons/profile_icon.png",
                textInputType: TextInputType.name,
              ),
              const SizedBox(height: 15),

              RoundTextField(
                controller: lastNameController,
                hintText: "Họ",
                icon: "assets/icons/profile_icon.png",
                textInputType: TextInputType.name,
              ),
              const SizedBox(height: 15),

              RoundTextField(
                controller: emailController,
                hintText: "Email",
                icon: "assets/icons/message_icon.png",
                textInputType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),

              RoundTextField(
                controller: passwordController,
                hintText: "Mật khẩu",
                icon: "assets/icons/lock_icon.png",
                textInputType: TextInputType.text,
                isObscureText: true,
                rightIcon: TextButton(
                  onPressed: () {},
                  child: Image.asset("assets/icons/hide_pwd_icon.png", width: 20, height: 20, color: AppColors.grayColor),
                ),
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  IconButton(
                    onPressed: () => setState(() => isCheck = !isCheck),
                    icon: Icon(!isCheck ? Icons.check_box_outline_blank_outlined : Icons.check_box_outlined, color: AppColors.grayColor),
                  ),
                  const Expanded(
                    child: Text("Bằng việc tiếp tục, bạn chấp nhận Chính sách Bảo mật và\nĐiều khoản Sử dụng",
                        style: TextStyle(color: AppColors.grayColor, fontSize: 10)),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),

              RoundGradientButton(title: "Đăng Ký", onPressed: onRegisterButtonPressed),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(child: Divider(color: AppColors.grayColor.withOpacity(0.5))),
                  const Text("  Hoặc  ", style: TextStyle(color: AppColors.grayColor, fontSize: 12, fontWeight: FontWeight.w400)),
                  Expanded(child: Divider(color: AppColors.grayColor.withOpacity(0.5))),
                ],
              ),
              const SizedBox(height: 20),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(color: AppColors.blackColor, fontSize: 14, fontWeight: FontWeight.w400),
                    children: [
                      TextSpan(text: "Đã có tài khoản? "),
                      TextSpan(text: "Đăng Nhập", style: TextStyle(color: AppColors.secondaryColor1, fontSize: 14, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

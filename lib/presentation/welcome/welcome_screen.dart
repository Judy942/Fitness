import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/presentation/dashboard/dashboard_screen.dart';

import '../../core/utils/app_colors.dart';
import '../../widgets/round_gradient_button.dart';

class WelcomeScreen extends StatelessWidget {

  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Image.asset("assets/images/welcome_promo.png",
                  width: media.width * 0.75, fit: BoxFit.fitWidth),
              SizedBox(height: media.width * 0.05),
              const Text(
                "Chào mừng, Judy",
                style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(height: media.width * 0.01),
              const Text(
                "Bạn đã sẵn sàng, hãy cùng chúng tôi\nđạt được mục tiêu của bạn",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.grayColor,
                  fontSize: 12,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              RoundGradientButton(
                title: "Đến Trang Chủ",
                onPressed: () {
                  // Navigator.pushNamed(context, '/dashboardScreen');
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                    return const DashboardScreen();
                  }));
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

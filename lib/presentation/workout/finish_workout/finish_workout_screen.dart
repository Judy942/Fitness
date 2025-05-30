import 'package:flutter/material.dart';

import '../../../core/utils/app_colors.dart';
import '../../../widgets/round_gradient_button.dart';

class FinishWorkoutScreen extends StatelessWidget {
  const FinishWorkoutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              const SizedBox(height: 20,),
              Image.asset(
                "assets/images/complete_workout.png",
                height: media.width * 0.8,
                fit: BoxFit.fitHeight,
              ),

              const SizedBox(
                height: 20,
              ),

              const Text(
                "Chúc mừng, bạn đã hoàn thành bài tập",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.blackColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              const Text(
                "Tập luyện là vua và dinh dưỡng là hoàng hậu. Kết hợp cả hai và bạn sẽ có một vương quốc",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.grayColor,
                  fontSize: 12,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              const Text(
                "-Jack Lalanne",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.grayColor,
                  fontSize: 12,
                ),
              ),

              const Spacer(),
              RoundGradientButton(
                  title: "Quay lại lịch sử",
                  onPressed: () {
                    Navigator.pop(context);
                  }),

              const SizedBox(
                height: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

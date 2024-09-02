import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/core/utils/app_colors.dart';


class StartScreen extends StatelessWidget {
  const StartScreen({Key? key}) : super(key: key);

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
          end: Alignment.centerLeft,),
        ),
        child: Column(
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
                  Navigator.pushNamed(context, "/onboardingScreen");
                },
                color: AppColors.whiteColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
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
      )
    );
  }

 }
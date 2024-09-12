import 'package:flutter/material.dart ';

import '../../core/utils/app_colors.dart';

class HowToCalculateBmi extends StatelessWidget {
  const HowToCalculateBmi({super.key});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Container(
      width: media.width,
      height: media.height,
      decoration: BoxDecoration(
                      gradient: LinearGradient(colors: AppColors.primary),),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.close,
              color: AppColors.blackColor,
            ),
          ),
          Image.asset('assets/images/body_mass_index_control.png',
              width: media.width, fit: BoxFit.fitWidth),
          const Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15),
                  Text(
                    "Calculate Your Body Mass Index",
                    style: TextStyle(
                        decoration: TextDecoration.none,
                        color: AppColors.blackColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 15),
                  SizedBox(
                    width: 315,
                    child: Text(
                      "BMI is calculated using your weight and height (your weight divided by your height squared). Healthy BMI range: 18.5 kg/m2 - 25 kg/m2",
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        color: AppColors.grayColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}

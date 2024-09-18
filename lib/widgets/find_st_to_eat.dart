import 'package:flutter/material.dart';

import '../core/utils/app_colors.dart';
import '../presentation/workout/workour_detail_view/workour_detail_view.dart';
import 'round_button.dart';

class FindStToEat extends StatelessWidget {
  final Map wObj;

  const FindStToEat({Key? key, required this.wObj}) : super(key: key);

  void onViewMoreClick(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WorkoutDetailView(
                  dObj: wObj,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.primaryColor2.withOpacity(0.3),
          AppColors.primaryColor1.withOpacity(0.3)
        ]),
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(80),
            bottomRight: Radius.circular(20),
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Image.asset(
                wObj["image"].toString(),
                width: 80,
                height: 80,
              ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            
            children: [
              Text(
                wObj["title"].toString(),
                style: const TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                width: 4,
              ),
              Text(
                "${wObj["countFoods"].toString()}",
                style: const TextStyle(
                  color: AppColors.grayColor,
                  fontSize: 12,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              SizedBox(
                width: 80,
                height: 30,
                child: RoundButton(
                    title: "Select",
                    onPressed: () {
                      onViewMoreClick(context);
                    }),
              )
            ],
          ),
          const SizedBox(
            width: 15,
          ),
          // Stack(
          //   alignment: Alignment.center,
          //   children: [
          //     Container(
          //       width: 80,
          //       height: 80,
          //       decoration: BoxDecoration(
          //         color: AppColors.whiteColor.withOpacity(0.54),
          //         borderRadius: BorderRadius.circular(40),
          //       ),
          //     ),
          //     ClipRRect(
          //       borderRadius: BorderRadius.circular(30),
          //       child: Image.asset(
          //         wObj["image"].toString(),
          //         width: 90,
          //         height: 90,
          //         fit: BoxFit.contain,
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}

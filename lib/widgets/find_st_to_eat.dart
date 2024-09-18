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
    return Stack(
      children: [
        Container(
          // padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              AppColors.primaryColor2.withOpacity(0.3),
              AppColors.primaryColor1.withOpacity(0.3)
            ]),
            borderRadius: const BorderRadius.only(
                topRight: Radius.circular(100),
                bottomRight: Radius.circular(20),
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20)),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Image.asset(
                  wObj["image"].toString(),
                  width: 120,
                  height: 120,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20,bottom: 20),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
              
                children: [
                  Text(
                    wObj["title"].toString(),
                    style: const TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                  Text(
                    wObj["countFoods"].toString(),
                    style: const TextStyle(
                      color: AppColors.grayColor,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 120,
                    height: 30,
                    child: RoundButton(
                        type: RoundButtonType.primaryBG,
                        title: "Select",
                        onPressed: () {
                          onViewMoreClick(context);
                        }),
                  )
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

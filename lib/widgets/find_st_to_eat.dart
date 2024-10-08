import 'package:flutter/material.dart';

import '../core/utils/app_colors.dart';
import '../presentation/meal_planner/meal_planner_detail/meal_planner_detail_screen.dart';
import 'round_button.dart';

class FindStToEat extends StatelessWidget {
  final Map wObj;
  final RoundButtonType type;

  const FindStToEat(
      {Key? key, required this.wObj, this.type = RoundButtonType.primaryBG})
      : super(key: key);

  void onClickSelect(BuildContext context) {
     Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MealPlannerDetailScreen(
                  title: wObj["title"].toString(),
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          // padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color:type == RoundButtonType.secondaryBG
                  ? AppColors.secondaryColor2.withOpacity(0.2)
                  : AppColors.primaryColor1.withOpacity(0.2),
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
                // Image.asset(
                //   wObj["image"].toString(),
                //   width: MediaQuery.of(context).size.width * 0.25,
                //   height: MediaQuery.of(context).size.width * 0.25,
                // ),
                Image.network(
                                    wObj["image"].toString(),
                  width: MediaQuery.of(context).size.width * 0.25,
                  height: MediaQuery.of(context).size.width * 0.25,
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
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
                    height: 32,
                    child: RoundButton(
                        type: type,
                        title: "Select",
                        onPressed: () {
                          onClickSelect(context);
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

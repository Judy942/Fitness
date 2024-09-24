import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/presentation/meal_planner/meal_planner_detail/meal_details_screen.dart';

import '../core/utils/app_colors.dart';

class PopularContainer extends StatelessWidget {
  final Map wObj;
  const PopularContainer({Key? key, required this.wObj}) : super(key: key);

  void onViewMoreClick(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MealDetailsScreen(
                  dObj: wObj,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 10, 20),
      // margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
                color: AppColors.grayColor.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3))
          ]),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Image.asset(
                height: MediaQuery.of(context).size.width * 0.1,
                width: MediaQuery.of(context).size.width * 0.1,
                wObj["image"].toString(),
                fit: BoxFit.fill,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wObj["name"].toString(),
                  style: const TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  "${wObj["difficulty"]} | ${wObj["time"]} | ${wObj["calories"]}",
                  style: const TextStyle(
                      color: AppColors.grayColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                onViewMoreClick(context);
              },
              child: Image.asset(
                "assets/images/next_go.png",
                // height: MediaQuery.of(context).size.width * 0.1,
                // width: double.maxFinite,
                // fit: BoxFit.fitHeight,
                color: AppColors.secondaryColor1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

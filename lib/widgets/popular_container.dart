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
    print('Giá trị của wObj trong popular:$wObj');
    return Container(
      padding: const EdgeInsets.all(5),
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

              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                child: Image.network(
                  'http://192.168.1.6:8055/assets/${wObj["image"]}',
                  height: 55,
                  width: 55,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Text(
              wObj["name"].toString(),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              
              style: const TextStyle(
                  color: AppColors.blackColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                onViewMoreClick(context);
              },
              child: Image.asset(
                "assets/images/next_go.png",
                height: 25,
                width: 25,
                // fit: BoxFit.fitHeight,
                color: AppColors.secondaryColor1,
              ),

            ),
            SizedBox(width: 5,)
          ],
        ),
      ),
    );
  }
}

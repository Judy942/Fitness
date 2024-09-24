
import 'package:flutter/material.dart';

import '../core/utils/app_colors.dart';
import '../core/utils/date_and_time.dart';
import 'round_gradient_button.dart';

class ShowLog extends StatelessWidget {
  final Map eObj;
  const ShowLog({Key? key, required this.eObj}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      content: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    height: 40,
                    width: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: AppColors.lightGrayColor,
                        borderRadius: BorderRadius.circular(10)),
                    child: Image.asset(
                      "assets/icons/closed_btn.png",
                      width: 15,
                      height: 15,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const Text(
                  "Workout Schedule",
                  style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
                InkWell(
                  onTap: () {},
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    height: 40,
                    width: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: AppColors.lightGrayColor,
                        borderRadius: BorderRadius.circular(10)),
                    child: Image.asset(
                      "assets/icons/more_icon.png",
                      width: 15,
                      height: 15,
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              eObj["name"].toString(),
              style: const TextStyle(
                  color: AppColors.blackColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(
              height: 4,
            ),
            Row(children: [
              Image.asset(
                "assets/icons/time_workout.png",
                height: 20,
                width: 20,
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                "${getDayTitle(eObj["start_time"].toString())}|${getStringDateToOtherFormate(eObj["start_time"].toString(), outFormatStr: "h:mm aa")}",
                style:
                    const TextStyle(color: AppColors.grayColor, fontSize: 12),
              )
            ]),
            const SizedBox(
              height: 15,
            ),
            RoundGradientButton(
                title: "Mark Done",
                onPressed: () {
                  Navigator.pop(context);
                }),
          ],
        ),
      ),
    );
  }
}

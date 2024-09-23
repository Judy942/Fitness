import 'package:flutter/material.dart';

import '../core/utils/app_colors.dart';
import 'round_button.dart';

class RecommendationContainer extends StatelessWidget {
  final Map wObj;
  final RoundButtonType type;

  const RecommendationContainer(
      {Key? key, required this.wObj, this.type = RoundButtonType.primaryBG})
      : super(key: key);

  void onViewMoreClick(BuildContext context) {
    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => WorkoutDetailView(
    //               dObj: wObj,
    //             )));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          color: type == RoundButtonType.secondaryBG
              ? AppColors.secondaryColor2.withOpacity(0.2)
              : AppColors.primaryColor2.withOpacity(0.2),
          borderRadius: const BorderRadius.all(Radius.circular(20))),
          child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                height: MediaQuery.of(context).size.width * 0.2,
                width: MediaQuery.of(context).size.width * 0.2,
                wObj["image"].toString(),
              ),
              const SizedBox(
                height: 5,
              ),
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
                    fontWeight: FontWeight.w400),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: SizedBox(
                  height: 35,
                  width: 100,
                  child: RoundButton(
                    type: RoundButtonType.primaryBG,
                    title: "View",
                    onPressed: () {
                      onViewMoreClick(context);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}

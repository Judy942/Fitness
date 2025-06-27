import 'package:flutter/material.dart';

import '../core/utils/app_colors.dart';
import 'round_button.dart';

class CategoryContainer extends StatelessWidget {
  final Map wObj;
  final RoundButtonType type;

  const CategoryContainer(
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
      // padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: type == RoundButtonType.secondaryBG
              ? AppColors.secondaryColor2.withOpacity(0.2)
              : AppColors.primaryColor2.withOpacity(0.2),
          borderRadius: const BorderRadius.all(Radius.circular(20))),
          child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 10),
                height: MediaQuery.of(context).size.width * 0.15,
                width: MediaQuery.of(context).size.width * 0.15,
                decoration: BoxDecoration(
                    color:AppColors.whiteColor.withOpacity(0.4),
                    borderRadius: const BorderRadius.all(Radius.circular(80))),
                child: 
                Image.network(
                  wObj["image"].toString(),
                  fit: BoxFit.contain,
                ),
                // Image.asset(
                //   wObj["image"].toString(),
                //   fit: BoxFit.contain,
                // ),
              ),
              Text(
                wObj["name"].toString(),
                style: const TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
    );
  }
}

import 'package:flutter/material.dart';

import '../core/utils/app_colors.dart';
import '../presentation/workout/workour_detail_view/workour_detail_view.dart';
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
    return Stack(
      children: [
        Container(
          // padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: type == RoundButtonType.secondaryBG
                  ? AppColors.secondaryColor2.withOpacity(0.2)
                  : AppColors.primaryColor2.withOpacity(0.2),
              borderRadius: const BorderRadius.all(Radius.circular(20))),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: type == RoundButtonType.secondaryBG
                      ? AppColors.secondaryColor2.withOpacity(0.2)
                      : AppColors.primaryColor2.withOpacity(0.2),
                  borderRadius: const BorderRadius.all(Radius.circular(20))),
              child: Image.asset(
                wObj["image"].toString(),
                width: MediaQuery.of(context).size.width * 0.25,
                height: MediaQuery.of(context).size.width * 0.25,
              ),
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
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../core/utils/app_colors.dart';
import 'round_button.dart';

class ExercisesRow extends StatelessWidget {
  final Map eObj;
  final VoidCallback onPressed;
    final RoundButtonType type;
    final double ImagePadding;

  const ExercisesRow({Key? key, required this.eObj, required this.onPressed, this.type = RoundButtonType.primaryBG, this.ImagePadding = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: type == RoundButtonType.secondaryBG?AppColors.secondaryColor1.withOpacity(0.2):AppColors.primaryColor1.withOpacity(0.2),
              borderRadius: BorderRadius.circular(5),
            ),
            padding: EdgeInsets.all(ImagePadding),
            width: 60,
            height: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.asset(
                eObj["image"].toString(),
                // width: 60,
                // height: 60,
                fit: BoxFit.fill,
              ),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eObj["title"].toString(),
                    style: const TextStyle(color: AppColors.blackColor, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    eObj["value"].toString(),
                    style: const TextStyle(
                      color: AppColors.grayColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              )),
          IconButton(
              onPressed: onPressed,
              icon: Image.asset(
                "assets/icons/next_go.png",
                width: 20,
                height: 20,
                fit: BoxFit.contain,
              ))
        ],
      ),
    );
  }
}

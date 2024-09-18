import 'package:flutter/material.dart';

import '../core/utils/app_colors.dart';

class TodayMealsRow extends StatefulWidget {
  final Map wObj;
  const TodayMealsRow({Key? key, required this.wObj}) : super(key: key);

  @override
  State<TodayMealsRow> createState() => _TodayMealsRowState();
}

class _TodayMealsRowState extends State<TodayMealsRow> {

  bool positive = false;
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        padding: const EdgeInsets.all( 10),
        decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)]),
        child: Row(
          children: [
            ClipRRect(
              // borderRadius: BorderRadius.circular(30),
              
              child: Image.asset(
                widget.wObj["image"].toString(),
                width: 50,
                height: 50,
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
                      widget.wObj["title"].toString(),
                      style: const TextStyle(
                          color: AppColors.blackColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      widget.wObj["time"].toString(),
                      style: const TextStyle(
                        color: AppColors.grayColor,
                        fontSize: 10,
                      ),
                    ),
                  ],
                )),

              InkWell(
                child: ImageIcon(
                  positive ? AssetImage("assets/icons/Icon_Bell.png") : AssetImage("assets/icons/Icon_Bell_off.png"),
                  color: positive ? Colors.purple : Colors.grey,
                  size: 30,
                ),
                onTap: () {
                  setState(() {
                    positive = !positive;
                  });
                },
              )
          
          ],
        ));
  }
}

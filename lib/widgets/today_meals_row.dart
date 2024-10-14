import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/utils/app_colors.dart';

class TodayMealsRow extends StatefulWidget {
  final Map wObj;
  const TodayMealsRow({Key? key, required this.wObj}) : super(key: key);

  @override
  State<TodayMealsRow> createState() => _TodayMealsRowState();
}

class _TodayMealsRowState extends State<TodayMealsRow> {

  bool positive = true;
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
              
              child: Image.network(
                'http://162.248.102.236:8055/assets/${widget.wObj['dish_id']["image"]}',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              // Image.asset(
              //   widget.wObj['dish_id']["image"].toString(),
              //   width: 50,
              //   height: 50,
              // ),
            ),
            const SizedBox(
              width: 15,
            ),
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.wObj['dish_id']["name"].toString(),
                      style: const TextStyle(
                          color: AppColors.blackColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Today | ${DateFormat('hh:mm a').format(DateTime.parse(widget.wObj["meal_time"]).toLocal())}',
                      
                      style: const TextStyle(
                        color: AppColors.grayColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                )),

              InkWell(
                child: ImageIcon(
                  positive ? const AssetImage("assets/icons/Icon_Bell.png") : const AssetImage("assets/icons/Icon_Bell_off.png"),
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

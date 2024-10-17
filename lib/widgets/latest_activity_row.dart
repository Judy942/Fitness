import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../core/utils/app_colors.dart';

class LatestActivityRow extends StatelessWidget {
  final Map wObj;
  const LatestActivityRow({Key? key, required this.wObj}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColors.grayColor.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.network(
                wObj["type"] == "MEAL"
                    ? 'https://162.248.102.236:8055/assets/${wObj["dish_id"]["image"]}'
                    : 'https://162.248.102.236:8055/assets/${wObj["workout_id"]["image"]}',
                errorBuilder: (BuildContext context, Object error,
                    StackTrace? stackTrace) {
                  return Container(
                    color: Colors.grey, // Hoặc bất kỳ màu nào bạn muốn
                    child: const Icon(
                        Icons.error_outline), // Hiển thị biểu tượng lỗi
                  );
                },
                width: 50,
                height: 50,
                fit: BoxFit.cover,
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
                  wObj["type"] == "MEAL"
                      ? wObj["dish_id"]["name"].toString()
                      : wObj["workout_id"]["name"].toString(),
                  style: const TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  wObj["type"] == "MEAL"
                      ? timeago.format(DateTime.parse(wObj["meal_time"]))
                      : timeago.format(
                          DateTime.parse(wObj["scheduled_execution_time"])),
                  style: const TextStyle(
                    color: AppColors.grayColor,
                    fontSize: 10,
                  ),
                )
              ],
            )),
          ],
        ));
  }
}

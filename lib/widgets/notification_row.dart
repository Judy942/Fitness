import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../core/utils/app_colors.dart';

class NotificationRow extends StatelessWidget {
  final Map nObj;
  const NotificationRow({Key? key, required this.nObj}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.network(
              nObj["type"] == "MEAL"
                  ? 'https://162.248.102.236:8055/assets/${nObj["dish_id"]["image"]}'
                  : 'https://162.248.102.236:8055/assets/${nObj["workout_id"]["image"]}',
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                return Container(
                  color: Colors.grey, // Hoặc bất kỳ màu nào bạn muốn
                  child: const Icon(Icons.error_outline), // Hiển thị biểu tượng lỗi
                );
              },
              width: 40,
              height: 40,
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
                nObj["type"] == "MEAL"
                    ? nObj["dish_id"]["name"]
                    : nObj["workout_id"]["name"],
                style: const TextStyle(
                    color: AppColors.blackColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 12),
              ),
              Text(
                nObj["type"] == "MEAL"
                    ? timeago.format(DateTime.parse(nObj["meal_time"]))
                    : timeago.format(
                        DateTime.parse(nObj["scheduled_execution_time"])),
                style: const TextStyle(
                  color: AppColors.grayColor,
                  fontSize: 10,
                ),
              )
            ],
          )),
        ],
      ),
    );
  }
}

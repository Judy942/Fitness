import 'package:flutter/material.dart';

import '../core/utils/app_colors.dart';

class NotificationRow extends StatefulWidget {
  final Map nObj;
  const NotificationRow({Key? key, required this.nObj}) : super(key: key);

  @override
  State<NotificationRow> createState() => _NotificationRowState();
}

class _NotificationRowState extends State<NotificationRow> {
  List completedExercise = [];

  @override
  void initState() {
    super.initState();
    for (var item in widget.nObj["completed_exercise"]) {
      completedExercise.add(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalExercises = widget.nObj["workout_id"]["exercises"].length;
    if (completedExercise.length == totalExercises) {
      return Container(); // Không hiển thị nếu hoàn thành tất cả bài thể dục
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.network(
              widget.nObj["type"] == "MEAL"
                  ? 'http://192.168.133.101:8055/assets/${widget.nObj["dish_id"]["image"]}'
                  : 'http://192.168.133.101:8055/assets/${widget.nObj["workout_id"]["image"]}',
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                return Container(
                  color: Colors.grey, // Màu nền mặc định
                  child: const Icon(
                      Icons.error_outline), // Hiển thị biểu tượng lỗi
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
                widget.nObj["type"] == "MEAL"
                    ? widget.nObj["dish_id"]["name"]
                    : widget.nObj["workout_id"]["name"],
                style: const TextStyle(
                    color: AppColors.blackColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 12),
              ),
              Text(
                (widget.nObj["time_difference_str"]?.isNotEmpty ?? false)
                    ? widget.nObj["time_difference_str"]
                    : "-",
                style: const TextStyle(
                  color: AppColors.grayColor,
                  fontSize: 10,
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }
}

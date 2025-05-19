import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/presentation/workout/finish_workout/finish_workout.dart';
import 'package:intl/intl.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';

import '../core/utils/app_colors.dart';

class WorkoutRow extends StatefulWidget {
  final Map wObj;
  const WorkoutRow({super.key, required this.wObj});

  @override
  State<WorkoutRow> createState() => _WorkoutRowState();
}

class _WorkoutRowState extends State<WorkoutRow> {
  List completedExercise = [];

  @override
  void initState() {
    super.initState();
    for (var item in widget.wObj["completed_exercise"]) {
      completedExercise.add(item);
    }
  }

  void onButtonIconClick(BuildContext context) {
    log(completedExercise.toString());
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CompleteWorkoutScreen(
                workoutSchedule: widget.wObj,
                completedExercise: completedExercise,
                onComplete: () {
                  setState(() {
                    // Update state when onComplete is called
                  });
                })));
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    int totalExercises = widget.wObj["workout_id"]["exercises"].length;
    if (completedExercise.length == totalExercises) {
      return Container(); // Không hiển thị nếu hoàn thành tất cả bài thể dục
    }
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)]),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.network(
                'http://192.168.133.103:8055/assets/${widget.wObj["workout_id"]["image"]}',
                width: 60,
                height: 60,
                fit: BoxFit.fitHeight,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.error_outline);
                },
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
                  widget.wObj["workout_id"]["name"].toString(),
                  style: const TextStyle(
                      color: AppColors.blackColor, fontSize: 12),
                ),
                const SizedBox(
                  height: 4,
                ),
                SimpleAnimationProgressBar(
                  height: 15,
                  width: media.width * 0.5,
                  backgroundColor: Colors.grey.shade100,
                  foregroundColor: Colors.purple,
                  ratio: completedExercise.length.toDouble() /
                      totalExercises.toDouble(),
                  direction: Axis.horizontal,
                  curve: Curves.fastLinearToSlowEaseIn,
                  duration: const Duration(seconds: 3),
                  borderRadius: BorderRadius.circular(7.5),
                  gradientColor: LinearGradient(
                      colors: AppColors.primary,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  "ngày bắt đầu: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(widget.wObj["scheduled_execution_time"]))}",
                  style: const TextStyle(
                      color: AppColors.blackColor, fontSize: 12),
                ),
              ],
            )),
            IconButton(
                onPressed: () {
                  onButtonIconClick(context);
                },
                icon: Image.asset(
                  "assets/icons/next_icon.png",
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                ))
          ],
        ));
  }
}

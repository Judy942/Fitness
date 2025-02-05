import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/utils/app_colors.dart';
import '../core/utils/date_and_time.dart';

class UpcomingWorkoutRow extends StatefulWidget {
  final Map wObj;
  const UpcomingWorkoutRow({Key? key, required this.wObj}) : super(key: key);

  @override
  State<UpcomingWorkoutRow> createState() => _UpcomingWorkoutRowState();
}

class _UpcomingWorkoutRowState extends State<UpcomingWorkoutRow> {
  @override
  Widget build(BuildContext context) {
    return
    Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        padding: const EdgeInsets.all( 10),
        decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)]),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.network(
                // widget.wObj["image"].toString(),
                "http://192.168.95.1:8055/assets/${widget.wObj["workout_id"]["image"].toString()}",
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
                      widget.wObj["workout_id"]["name"].toString(),
                      style: const TextStyle(
                          color: AppColors.blackColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                    // Text(
                    //   widget.wObj["scheduled_execution_time"].toString(),
                    //   style: const TextStyle(
                    //     color: AppColors.grayColor,
                    //     fontSize: 10,
                    //   ),
                    // ),
                    Text(
                      '${getDayTitle(widget.wObj["scheduled_execution_time"].toString())}|${DateFormat(' hh:mm a').format(DateTime.parse(widget.wObj["scheduled_execution_time"]).toLocal())}',
                      style: const TextStyle(
                        color: AppColors.grayColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                )),
          ],
        ));
  }
}

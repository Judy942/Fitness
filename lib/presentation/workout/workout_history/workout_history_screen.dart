import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/presentation/workout/finish_workout/finish_workout_screen.dart';

import '../../../core/utils/app_colors.dart';
import '../../../services/user_service.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  final UserService _userService = UserService();
  List workoutHistoryArr = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWorkoutHistory();
  }

  Future<void> _fetchWorkoutHistory() async {
    List<dynamic> workouts = await _userService.fetchData(
      'http://192.168.102.186:8055/items/workout_schedule?fields=*,completed_exercise.*,workout_id.*&sort=-scheduled_execution_time'
    );

    setState(() {
      workoutHistoryArr = workouts.where((wObj) {
        return wObj["completed_exercise"]?.length == wObj["workout_id"]["exercises"]?.length;
      }).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Lịch sử bài tập",
          style: TextStyle(
            color: AppColors.blackColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Stack(
        children: [
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (workoutHistoryArr.isEmpty)
            Center(
              child: Text(
                "Chưa có lịch sử nào",
                style: const TextStyle(
                  color: AppColors.grayColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: workoutHistoryArr.length,
            itemBuilder: (context, index) {
              var wObj = workoutHistoryArr[index] as Map? ?? {};
              // List completedExercise = (wObj["completed_exercise"] ?? []).map((exercise) {
              //   return {
              //     "id": exercise["id"],
              //     "workout_schedule_id": wObj["id"],
              return GestureDetector(
                onTap: () {
                  // log(completedExercise.toString());
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FinishWorkoutScreen()
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.network(
                          'http://192.168.102.186:8055/assets/${wObj["workout_id"]["image"]}',
                          width: 60,
                          height: 60,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              wObj["workout_id"]["name"] ?? "",
                              style: const TextStyle(
                                color: AppColors.blackColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Ngày bắt đầu: ${DateTime.parse(wObj["scheduled_execution_time"]).toString().split(' ')[0]}",
                              style: const TextStyle(
                                color: AppColors.grayColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
} 
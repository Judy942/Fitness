import 'package:flutter/material.dart';

import '../../../core/utils/app_colors.dart';
import '../../../services/user_service.dart';

class CompleteWorkoutScreen extends StatefulWidget {
  final Map workoutSchedule;
  final List completedExercise;
  final VoidCallback onComplete;
  const CompleteWorkoutScreen({
    super.key,
    required this.workoutSchedule,
    required this.completedExercise,
    required this.onComplete,
  });

  @override
  State<CompleteWorkoutScreen> createState() => _FinishWorkoutScreenState();
}

class _FinishWorkoutScreenState extends State<CompleteWorkoutScreen> {
  Map<int, List<dynamic>> exercisesBySet = {};
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _fetchExerciseData();
  }

  Future<void> _fetchExerciseData() async {
    Map<String, dynamic> exercises = await _userService.fetchDataMap(
      'http://192.168.133.103:8055/api/workouts/${widget.workoutSchedule["workout_id"]["id"]}',
    );
    setState(() {
      _groupExercisesBySet(exercises['exercises']);
    });
  }

  void _groupExercisesBySet(List<dynamic> exercises) {
    for (var exercise in exercises) {
      int setNumber = exercise['set_number'];
      if (!exercisesBySet.containsKey(setNumber)) {
        exercisesBySet[setNumber] = [];
      }
      exercisesBySet[setNumber]!.add(exercise);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Exercises'),
        actions: [
          TextButton(
            onPressed: () {
              widget.onComplete();
              Navigator.pop(context);
            },
            child: const Text(
              'Hoàn thành',
              style: TextStyle(
                  color: AppColors.primaryColor1, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: exercisesBySet.length,
            itemBuilder: (context, index) {
              int setNumber = exercisesBySet.keys.elementAt(index);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ngày $setNumber',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  ...exercisesBySet[setNumber]!.map((wObj) {
                    return CompletedExerciseRow(
                      workoutSchedule: widget.workoutSchedule,
                      wObj: wObj,
                      completedExercise: widget.completedExercise,
                      onDelete: (exerciseId) {
                        _userService.deleteData(
                          'http://192.168.133.103:8055/items/workout_schedule_exercise/$exerciseId',
                        );
                      },
                    );
                  }).toList(),
                ],
              );
            }),
      ),
    );
  }
}

class CompletedExerciseRow extends StatefulWidget {
  final Map workoutSchedule;
  final Map wObj;
  final List completedExercise;
  final Function(int) onDelete; // Thêm tham số onDelete
  const CompletedExerciseRow(
      {Key? key,
      required this.workoutSchedule,
      required this.wObj,
      required this.completedExercise,
      required this.onDelete}) // Thêm tham số onDelete
      : super(key: key);

  @override
  State<CompletedExerciseRow> createState() => _CompletedExerciseRowState();
}

class _CompletedExerciseRowState extends State<CompletedExerciseRow> {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              AppColors.primaryColor2.withOpacity(0.3),
              AppColors.primaryColor1.withOpacity(0.3)
            ]),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.wObj["exercise_id"]["title"].toString(),
                      style: const TextStyle(
                          color: AppColors.blackColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Checkbox(
                      value: widget.completedExercise.any((exercise) =>
                          exercise["exercise_id"] ==
                              widget.wObj["exercise_id"]["id"] &&
                          exercise["set_completed_in"] ==
                              widget.wObj['set_number']),
                      onChanged: (value) {
                        setState(() {
                          final userService = UserService();
                          if (value == true) {
                            if (!widget.completedExercise.any((exercise) =>
                                exercise["exercise_id"] ==
                                    widget.wObj["exercise_id"]["id"] &&
                                exercise["set_completed_in"] ==
                                    widget.wObj['set_number'])) {
                              widget.completedExercise.add({
                                "exercise_id": widget.wObj["exercise_id"]["id"],
                                "set_completed_in": widget.wObj['set_number'],
                              });
                              userService.postData(
                                'http://192.168.133.103:8055/items/workout_schedule_exercise',
                                {
                                  "workout_schedule_id":
                                      widget.workoutSchedule["id"],
                                  "exercise_id": widget.wObj["exercise_id"]
                                      ["id"],
                                  "set_completed_in": widget.wObj['set_number'],
                                },
                              );
                            }
                          } else {
                            if (widget.completedExercise.any((exercise) =>
                                exercise["exercise_id"] ==
                                    widget.wObj["exercise_id"]["id"] &&
                                exercise["set_completed_in"] ==
                                    widget.wObj['set_number'])) {
                              int? completedExerciseId =
                                  widget.completedExercise.firstWhere(
                                (exercise) =>
                                    exercise["exercise_id"] ==
                                        widget.wObj["exercise_id"]["id"] &&
                                    exercise["set_completed_in"] ==
                                        widget.wObj['set_number'],
                                orElse: () => null,
                              )?["id"];
                              widget.completedExercise.removeWhere((exercise) =>
                                  exercise["exercise_id"] ==
                                      widget.wObj["exercise_id"]["id"] &&
                                  exercise["set_completed_in"] ==
                                      widget.wObj['set_number']);

                              if (completedExerciseId != null) {
                                widget.onDelete(
                                    completedExerciseId); // Gọi hàm onDelete
                              }
                            }
                          }
                        });
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor.withOpacity(0.54),
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.network(
                        'http://192.168.133.103:8055/assets/${widget.wObj["exercise_id"]["image"]}',
                        width: 90,
                        height: 90,
                        fit: BoxFit.fill),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}

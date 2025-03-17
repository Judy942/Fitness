

import 'package:flutter/material.dart';

import '../../../widgets/what_train_row.dart';
import '../workout_tracker/workout_tracker_screen.dart';

class CompleteWorkoutScreen extends StatefulWidget {


  const CompleteWorkoutScreen({super.key});

  @override
  State<CompleteWorkoutScreen> createState() => _FinishWorkoutScreenState();
}

class _FinishWorkoutScreenState extends State<CompleteWorkoutScreen> {
  List whatArr = [];

  @override
  void initState() {
    super.initState();
    getListWorkout().then((value) {
      setState(() {
        whatArr = value;
      });
    });
    // getNotification().then((value) {
    //   setState(() {
    //     latestArr = value;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finish Workout'),
      ),
      body: Center(
        child: ListView.builder(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: whatArr.length,
                        itemBuilder: (context, index) {
                          var wObj = whatArr[index] as Map? ?? {};
                          return WhatTrainRow(
                            wObj: wObj,
                          );
                        }),
      ),
    );
  }
}

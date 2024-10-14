import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/utils/app_colors.dart';
import '../../../model/workout.dart';
import '../../../push_up_detection/pose_detection_view.dart';
import '../../../widgets/exercises_set_section.dart';
import '../../../widgets/icon_title_next_row.dart';
import '../../../widgets/round_gradient_button.dart';
import '../../onboarding_screen/start_screen.dart';
import 'exercises_step_details.dart';

Future<Map<String, dynamic>> getExerciseDetail(int id) async {
  String url =
      'http://162.248.102.236:8055/items/exercise/$id?fields=*,process_steps.*,exercise_difficulties.difficulty_id.code,exercise_difficulties.value,exercise_difficulties.calories_burn,exercise_difficulties.excercise_time&deep[exercise_difficulties][_filter][difficulty_id][code][_eq]=EASY';

  String? token = await getToken();

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      print(data);
      // Kiểm tra xem dữ liệu có tồn tại không
      if (data.containsKey('data')) {
        return data['data']; // Trả về exerciseDetail
      } else {
        print('No data found');
      }
    } else {
      print("Error: ${response.statusCode}");
    }
  } catch (e) {
    print("Exception: $e");
  }
  return {}; // Return an empty map if no data is found or an error occurs
}

class WorkoutDetailView extends StatefulWidget {
  final Map dObj;
  final Workout workout;
  const WorkoutDetailView({Key? key, required this.dObj, required this.workout})
      : super(key: key);

  @override
  State<WorkoutDetailView> createState() => _WorkoutDetailViewState();
}

class _WorkoutDetailViewState extends State<WorkoutDetailView> {
  @override
  Widget build(BuildContext context) {
    // List exercisesArr = widget.workout.exercises;
    List<GroupedExercise> groupedExercises =
        widget.workout.groupExercisesBySetNumber();
    List equipmentArr = widget.workout.equipments;

    var media = MediaQuery.of(context).size;
    return Container(
      decoration:
          BoxDecoration(gradient: LinearGradient(colors: AppColors.primary)),
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
              leading: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.all(8),
                  height: 40,
                  width: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: AppColors.lightGrayColor,
                      borderRadius: BorderRadius.circular(10)),
                  child: Image.asset(
                    "assets/icons/back_icon.png",
                    width: 15,
                    height: 15,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              actions: [
                InkWell(
                  onTap: () {},
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    height: 40,
                    width: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: AppColors.lightGrayColor,
                        borderRadius: BorderRadius.circular(10)),
                    child: Image.asset(
                      "assets/icons/more_icon.png",
                      width: 15,
                      height: 15,
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              ],
            ),
            SliverAppBar(
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
              leadingWidth: 0,
              leading: Container(),
              expandedHeight: media.width * 0.5,
              flexibleSpace: Align(
                alignment: Alignment.center,
                child: Image.asset(
                  "assets/images/detail_top.png",
                  width: media.width * 0.75,
                  height: media.width * 0.8,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ];
        },
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: const BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25), topRight: Radius.circular(25))),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 50,
                        height: 4,
                        decoration: BoxDecoration(
                            color: AppColors.grayColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(3)),
                      ),
                      SizedBox(
                        height: media.width * 0.05,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.dObj["title"].toString(),
                                  style: const TextStyle(
                                      color: AppColors.blackColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  "${widget.dObj["exercises"].toString()} | ${widget.dObj["time"].toString()}",
                                  style: const TextStyle(
                                      color: AppColors.grayColor, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Image.asset(
                              "assets/icons/fav_icon.png",
                              width: 15,
                              height: 15,
                              fit: BoxFit.contain,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: media.width * 0.05,
                      ),
                      IconTitleNextRow(
                          icon: "assets/icons/time_icon.png",
                          title: "Schedule Workout",
                          time: "5/27, 09:00 AM",
                          color: AppColors.primaryColor2.withOpacity(0.3),
                          onPressed: () {
                            Navigator.pushNamed(
                                context, '/workoutScheduleView');
                          }),
                      SizedBox(
                        height: media.width * 0.02,
                      ),
                      IconTitleNextRow(
                          icon: "assets/icons/difficulity_icon.png",
                          title: "Difficulity",
                          time: "Beginner",
                          color: AppColors.secondaryColor2.withOpacity(0.3),
                          onPressed: () {}),
                      SizedBox(
                        height: media.width * 0.05,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "You'll Need",
                            style: TextStyle(
                                color: AppColors.blackColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                          Text(
                            "${equipmentArr.length} Items",
                            style: const TextStyle(
                                color: AppColors.grayColor, fontSize: 12),
                          ),
                        ],
                      ),
                      equipmentArr.isEmpty
                          ? const SizedBox()
                          : SizedBox(
                              height: media.width > 400
                                  ? media.width * 0.48
                                  : media.width * 0.55,
                              child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount: equipmentArr.length,
                                  itemBuilder: (context, index) {
                                    var yObj = equipmentArr[index].toMap();
                                    return Container(
                                        margin: const EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: media.width * 0.35,
                                              width: media.width * 0.35,
                                              decoration: BoxDecoration(
                                                  color:
                                                      AppColors.lightGrayColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15)),
                                              alignment: Alignment.center,
                                              child: Image.network(
                                                yObj["image"].toString(),
                                                width: media.width * 0.2,
                                                height: media.width * 0.2,
                                                fit: BoxFit.contain,
                                              ),
                                              // Image.asset(
                                              //   yObj["image"].toString(),
                                              //   width: media.width * 0.2,
                                              //   height: media.width * 0.2,
                                              //   fit: BoxFit.contain,
                                              // ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                yObj["name"].toString(),
                                                style: const TextStyle(
                                                    color: AppColors.blackColor,
                                                    fontSize: 16),
                                              ),
                                            )
                                          ],
                                        ));
                                  }),
                            ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Exercises",
                            style: TextStyle(
                                color: AppColors.blackColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                          Text(
                            "${groupedExercises.length} Sets",
                            style: const TextStyle(
                                color: AppColors.grayColor, fontSize: 12),
                          ),
                        ],
                      ),
                      ListView.builder(
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: groupedExercises.length,
                          itemBuilder: (context, index) {
                            var sObj = groupedExercises[index];
                            return ExercisesSetSection(
                              sObj: sObj,
                              onPressed: (obj) {
                                onExercisePressed(context, obj);
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => ExercisesStepDetails(eObj: obj,),
                                //   ),
                                // );
                              },
                            );
                          }),
                      SizedBox(
                        height: media.width * 0.1,
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      RoundGradientButton(
                          title: "Start Workout",
                          onPressed: () {
                            return Scaffold(
                              appBar: AppBar(
                                title: Text('Finess App'),
                                centerTitle: true,
                                elevation: 0,
                              ),
                              body: SafeArea(
                                child: Center(
                                  child: SingleChildScrollView(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                      child: Column(
                                        children: [
                                          ExpansionTile(
                                            title: const Text('Gyms'),
                                            children: [
                                              CustomCard('PushUpDetector',
                                                  PoseDetectorView()),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          })
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> onExercisePressed(BuildContext context, Exercise obj) async {
  var exerciseDetail = await getExerciseDetail(obj.id);
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ExercisesStepDetails(
        eObj: obj,
        exerciseDetail: exerciseDetail,
      ),
    ),
  );
}
class CustomCard extends StatelessWidget {
  final String _label;
  final Widget _viewPage;
  final bool featureCompleted;
 
  const CustomCard(this._label, this._viewPage, {this.featureCompleted = true});
 
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.only(bottom: 10),
      child: ListTile(
        tileColor: Theme.of(context).primaryColor,
        title: Text(
          _label,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onTap: () {
          if (!featureCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content:
                const Text('This feature has not been implemented yet')));
          } else {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => _viewPage));
          }
        },
      ),
    );
  }
}
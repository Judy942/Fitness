import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/model/workout.dart';
import 'package:readmore/readmore.dart';

import '../../../core/utils/app_colors.dart';
import '../../../widgets/step_detail_row.dart';

class ExercisesStepDetails extends StatefulWidget {
  final Exercise eObj;
  final Map<String, dynamic> exerciseDetail;
  const ExercisesStepDetails(
      {Key? key, required this.eObj, required this.exerciseDetail})
      : super(key: key);

  @override
  State<ExercisesStepDetails> createState() => _ExercisesStepDetailsState();
}

class _ExercisesStepDetailsState extends State<ExercisesStepDetails> {
  @override
  Widget build(BuildContext context) {
    int difficulty;
    try {
      difficulty =
          int.parse(widget.exerciseDetail["exercise_difficulties"][0]["value"]);
    } catch (e) {
      print("Lỗi khi phân tích: $e");
      difficulty = 0; // Hoặc một giá trị mặc định nào đó
    }
// int difficulty = int.parse(widget.exerciseDetail["exercise_difficulties"]["value"]);
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
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
              "assets/icons/closed_btn.png",
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
      backgroundColor: AppColors.whiteColor,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: media.width,
                    height: media.width * 0.43,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: AppColors.primary),
                        borderRadius: BorderRadius.circular(20)),
                    child: Image.network(
                      widget.eObj.image,
                      width: media.width,
                      height: media.width * 0.43,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Container(
                    width: media.width,
                    height: media.width * 0.43,
                    decoration: BoxDecoration(
                        color: AppColors.blackColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  // IconButton(
                  //   onPressed: () {},
                  //   icon: Image.asset(
                  //     "assets/icons/play_icon.png",
                  //     width: 30,
                  //     height: 30,
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                // widget.eObj["title"].toString(),
                widget.eObj.title,
                style: const TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                // "Easy | 390 Calories Burn",
                "${widget.eObj.difficulty} | ${widget.eObj.caloriesBurned} Calories Burn",
                style: const TextStyle(
                  color: AppColors.grayColor,
                  fontSize: 12,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(
                "Descriptions",
                style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(
                height: 4,
              ),
              ReadMoreText(
                // 'A jumping jack, also known as a star jump and called a side-straddle hop in the US military, is a physical jumping exercise performed by jumping to a position with the legs spread wide A jumping jack, also known as a star jump and called a side-straddle hop in the US military, is a physical jumping exercise performed by jumping to a position with the legs spread wide',
                widget.exerciseDetail["description"] ??
                    "No description available",
                trimLines: 4,
                colorClickableText: AppColors.blackColor,
                trimMode: TrimMode.Line,
                trimCollapsedText: ' Read More ...',
                trimExpandedText: ' Read Less',
                style: const TextStyle(
                  color: AppColors.grayColor,
                  fontSize: 14,
                ),
                moreStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryColor1),
                lessStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryColor1),
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "How To Do It",
                    style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      // "${exerciseDetail.length} Steps",
                      // "${exerciseDetail["process_steps"].length} Steps",
                      "${(widget.exerciseDetail["process_steps"] as List?)?.length ?? 0} Steps",

                      style: const TextStyle(
                          color: AppColors.grayColor, fontSize: 12),
                    ),
                  )
                ],
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.exerciseDetail["process_steps"].length,
                itemBuilder: ((context, index) {
                  // var sObj = exerciseDetail["process_steps"][index] as Map? ?? {};

                  // return StepDetailRow(
                  //   sObj: sObj,
                  //   isLast: exerciseDetail["process_steps"].last == sObj,
                  // );
                  if (widget.exerciseDetail["process_steps"].isNotEmpty) {
                    // An toàn để truy cập các phần tử
                    return StepDetailRow(
                      sObj: widget.exerciseDetail["process_steps"][index],
                      isLast: index ==
                          widget.exerciseDetail["process_steps"].length - 1,
                    );
                  } else {
                    // Xử lý trường hợp danh sách rỗng
                    return const Text("No steps available");
                  }
                }),
              ),
              const Text(
                "Custom Repetitions",
                style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(
                height: 150,
                child: CupertinoPicker.builder(
                  itemExtent: 42,
                  selectionOverlay: Container(
                    width: double.maxFinite,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                            color: AppColors.grayColor.withOpacity(0.2),
                            width: 1),
                        bottom: BorderSide(
                            color: AppColors.grayColor.withOpacity(0.2),
                            width: 1),
                      ),
                    ),
                  ),
                  onSelectedItemChanged: (index) {
                    difficulty = index;
                  },
                  childCount: 100,
                  itemBuilder: (context, index) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/icons/burn_icon.png",
                          width: 15,
                          height: 15,
                          fit: BoxFit.contain,
                        ),
                        Text(
                          " ${(index + 1) * 15} Calories Burn",
                          style: const TextStyle(
                              color: AppColors.grayColor, fontSize: 10),
                        ),
                        Text(
                          " ${index + 1} ",
                          style: const TextStyle(
                              color: AppColors.grayColor,
                              fontSize: 24,
                              fontWeight: FontWeight.w500),
                        ),
                        const Text(
                          " times",
                          style: TextStyle(
                              color: AppColors.grayColor, fontSize: 16),
                        )
                      ],
                    );
                  },
                ),
              ),
              // RoundGradientButton(
              //     title: "Save",
              //     onPressed: () async {
              //         widget.exerciseDetail["exercise_difficulties"][0]
              //             ["value"] = difficulty.toString();

              //       //cập nhật dữ liệu trên server
              //       await updateExerciseDetail(
              //           widget.eObj.id, widget.exerciseDetail);
              //       print(widget.exerciseDetail);
              //       Navigator.pop(context);
              //     }),
              const SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

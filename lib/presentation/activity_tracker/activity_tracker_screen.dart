import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/utils/app_colors.dart';
import '../../widgets/latest_activity_row.dart';
import '../../widgets/today_target_cell.dart';


class ActivityTrackerScreen extends StatefulWidget {
  const ActivityTrackerScreen({Key? key}) : super(key: key);

  @override
  State<ActivityTrackerScreen> createState() => _ActivityTrackerScreenState();
}

class _ActivityTrackerScreenState extends State<ActivityTrackerScreen> {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '?', _steps = '0';
  int touchedIndex = -1;

  List latestArr = [
    {
      "image": "assets/images/pic_4.png",
      "title": "Drinking 300ml Water",
      "time": "About 1 minutes ago"
    },
    {
      "image": "assets/images/pic_5.png",
      "title": "Eat Snack (Fitbar)",
      "time": "About 3 hours ago"
    },
  ];

    @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void onStepCount(StepCount event) {
    print(event);
    setState(() {
      _steps = event.steps.toString();
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    print(event);
    setState(() {
      _status = event.status;
    });
  }

  void onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    print(_status);
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      _steps = 'Not available';
    });
  }

  Future<bool> _checkActivityRecognitionPermission() async {
    bool granted = await Permission.activityRecognition.isGranted;

    if (!granted) {
      granted = await Permission.activityRecognition.request() ==
          PermissionStatus.granted;
    }

    return granted;
  }

  Future<void> initPlatformState() async {
    bool granted = await _checkActivityRecognitionPermission();
    if (!granted) {
      // tell user, the app will not work
      
    }

    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    (_pedestrianStatusStream.listen(onPedestrianStatusChanged))
        .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    if (!mounted) return;
  }


  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
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
              "assets/icons/back_icon.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: const Text(
          "Activity Tracker",
          style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 16,
              fontWeight: FontWeight.w700),
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
                width: 12,
                height: 12,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
          child: Column(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    AppColors.primaryColor2.withOpacity(0.3),
                    AppColors.primaryColor1.withOpacity(0.3)
                  ]),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Today Target",
                          style: TextStyle(
                              color: AppColors.blackColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: AppColors.primary,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: MaterialButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/mealPlannerScreen');
                                },
                                padding: EdgeInsets.zero,
                                height: 30,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)),
                                textColor: AppColors.primaryColor1,
                                minWidth: double.maxFinite,
                                elevation: 0,
                                color: Colors.transparent,
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 15,
                                )),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        const Expanded(
                          child: TodayTargetCell(
                            icon: "assets/icons/water_icon.png",
                            value: "8L",
                            title: "Water Intake",
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: TodayTargetCell(
                            icon: "assets/icons/foot_icon.png",
                            value: _steps,
                            title: "Foot Steps",
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(
                height: media.width * 0.05,
              ),
            
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Latest Workout",
                    style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "See More",
                      style: TextStyle(
                          color: AppColors.grayColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                  )
                ],
              ),
              ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: latestArr.length,
                  itemBuilder: (context, index) {
                    var wObj = latestArr[index] as Map? ?? {};
                    return LatestActivityRow(wObj: wObj);
                  }),
              SizedBox(
                height: media.width * 0.1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget getTitles(double value, TitleMeta meta) {
  //   var style = const TextStyle(
  //     color: AppColors.grayColor,
  //     fontWeight: FontWeight.w500,
  //     fontSize: 12,
  //   );
  //   Widget text;
  //   switch (value.toInt()) {
  //     case 0:
  //       text =  Text('Sun', style: style);
  //       break;
  //     case 1:
  //       text =  Text('Mon', style: style);
  //       break;
  //     case 2:
  //       text =  Text('Tue', style: style);
  //       break;
  //     case 3:
  //       text =  Text('Wed', style: style);
  //       break;
  //     case 4:
  //       text =  Text('Thu', style: style);
  //       break;
  //     case 5:
  //       text =  Text('Fri', style: style);
  //       break;
  //     case 6:
  //       text =  Text('Sat', style: style);
  //       break;
  //     default:
  //       text =  Text('', style: style);
  //       break;
  //   }
  //   return SideTitleWidget(
  //     axisSide: meta.axisSide,
  //     space: 16,
  //     child: text,
  //   );
  // }

  // List<BarChartGroupData> showingGroups() => List.generate(7, (i) {
  //   switch (i) {
  //     case 0:
  //       return makeGroupData(0, 5, AppColors.primary , isTouched: i == touchedIndex);
  //     case 1:
  //       return makeGroupData(1, 10.5, AppColors.secondary, isTouched: i == touchedIndex);
  //     case 2:
  //       return makeGroupData(2, 5, AppColors.primary , isTouched: i == touchedIndex);
  //     case 3:
  //       return makeGroupData(3, 7.5, AppColors.secondary, isTouched: i == touchedIndex);
  //     case 4:
  //       return makeGroupData(4, 15, AppColors.primary , isTouched: i == touchedIndex);
  //     case 5:
  //       return makeGroupData(5, 5.5, AppColors.secondary, isTouched: i == touchedIndex);
  //     case 6:
  //       return makeGroupData(6, 8.5, AppColors.primary , isTouched: i == touchedIndex);
  //     default:
  //       return throw Error();
  //   }
  // });

  // BarChartGroupData makeGroupData(
  //     int x,
  //     double y,
  //     List<Color> barColor,
  //     {
  //       bool isTouched = false,

  //       double width = 22,
  //       List<int> showTooltips = const [],
  //     }) {

  //   return BarChartGroupData(
  //     x: x,
  //     barRods: [
  //       BarChartRodData(
  //         toY: isTouched ? y + 1 : y,
  //         gradient: LinearGradient(colors: barColor, begin: Alignment.topCenter, end: Alignment.bottomCenter ),
  //         width: width,
  //         borderSide: isTouched
  //             ? const BorderSide(color: Colors.green)
  //             : const BorderSide(color: Colors.white, width: 0),
  //         backDrawRodData: BackgroundBarChartRodData(
  //           show: true,
  //           toY: 20,
  //           color: AppColors.lightGrayColor,
  //         ),
  //       ),
  //     ],
  //     showingTooltipIndicators: showTooltips,
  //   );
  // }
}


import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

import '../../core/utils/app_colors.dart';
import '../../widgets/round_button.dart';
import '../../widgets/workout_row.dart';
import 'how_to_calculate_bmi.dart';

Future<String?> getBmi() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('bmi'); // Lấy giá trị BMI từ SharedPreferences
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TopBar(),
                SizedBox(height: media.width * 0.05),
                const ContainerBmi(),
                SizedBox(height: media.width * 0.05),
                const TodayTargetSection(),
                SizedBox(height: media.width * 0.05),
                const Text("Activity Status", style: sectionTitleStyle),
                SizedBox(height: media.width * 0.05),
                ActivityStatus(),
                SizedBox(height: media.width * 0.1),
                const WorkoutProgressSection(),
                SizedBox(height: media.width * 0.05),
                LatestWorkoutSection(),
                SizedBox(height: media.width * 0.1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome Back,",
              style: TextStyle(
                color: AppColors.midGrayColor,
                fontSize: 12,
              ),
            ),
            Text(
              "Judy",
              style: TextStyle(
                color: AppColors.blackColor,
                fontSize: 20,
                fontFamily: "Poppins",
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/notificationScreen');
          },
          icon: Image.asset(
            "assets/icons/notification_icon.png",
            width: 25,
            height: 25,
            fit: BoxFit.fitHeight,
          ),
        ),
      ],
    );
  }
}

class ContainerBmi extends StatelessWidget {
  const ContainerBmi({super.key});

  // Future<String?> getBmi() async {
  //   const String url =
  //       'http://162.248.102.236:8055/api/users/bmi'; // Địa chỉ API của bạn
  //   String? token = await getToken();

  //   if (token != null) {
  //     try {
  //       final response = await http.get(
  //         Uri.parse(url),
  //         headers: {
  //           'Authorization': 'Bearer $token', // Thêm access token vào tiêu đề
  //         },
  //       );

  //       if (response.statusCode == 200) {
  //         // Giả định rằng API trả về một JSON với trường 'bmi'
  //         final Map<String, dynamic> data = json.decode(response.body);
  //         print(data);
  //         return data['bmi'] != null ? data['bmi'].toString() : '0.0';
  //       } else {
  //         // Xử lý lỗi tại đây
  //         print('Failed to load BMI: ${response.statusCode}');
  //         return null;
  //       }
  //     } catch (e) {
  //       // Xử lý ngoại lệ
  //       print('Error occurred: $e');

  //       return null;
  //     }
  //   }
  //   return null;
  // }


  @override
  Widget build(BuildContext context) {
    List<PieChartSectionData> showingSections(String bmi) {
      return List.generate(
        2,
        (i) {
          const color0 = AppColors.secondaryColor2;
          const color1 = AppColors.whiteColor;

          switch (i) {
            case 0:
              return PieChartSectionData(
                  color: color0,
                  value: 33,
                  title: '',
                  radius: 55,
                  titlePositionPercentageOffset: 0.55,
                  badgeWidget: Text(
                    bmi,
                    style: const TextStyle(
                        color: AppColors.whiteColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12),
                  ));
            case 1:
              return PieChartSectionData(
                color: color1,
                value: 75,
                title: '',
                radius: 42,
                titlePositionPercentageOffset: 0.55,
              );
            default:
              throw Error();
          }
        },
      );
    }

    return Container(
      height: MediaQuery.of(context).size.width * 0.4,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AppColors.primary),
        borderRadius:
            BorderRadius.circular(MediaQuery.of(context).size.width * 0.065),
      ),
      child: FutureBuilder<String?>(
        future: getBmi(), // Fetch the BMI value asynchronously
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator()); // Show loading while fetching
          } else {
            String? bmi = snapshot.data;
            return _buildBMIContent(bmi ?? "0", context); // Pass the valid BMI value
          }
        },
      ),
    );
  }

  Widget _buildEmptyBMI() {
    return const Center(
      child: Text(
        'BMI not available',
        style: TextStyle(color: AppColors.whiteColor),
      ),
    );
  }

  Widget _buildBMIContent(String bmi, BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          "assets/icons/bg_dots.png",
          height: MediaQuery.of(context).size.width * 0.4,
          width: double.maxFinite,
          fit: BoxFit.fitHeight,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "BMI (Body Mass Index)",
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "Enter your height and weight",
                    style: TextStyle(
                      color: AppColors.whiteColor.withOpacity(0.7),
                      fontSize: 12,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.width * 0.05),
                  Padding(
                    padding: const EdgeInsets.all(0),
                    child: SizedBox(
                      height: 35,
                      width: 100,
                      child: RoundButton(
                        title: "View More",
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return const AlertDialog(
                                title: Text("How to calculate BMI"),
                                content: HowToCalculateBmi(),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              AspectRatio(
                aspectRatio: 1,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                    ),
                    startDegreeOffset: 250,
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 1,
                    centerSpaceRadius: 0,
                    sections: showingSections(bmi), // Use the BMI value here
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> showingSections(String bmi) {
    return List.generate(
      2,
      (i) {
        const color0 = AppColors.secondaryColor2;
        const color1 = AppColors.whiteColor;

        switch (i) {
          case 0:
            return PieChartSectionData(
                color: color0,
                // color: AppColors.blackColor,
                value: double.parse(bmi),
                title: '',
                radius: 55,
                titlePositionPercentageOffset: 0.55,
                // badgeWidget: const Text("20.1", style: TextStyle(
                badgeWidget: Text(
                  bmi,
                  style: const TextStyle(
                      color: AppColors.whiteColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12),
                ));
          case 1:
            return PieChartSectionData(
              color: color1,
              value: 100 - double.parse(bmi),
              title: '',
              radius: 42,
              titlePositionPercentageOffset: 0.55,
            );
          default:
            throw Error();
        }
      },
    );
  }
}

class ActivityStatus extends StatelessWidget {
  final List<Map<String, String>> waterArr = [
    {"title": "6am - 8am", "subtitle": "600ml"},
    {"title": "9am - 11am", "subtitle": "500ml"},
    {"title": "11am - 2pm", "subtitle": "1000ml"},
    {"title": "2pm - 4pm", "subtitle": "700ml"},
    {"title": "4pm - now", "subtitle": "900ml"}
  ];

  ActivityStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildWaterIntakeSection(context)),
        SizedBox(width: MediaQuery.of(context).size.width * 0.05),
        Expanded(child: _buildHealthMetricsSection(context)),
      ],
    );
  }

  Widget _buildWaterIntakeSection(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.width * 0.95,
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Row(
        children: [
          _buildWaterProgressBar(context),
          const SizedBox(width: 10),
          Expanded(child: _buildWaterInfo(context)),
        ],
      ),
    );
  }

  Widget _buildWaterProgressBar(BuildContext context) {
    return SimpleAnimationProgressBar(
      height: MediaQuery.of(context).size.width * 0.95,
      width: MediaQuery.of(context).size.width * 0.07,
      backgroundColor: Colors.grey.shade100,
      foregrondColor: Colors.purple,
      ratio: 0.5,
      direction: Axis.vertical,
      curve: Curves.fastLinearToSlowEaseIn,
      duration: const Duration(seconds: 3),
      borderRadius: BorderRadius.circular(30),
      gradientColor: LinearGradient(
        colors: AppColors.primary,
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ),
    );
  }

  Widget _buildWaterInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Water Intake",
          style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 12,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(height: MediaQuery.of(context).size.width * 0.01),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
                    colors: AppColors.primary,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight)
                .createShader(Rect.fromLTRB(0, 0, bounds.width, bounds.height));
          },
          child: const Text(
            "4 Liters",
            style: TextStyle(
                color: AppColors.blackColor,
                fontSize: 14,
                fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.width * 0.03),
        const Text("Real time updates",
            style: TextStyle(
                color: AppColors.blackColor,
                fontSize: 10,
                fontWeight: FontWeight.w400)),
        SizedBox(height: MediaQuery.of(context).size.width * 0.01),
        _buildWaterTimeline(context),
      ],
    );
  }

  Widget _buildWaterTimeline(BuildContext context) {
    return Column(
      children: waterArr.map((obj) {
        bool isLast = obj == waterArr.last;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimelineIndicator(isLast, context),
            const SizedBox(width: 10),
            _buildTimelineEntry(obj, context),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTimelineIndicator(bool isLast, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
              color: AppColors.secondaryColor1.withOpacity(0.5),
              borderRadius: BorderRadius.circular(5)),
        ),
        if (!isLast)
          DottedDashedLine(
              width: 0,
              height: MediaQuery.of(context).size.width * 0.078,
              axis: Axis.vertical,
              dashColor: AppColors.secondaryColor1.withOpacity(0.5)),
      ],
    );
  }

  Widget _buildTimelineEntry(Map<String, String> obj, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: MediaQuery.of(context).size.width * 0.01),
        Text(obj["title"]!,
            style: const TextStyle(
                color: AppColors.blackColor,
                fontSize: 11,
                fontWeight: FontWeight.w400)),
        const SizedBox(height: 1),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
                    colors: AppColors.secondary,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight)
                .createShader(Rect.fromLTRB(0, 0, bounds.width, bounds.height));
          },
          child: Text(obj["subtitle"]!,
              style: const TextStyle(
                  color: AppColors.blackColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _buildHealthMetricsSection(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSleepContainer(context),
        SizedBox(height: MediaQuery.of(context).size.width * 0.05),
        _buildCaloriesContainer(context),
      ],
    );
  }

  Widget _buildSleepContainer(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: MediaQuery.of(context).size.width * 0.45,
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Sleep",
              style: TextStyle(
                  color: AppColors.blackColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: MediaQuery.of(context).size.width * 0.01),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) {
              return LinearGradient(
                      colors: AppColors.primary,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight)
                  .createShader(
                      Rect.fromLTRB(0, 0, bounds.width, bounds.height));
            },
            child: const Text("8h 20m",
                style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ),
          Expanded(
              child: Image.asset("assets/images/sleep_graph.png",
                  width: double.maxFinite, fit: BoxFit.fitWidth)),
        ],
      ),
    );
  }

  Widget _buildCaloriesContainer(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: MediaQuery.of(context).size.width * 0.45,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Calories",
              style: TextStyle(
                  color: AppColors.blackColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: MediaQuery.of(context).size.width * 0.01),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) {
              return LinearGradient(
                      colors: AppColors.primary,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight)
                  .createShader(
                      Rect.fromLTRB(0, 0, bounds.width, bounds.height));
            },
            child: const Text("760 kCal",
                style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ),
          Expanded(child: _buildCaloriesProgress(context)),
        ],
      ),
    );
  }

  Widget _buildCaloriesProgress(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.2,
        height: MediaQuery.of(context).size.width * 0.2,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.16,
              height: MediaQuery.of(context).size.width * 0.16,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppColors.primary),
                borderRadius: BorderRadius.circular(
                    MediaQuery.of(context).size.width * 0.075),
              ),
              child: const Text("230kCal\nleft",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w400)),
            ),
            SimpleCircularProgressBar(
              startAngle: -180,
              progressStrokeWidth: 10,
              backStrokeWidth: 10,
              progressColors: AppColors.primary,
              backColor: Colors.grey.shade100,
              valueNotifier: ValueNotifier(60),
            ),
          ],
        ),
      ),
    );
  }
}

class TodayTargetSection extends StatelessWidget {
  const TodayTargetSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: AppColors.primaryColor1.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Today Target",
            style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(
            width: 75,
            height: 30,
            child: RoundButton(
              title: "Check",
              type: RoundButtonType.primaryBG,
              onPressed: () {
                Navigator.pushNamed(context, '/activityTrackerScreen');
              },
            ),
          ),
        ],
      ),
    );
  }
}

class WorkoutProgressSection extends StatefulWidget {
  const WorkoutProgressSection({super.key});

  @override
  State<WorkoutProgressSection> createState() => _WorkoutProgressSectionState();
}

class _WorkoutProgressSectionState extends State<WorkoutProgressSection> {
  SideTitles get rightTitles => SideTitles(
        getTitlesWidget: rightTitleWidgets,
        showTitles: true,
        interval: 20,
        reservedSize: 40,
      );

  Widget rightTitleWidgets(double value, TitleMeta meta) {
    String text;
    switch (value.toInt()) {
      case 0:
        text = '0%';
        break;
      case 20:
        text = '20%';
        break;
      case 40:
        text = '40%';
        break;
      case 60:
        text = '60%';
        break;
      case 80:
        text = '80%';
        break;
      case 100:
        text = '100%';
        break;
      default:
        return Container();
    }

    return Text(text,
        style: const TextStyle(
          color: AppColors.grayColor,
          fontSize: 12,
        ),
        textAlign: TextAlign.center);
  }

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    var style = const TextStyle(
      color: AppColors.grayColor,
      fontSize: 12,
    );
    Widget text;
    switch (value.toInt()) {
      case 1:
        text = Text('Sun', style: style);
        break;
      case 2:
        text = Text('Mon', style: style);
        break;
      case 3:
        text = Text('Tue', style: style);
        break;
      case 4:
        text = Text('Wed', style: style);
        break;
      case 5:
        text = Text('Thu', style: style);
        break;
      case 6:
        text = Text('Fri', style: style);
        break;
      case 7:
        text = Text('Sat', style: style);
        break;
      default:
        text = const Text('');
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: text,
    );
  }

  List<int> showingTooltipOnSpots = [21];

  List<FlSpot> get allSpots => const [
        FlSpot(0, 20),
        FlSpot(1, 25),
        FlSpot(2, 40),
        FlSpot(3, 50),
        FlSpot(4, 35),
        FlSpot(5, 40),
        FlSpot(6, 30),
        FlSpot(7, 20),
        FlSpot(8, 25),
        FlSpot(9, 40),
        FlSpot(10, 50),
        FlSpot(11, 35),
        FlSpot(12, 50),
        FlSpot(13, 60),
        FlSpot(14, 40),
        FlSpot(15, 50),
        FlSpot(16, 20),
        FlSpot(17, 25),
        FlSpot(18, 40),
        FlSpot(19, 50),
        FlSpot(20, 35),
        FlSpot(21, 80),
        FlSpot(22, 30),
        FlSpot(23, 20),
        FlSpot(24, 25),
        FlSpot(25, 40),
        FlSpot(26, 50),
        FlSpot(27, 35),
        FlSpot(28, 50),
        FlSpot(29, 60),
        FlSpot(30, 40),
      ];

  List<LineChartBarData> get lineBarsData1 => [
        lineChartBarData1_1,
        lineChartBarData1_2,
      ];

  LineChartBarData get lineChartBarData1_1 => LineChartBarData(
        isCurved: true,
        gradient: LinearGradient(colors: [
          AppColors.primaryColor2.withOpacity(0.5),
          AppColors.primaryColor1.withOpacity(0.5),
        ]),
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: const [
          FlSpot(1, 35),
          FlSpot(2, 70),
          FlSpot(3, 40),
          FlSpot(4, 80),
          FlSpot(5, 25),
          FlSpot(6, 70),
          FlSpot(7, 35),
        ],
      );

  LineChartBarData get lineChartBarData1_2 => LineChartBarData(
        isCurved: true,
        gradient: LinearGradient(colors: [
          AppColors.secondaryColor2.withOpacity(0.5),
          AppColors.secondaryColor1.withOpacity(0.5),
        ]),
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: false,
        ),
        spots: const [
          FlSpot(1, 80),
          FlSpot(2, 50),
          FlSpot(3, 90),
          FlSpot(4, 40),
          FlSpot(5, 80),
          FlSpot(6, 35),
          FlSpot(7, 60),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final lineBarsData = [
      LineChartBarData(
        showingIndicators: showingTooltipOnSpots,
        spots: allSpots,
        isCurved: false,
        barWidth: 3,
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(colors: [
            AppColors.primaryColor2.withOpacity(0.4),
            AppColors.primaryColor1.withOpacity(0.1),
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        dotData: const FlDotData(show: false),
        gradient: LinearGradient(
          colors: AppColors.primary,
        ),
      ),
    ];

    final tooltipsOnBar = lineBarsData[0];
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Workout Progress",
              style: TextStyle(
                color: AppColors.blackColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              height: 35,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: AppColors.primary),
                  borderRadius: BorderRadius.circular(15)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton(
                  items: ["Weekly", "Monthly"]
                      .map((name) => DropdownMenuItem(
                          value: name,
                          child: Text(
                            name,
                            style: const TextStyle(
                                color: AppColors.blackColor, fontSize: 14),
                          )))
                      .toList(),
                  onChanged: (value) {},
                  icon: const Icon(Icons.expand_more,
                      color: AppColors.whiteColor),
                  hint: const Text("Weekly",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: AppColors.whiteColor, fontSize: 12)),
                ),
              ),
            )
          ],
        ),
        SizedBox(height: MediaQuery.of(context).size.width * 0.05),
        Container(
            padding: const EdgeInsets.only(left: 15),
            height: MediaQuery.of(context).size.width * 0.5,
            width: double.maxFinite,
            child: LineChart(
              LineChartData(
                showingTooltipIndicators: showingTooltipOnSpots.map((index) {
                  return ShowingTooltipIndicators([
                    LineBarSpot(
                      tooltipsOnBar,
                      lineBarsData.indexOf(tooltipsOnBar),
                      tooltipsOnBar.spots[index],
                    ),
                  ]);
                }).toList(),
                lineTouchData: LineTouchData(
                  enabled: true,
                  handleBuiltInTouches: false,
                  touchCallback:
                      (FlTouchEvent event, LineTouchResponse? response) {
                    if (response == null || response.lineBarSpots == null) {
                      return;
                    }
                    if (event is FlTapUpEvent) {
                      final spotIndex = response.lineBarSpots!.first.spotIndex;
                      showingTooltipOnSpots.clear();
                      setState(() {
                        showingTooltipOnSpots.add(spotIndex);
                      });
                    }
                  },
                  mouseCursorResolver:
                      (FlTouchEvent event, LineTouchResponse? response) {
                    if (response == null || response.lineBarSpots == null) {
                      return SystemMouseCursors.basic;
                    }
                    return SystemMouseCursors.click;
                  },
                  getTouchedSpotIndicator:
                      (LineChartBarData barData, List<int> spotIndexes) {
                    return spotIndexes.map((index) {
                      return TouchedSpotIndicatorData(
                        const FlLine(
                          color: Colors.transparent,
                        ),
                        FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) =>
                              FlDotCirclePainter(
                            radius: 3,
                            color: Colors.white,
                            strokeWidth: 3,
                            strokeColor: AppColors.secondaryColor1,
                          ),
                        ),
                      );
                    }).toList();
                  },
                  touchTooltipData: LineTouchTooltipData(
                    tooltipRoundedRadius: 20,
                    getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                      return lineBarsSpot.map((lineBarSpot) {
                        return LineTooltipItem(
                          "${lineBarSpot.x.toInt()} mins ago",
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: lineBarsData1,
                minY: -0.5,
                maxY: 110,
                titlesData: FlTitlesData(
                    show: true,
                    leftTitles: const AxisTitles(),
                    topTitles: const AxisTitles(),
                    bottomTitles: AxisTitles(
                      sideTitles: bottomTitles,
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: rightTitles,
                    )),
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  horizontalInterval: 25,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.grayColor.withOpacity(0.15),
                      strokeWidth: 2,
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Colors.transparent,
                  ),
                ),
              ),
            )),
      ],
    );
  }
}

class LatestWorkoutSection extends StatelessWidget {
  List lastWorkoutArr = [
    {
      "name": "Full Body Workout",
      "image": "assets/images/Workout1.png",
      "kcal": "180",
      "time": "20",
      "progress": 0.3
    },
    {
      "name": "Lower Body Workout",
      "image": "assets/images/Workout2.png",
      "kcal": "200",
      "time": "30",
      "progress": 0.4
    },
    {
      "name": "Ab Workout",
      "image": "assets/images/Workout3.png",
      "kcal": "300",
      "time": "40",
      "progress": 0.7
    },
  ];

  LatestWorkoutSection({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Latest Workout", style: sectionTitleStyle),
            TextButton(
              onPressed: () {},
              child: const Text(
                "See More",
                style: TextStyle(
                  color: AppColors.grayColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        ListView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: lastWorkoutArr.length,
          itemBuilder: (context, index) {
            var wObj = lastWorkoutArr[index] as Map? ?? {};
            return WorkoutRow(wObj: wObj);
          },
        ),
      ],
    );
  }
}

const TextStyle sectionTitleStyle = TextStyle(
  color: AppColors.blackColor,
  fontSize: 16,
  fontWeight: FontWeight.w600,
);

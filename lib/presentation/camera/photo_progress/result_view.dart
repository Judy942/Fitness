import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/date_and_time.dart';
import '../../../widgets/round_button.dart';
class ResultView extends StatefulWidget {
  final DateTime date1;
  final DateTime date2;
  const ResultView({super.key, required this.date1, required this.date2});

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  int selectButton = 0;

  List imaArr = [
    {
      "title": "Front Facing",
      "month_1_image": "assets/images/pp_1.png",
      "month_2_image": "assets/images/pp_2.png",
    },
    {
      "title": "Back Facing",
      "month_1_image": "assets/images/pp_3.png",
      "month_2_image": "assets/images/pp_4.png",
    },
    {
      "title": "Left Facing",
      "month_1_image": "assets/images/pp_5.png",
      "month_2_image": "assets/images/pp_6.png",
    },
    {
      "title": "Right Facing",
      "month_1_image": "assets/images/pp_7.png",
      "month_2_image": "assets/images/pp_8.png",
    },
  ];

  List statArr = [
    {
      "title": "Lose Weight",
      "diff_per": "33",
      "month_1_per": "33%",
      "month_2_per": "67%",
    },
    {
      "title": "Height Increase",
      "diff_per": "88",
      "month_1_per": "88%",
      "month_2_per": "12%",
    },
    {
      "title": "Muscle Mass Increase",
      "diff_per": "57",
      "month_1_per": "57%",
      "month_2_per": "43%",
    },
    {
      "title": "Abs",
      "diff_per": "89",
      "month_1_per": "89%",
      "month_2_per": "11%",
    },
  ];

  @override
  Widget build(BuildContext context) {
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
              "assets/icons/back_icon.png",
              width: 25,
              height: 25,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: const Text(
          "Result",
          style: TextStyle(
              color: AppColors.blackColor, fontSize: 22, fontWeight: FontWeight.w700),
        ),
      ),
      backgroundColor: AppColors.whiteColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            children: [
              Container(
                height: 55,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                    color: AppColors.lightGrayColor,
                    borderRadius: BorderRadius.circular(30)),
                child: Stack(alignment: Alignment.center, children: [
                  AnimatedContainer(
                    alignment: selectButton == 0
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      width: (media.width * 0.5) - 40,
                      height: 40,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: AppColors.primary),
                          borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectButton = 0;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30)),
                              child: Text(
                                "Photo",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: selectButton == 0
                                        ? AppColors.whiteColor
                                        : AppColors.grayColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectButton = 1;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30)),
                              child: Text(
                                "Statistic",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: selectButton == 1
                                        ? AppColors.whiteColor
                                        : AppColors.grayColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ]),
              ),

              const SizedBox(
                height: 20,
              ),

              //Photo Tab UI
              if (selectButton == 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Average Progress",
                          style: TextStyle(
                              color: AppColors.blackColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          "Good",
                          style: TextStyle(
                              color: Color(0xFF6DD570),
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SimpleAnimationProgressBar(
                          height: 20,
                          width: media.width - 40,
                          backgroundColor: Colors.grey.shade100,
                          foregrondColor: Colors.purple,
                          ratio: 0.62,
                          direction: Axis.horizontal,
                          curve: Curves.fastLinearToSlowEaseIn,
                          duration: const Duration(seconds: 3),
                          borderRadius: BorderRadius.circular(10),
                          gradientColor: LinearGradient(
                              colors: AppColors.primary,
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight),
                        ),
                        const Text(
                          "62%",
                          style: TextStyle(
                            color: AppColors.whiteColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dateToString(widget.date1, formatStr: "MMMM"),
                          style: const TextStyle(
                              color: AppColors.grayColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          dateToString(widget.date2, formatStr: "MMMM"),
                          style: const TextStyle(
                              color: AppColors.grayColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: imaArr.length,
                        itemBuilder: (context, index) {
                          var iObj = imaArr[index] as Map? ?? {};

                          return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  iObj["title"].toString(),
                                  style: const TextStyle(
                                      color: AppColors.grayColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: AspectRatio(
                                        aspectRatio: 1,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.lightGrayColor,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: Image.asset(
                                              iObj["month_1_image"].toString(),
                                              width: double.maxFinite,
                                              height: double.maxFinite,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    Expanded(
                                      child: AspectRatio(
                                        aspectRatio: 1,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.lightGrayColor,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: Image.asset(
                                              iObj["month_2_image"].toString(),
                                              width: double.maxFinite,
                                              height: double.maxFinite,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              ]);
                        }),
                    RoundButton(
                        title: "Back to Home",
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    const SizedBox(
                      height: 15,
                    ),
                  ],
                ),

              // Statistic Tab UI
              if (selectButton == 1)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      height: media.width * 0.5,
                      width: double.maxFinite,
                      child: LineChart(
                        LineChartData(
                          lineTouchData: LineTouchData(
                            enabled: true,
                            handleBuiltInTouches: false,
                            touchCallback: (FlTouchEvent event,
                                LineTouchResponse? response) {
                              if (response == null ||
                                  response.lineBarSpots == null) {
                                return;
                              }
                            },
                            mouseCursorResolver: (FlTouchEvent event,
                                LineTouchResponse? response) {
                              if (response == null ||
                                  response.lineBarSpots == null) {
                                return SystemMouseCursors.basic;
                              }
                              return SystemMouseCursors.click;
                            },
                            getTouchedSpotIndicator: (LineChartBarData barData,
                                List<int> spotIndexes) {
                              return spotIndexes.map((index) {
                                return TouchedSpotIndicatorData(
                                  const FlLine(
                                    color: Colors.transparent,
                                  ),
                                  FlDotData(
                                    show: true,
                                    getDotPainter:
                                        (spot, percent, barData, index) =>
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
                              getTooltipItems:
                                  (List<LineBarSpot> lineBarsSpot) {
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
                              return const FlLine(
                                color: AppColors.lightGrayColor,
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
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dateToString(widget.date1, formatStr: "MMMM"),
                          style: const TextStyle(
                              color: AppColors.grayColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          dateToString(widget.date2, formatStr: "MMMM"),
                          style: const TextStyle(
                              color: AppColors.grayColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: statArr.length,
                        itemBuilder: (context, index) {
                          var iObj = statArr[index] as Map? ?? {};

                          return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  iObj["title"].toString(),
                                  style: const TextStyle(
                                      color: AppColors.grayColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: 25,
                                      child: Text(
                                        iObj["month_1_per"].toString(),
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                            color: AppColors.grayColor, fontSize: 12),
                                      ),
                                    ),

                                    SimpleAnimationProgressBar(
                          height: 10,
                          width: media.width - 120,
                          backgroundColor: AppColors.primaryColor1,
                          foregrondColor: const Color(0xffFFB2B1) ,
                          ratio: (double.tryParse(iObj["diff_per"].toString()) ?? 0.0) / 100.0 ,
                          direction: Axis.horizontal,
                          curve: Curves.fastLinearToSlowEaseIn,
                          duration: const Duration(seconds: 3),
                          borderRadius: BorderRadius.circular(5),
                          
                        ),

                                    SizedBox(
                                      width: 25,
                                      child: Text(
                                        iObj["month_2_per"].toString(),
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(
                                          color: AppColors.grayColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ]);
                        }),
                 
                    RoundButton(
                        title: "Back to Home",
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    const SizedBox(
                      height: 15,
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }

  LineTouchData get lineTouchData1 => const LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
        ),
      );

  List<LineChartBarData> get lineBarsData1 => [
        lineChartBarData1_1,
        lineChartBarData1_2,
      ];

  LineChartBarData get lineChartBarData1_1 => LineChartBarData(
        isCurved: true,
        gradient: LinearGradient(colors: AppColors.primary),
        barWidth: 3,
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
          AppColors.secondaryColor1.withOpacity(0.5)
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
        text = Text('Jan', style: style);
        break;
      case 2:
        text = Text('Feb', style: style);
        break;
      case 3:
        text = Text('Mar', style: style);
        break;
      case 4:
        text = Text('Apr', style: style);
        break;
      case 5:
        text = Text('May', style: style);
        break;
      case 6:
        text = Text('Jun', style: style);
        break;
      case 7:
        text = Text('Jul', style: style);
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
}

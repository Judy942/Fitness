import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/widgets/find_st_to_eat.dart';
import 'package:flutter_application_fitness/widgets/round_button.dart';
import 'package:http/http.dart' as http;

import '../../core/utils/app_colors.dart';
import '../../widgets/today_meals_row.dart';
import '../onboarding_screen/start_screen.dart';
import 'meal_schedule/meal_schedule.dart';

Future<List> getMealType() async {
  // setState(() {
  //   isLoading = true;
  // });
  List somethingToEat = [];
  String? token = await getToken();
  final response = await http.get(
    Uri.parse(
        'http://162.248.102.236:8055/items/meal_type?filter[status][_neq]=archived'),
    headers: {'Authorization': 'Bearer $token'},
  );
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    // setState(() {
    somethingToEat = (jsonResponse['data'] as List).map((item) {
      return {
        'id': item['id'],
        'image': 'http://162.248.102.236:8055/assets/${item['image']}',
        "title": item['name'],
        "countFoods": item['dishes'].length,
      };
    }).toList();
    print(somethingToEat);
  } else {
    print('Có lỗi xảy ra: ${response.statusCode} - ${response.reasonPhrase}');
  }
  return somethingToEat;
}

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({Key? key}) : super(key: key);

  @override
  State<MealPlannerScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<MealPlannerScreen> {
  List<int> showingTooltipOnSpots = [21];
  bool isLoading = false;
  String dropdownValue = 'Breakfast';
  int selectedMeal = 0;
  List todayMeals = [];
  // List mealArr = [
  //   {
  //     "image": "assets/images/salmon_nigiri.png",
  //     "title": "SalMon Nigiri",
  //     "time": "Today, 07:00am"
  //   },
  //   {
  //     "image": "assets/images/milk.png",
  //     "title": "Lowfat Milk",
  //     "time": "Today, 08:00am"
  //   },
  // ];

  List somethingToEat = [];

  @override
  void initState() {
    super.initState();
    getMealType().then((value) {
      setState(() {
        somethingToEat = value;
      });
    });
    getMealSchedule(DateTime.now().toString().substring(0, 10)).then((value) {
      print(value);
      setState(() {
        todayMeals = value;
      });
    });
  }

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
  LineChartBarData get lineChartBarData => LineChartBarData(
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
          FlSpot(1, 65),
          FlSpot(2, 45),
          FlSpot(3, 68),
          FlSpot(4, 35),
          FlSpot(5, 80),
          FlSpot(6, 20),
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

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
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

    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
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
                "Meal Planner",
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
            body: SafeArea(
              child: Container(
                height: media.height * 0.9,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Meal Nutritions",
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
                                gradient:
                                    LinearGradient(colors: AppColors.primary),
                                borderRadius: BorderRadius.circular(15)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                items: ["Weekly", "Monthly"]
                                    .map((name) => DropdownMenuItem(
                                        value: name,
                                        child: Text(
                                          name,
                                          style: const TextStyle(
                                              color: AppColors.blackColor,
                                              fontSize: 14),
                                        )))
                                    .toList(),
                                onChanged: (value) {},
                                icon: const Icon(Icons.expand_more,
                                    color: AppColors.whiteColor),
                                hint: const Text("Weekly",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: AppColors.whiteColor,
                                        fontSize: 12)),
                              ),
                            ),
                          )
                        ],
                      ),
                      Container(
                          padding: const EdgeInsets.only(left: 15),
                          height: media.width * 0.5,
                          width: double.maxFinite,
                          child: LineChart(
                            LineChartData(
                              showingTooltipIndicators:
                                  showingTooltipOnSpots.map((index) {
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
                                handleBuiltInTouches: true,
                                touchCallback: (FlTouchEvent event,
                                    LineTouchResponse? response) {
                                  if (response == null ||
                                      response.lineBarSpots == null) {
                                    return;
                                  }
                                  if (event is FlTapUpEvent) {
                                    final spotIndex =
                                        response.lineBarSpots!.first.spotIndex;
                                    showingTooltipOnSpots.clear();
                                    setState(() {
                                      showingTooltipOnSpots.add(spotIndex);
                                    });
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
                                getTouchedSpotIndicator:
                                    (LineChartBarData barData,
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
                                          strokeColor:
                                              AppColors.secondaryColor1,
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
                              lineBarsData: [lineChartBarData],
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
                                horizontalInterval: 10,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color:
                                        AppColors.grayColor.withOpacity(0.15),
                                    strokeWidth: 2,
                                  );
                                },
                              ),
                              borderData: FlBorderData(
                                show: false,
                              ),
                            ),
                          )),
                      SizedBox(height: media.width * 0.05),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 15),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor2.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Daily Meal Schedule",
                              style: TextStyle(
                                  color: AppColors.blackColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700),
                            ),
                            SizedBox(
                              width: 80,
                              height: 30,
                              child: RoundButton(
                                type: RoundButtonType.primaryBG,
                                title: "Check",
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/mealScheduleScreen');
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: media.width * 0.05),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Today Meals",
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
                                gradient:
                                    LinearGradient(colors: AppColors.primary),
                                borderRadius: BorderRadius.circular(15)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                items: ["Breakfast", "Lunch", "Dinner", "Snack"]
                                    .map((name) => DropdownMenuItem(
                                        value: name,
                                        child: Text(
                                          name,
                                          style: const TextStyle(
                                              color: AppColors.blackColor,
                                              fontSize: 14),
                                        )))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    dropdownValue = value.toString();
                                    print(dropdownValue);
                                  });
                                },
                                icon: const Icon(Icons.expand_more,
                                    color: AppColors.whiteColor),
                                hint:  Text(dropdownValue,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: AppColors.whiteColor,
                                        fontSize: 12)),
                              ),
                            ),
                          )
                        ],
                      ),
                      todayMeals.isEmpty
                          ? const Center(
                              child: Text(
                                "No meal found",
                                style: TextStyle(
                                    color: AppColors.blackColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700),
                              ),
                            )
                          : SizedBox(height: media.width * 0.05),
                      for (var i = 0; i < todayMeals.length; i++)
                        if (todayMeals[i].isNotEmpty)
                          todayMeals[i]['code'].toUpperCase() ==
                                  dropdownValue.toUpperCase()
                              ? ListView.builder(
                                  padding: EdgeInsets.zero,
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: todayMeals[i]['meals'].length,
                                  itemBuilder: (context, index) {
                                    var wObj =
                                        todayMeals[i]['meals'][index] as Map? ??
                                            {};
                                    return TodayMealsRow(wObj: wObj);
                                  })
                              : const SizedBox(),
                      SizedBox(
                        height: media.width * 0.05,
                      ),
                      const Text(
                        "Find Something To Eat",
                        style: TextStyle(
                            color: AppColors.blackColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                      SizedBox(
                        height: media.width * 0.05,
                      ),
                      SingleChildScrollView(
                        // scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            SizedBox(
                              height: media.width * 0.5,
                              width: media.width - 40,
                              child: ListView.builder(
                                itemBuilder: (context, position) {
                                  if (position % 2 == 0) {
                                    var wObj =
                                        somethingToEat[position] as Map? ?? {};
                                    return Container(
                                        margin:
                                            const EdgeInsets.only(right: 20),
                                        width: media.width * 0.5,
                                        child: FindStToEat(wObj: wObj));
                                  } else {
                                    var wObj =
                                        somethingToEat[position] as Map? ?? {};
                                    return Container(
                                        margin:
                                            const EdgeInsets.only(right: 20),
                                        width: media.width * 0.45,
                                        child: FindStToEat(
                                            wObj: wObj,
                                            type: RoundButtonType.secondaryBG));
                                  }
                                },
                                padding: EdgeInsets.zero,
                                // physics: const NeverScrollableScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemCount: somethingToEat.length,
                              ),
                            ),
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

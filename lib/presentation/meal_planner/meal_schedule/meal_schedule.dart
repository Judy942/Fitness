import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/my_lib/calendar_agenda/lib/calendar_agenda.dart';
import 'package:flutter_application_fitness/presentation/meal_planner/meal_planner_screen.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';

import '../../../core/utils/app_colors.dart';
import '../../../models/workout.dart';
import '../../../services/user_service.dart';
import '../../../widgets/exercises_row.dart';
import '../../../widgets/showlog.dart';
import '../../home/home_screen.dart';
import 'add_meal_schedule.dart';

Future<List<Map<String, dynamic>>> getMealSchedule(String date) async {
  String? token = await getToken(); // Giả định bạn đã định nghĩa hàm getToken()
  final response = await http.get(
    Uri.parse('http://192.168.133.101:8055/api/meal_schedule?date=$date'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  print(response);
  log("response: ${response.body}");
  if (response.statusCode == 200) {
    // Chuyển đổi body của API thành List<Map<String, dynamic>>
    final Map<String, dynamic> responseBody = json.decode(response.body);
    final List<dynamic> data = responseBody['data'] ?? [];

    // Chuyển đổi dữ liệu thành List<Map<String, dynamic>>
    return List<Map<String, dynamic>>.from(data);
  } else {
    // Xử lý lỗi ở đây nếu cần
    throw Exception('Không thể tải lịch bữa ăn: ${response.statusCode}');
  }
}

class MealSchedule extends StatefulWidget {
  const MealSchedule({Key? key}) : super(key: key);

  @override
  State<MealSchedule> createState() => _MealScheduleState();
}

class _MealScheduleState extends State<MealSchedule> {
  final CalendarAgendaController _calendarAgendaControllerAppBar =
      CalendarAgendaController();
  late DateTime _selectedDateAppBBar;
  double userWeight = 0;
  late double proteinGoal;

  List mealScheduleArr = [];
  List nutritionGoalArr = [];

  List selectDayEventArr = [];

  @override
  void initState() {
    super.initState();
    getUserData().then((data) {
      setState(() {
        userWeight = data['weight']?.toDouble() ?? 0.0;
        proteinGoal = userWeight * 0.8;

        nutritionGoalArr = [
          {
            "title": "Calo",
            "value": "2000 kcal",
          },
          {
            "title": "Protein",
            "value": "${proteinGoal.toStringAsFixed(1)} g",
          },
          {
            "title": "Carb",
            "value": "130 g",
          },
        ];
      });
    });
    _selectedDateAppBBar = DateTime.now();
    getMealSchedule(DateFormat('yyyy-MM-dd').format(_selectedDateAppBBar))
        .then((value) {
      mealScheduleArr = value;
      setDayEventMealSchedule();
      getNutritionData();
      print(mealScheduleArr);

      setState(() {});
    });
  }

  void setDayEventMealSchedule() {
    selectDayEventArr = mealScheduleArr.map((wObj) {
      return {
        'id': wObj['id'],
        'name': wObj['name'],
        'from_time': wObj['from_time'],
        'to_time': wObj['to_time'],
        'meals': wObj['meals']
            .map((sObj) {
              var mealDate = DateTime.parse(sObj['meal_time']).toLocal();
              return {
                'id': sObj['id'],
                'meal_time': DateFormat('dd/MM/yyyy hh:mm a').format(mealDate),
                'dish_id': {
                  'id': sObj['dish_id']['id'],
                  'name': sObj['dish_id']['name'],
                  'description': sObj['dish_id']['description'],
                  'image':
                      'http://192.168.133.101:8055/assets/${sObj['dish_id']['image']}',
                  'nutritions': sObj['dish_id']['nutritions'],
                },
              };
            })
            .where((meal) => meal != null)
            .toList(),
      };
    }).toList();
  }

  int getCalories(List setArr) {
    int calories = 0;
    for (var sObj in setArr) {
      print(sObj["dish_id"]["nutritions"]);
      if (sObj["dish_id"] != null &&
          sObj["dish_id"]["nutritions"] != null &&
          sObj["dish_id"]["nutritions"].isNotEmpty) {
        calories += (sObj["dish_id"]["nutritions"].firstWhere((nutrition) =>
            nutrition["nutrition_id"]["code"] == "CAL")["value"] as int);
      }
    }
    return calories;
  }

  int sumCalories() {
    int calories = 0;
    for (var wObj in selectDayEventArr) {
      wObj["meals"].forEach((sObj) {
        calories += (sObj["dish_id"]["nutritions"][0]["value"] as int);
      });
    }
    return calories;
  }

  int sumProtein() {
    int protein = 0;
    for (var wObj in selectDayEventArr) {
      wObj["meals"].forEach((sObj) {
        protein += (sObj["dish_id"]["nutritions"][2]["value"] as int);
      });
    }
    return protein;
  }

  int sumCarbs() {
    int carbs = 0;
    for (var wObj in selectDayEventArr) {
      for (var sObj in wObj["meals"]) {
        var nuts = sObj["dish_id"]["nutritions"] as List;
        if (nuts.length > 3) {
          carbs += (nuts[3]["value"] as int);
        }
      }
    }
    return carbs;
  }

  int sumFat() {
    int fat = 0;
    for (var wObj in selectDayEventArr) {
      wObj["meals"].forEach((sObj) {
        fat += (sObj["dish_id"]["nutritions"][1]["value"] as int);
      });
    }
    return fat;
  }

  List getNutrition = [0, 0, 0, 0];

  int sumByCode(String code) {
    int total = 0;
    for (var wObj in selectDayEventArr) {
      for (var sObj in wObj["meals"]) {
        var nuts = sObj["dish_id"]["nutritions"] as List<dynamic>;
        var match = nuts.firstWhere((n) => n["nutrition_id"]["code"] == code,
            orElse: () => null);
        if (match != null) {
          total += (match["value"] as int);
        }
      }
    }
    return total;
  }

  void getNutritionData() {
    getNutrition = [
      sumByCode("CAL"),
      sumByCode("PROTEINS"),
      sumByCode("Carbo"),
      sumByCode("FATS"),
    ];
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
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const MealPlannerScreen()));
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
          "Lịch bữa ăn",
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
                width: 15,
                height: 15,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CalendarAgenda(
            controller: _calendarAgendaControllerAppBar,
            appbar: false,
            selectedDayPosition: SelectedDayPosition.center,
            leading: IconButton(
                onPressed: () {},
                icon: Image.asset(
                  "assets/icons/ArrowLeft.png",
                  width: 15,
                  height: 15,
                )),
            training: IconButton(
                onPressed: () {},
                icon: Image.asset(
                  "assets/icons/ArrowRight.png",
                  width: 15,
                  height: 15,
                )),
            weekDay: WeekDay.short,
            dayNameFontSize: 12,
            dayNumberFontSize: 16,
            dayBGColor: Colors.grey.withOpacity(0.15),
            titleSpaceBetween: 15,
            backgroundColor: Colors.transparent,
            fullCalendarScroll: FullCalendarScroll.horizontal,
            fullCalendarDay: WeekDay.short,
            selectedDateColor: Colors.white,
            dateColor: Colors.black,
            locale: 'en',
            initialDate: DateTime.now(),
            calendarEventColor: AppColors.primaryColor2,
            firstDate: DateTime.now().subtract(const Duration(days: 140)),
            lastDate: DateTime.now().add(const Duration(days: 60)),
            onDateSelected: (date) {
              DateTime now = DateTime.now();
              _selectedDateAppBBar = DateTime(
                date.year,
                date.month,
                date.day,
                now.hour,
                now.minute,
                now.second,
              );
              print("date: $_selectedDateAppBBar");
              getMealSchedule(
                      DateFormat('yyyy-MM-dd').format(_selectedDateAppBBar))
                  .then((value) async {
                mealScheduleArr = value;
                setDayEventMealSchedule();
                getNutritionData();
                print(mealScheduleArr);
                setState(() {});
              });
            },
            selectedDayLogo: Container(
              width: double.maxFinite,
              height: double.maxFinite,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: AppColors.primary,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          Expanded(
            child: Container(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      getNutrition[0] == 0
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Lottie.asset("assets/food.json",
                                    width: media.width,
                                    height: media.height * 0.35),
                                const Text(
                                  "Không có lịch bữa ăn cho hôm nay",
                                  style: TextStyle(
                                      color: AppColors.blackColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                              ],
                            )
                          : SizedBox(
                              width: media.width,
                              child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.only(bottom: 20),
                                itemCount: selectDayEventArr.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  var slotArr = selectDayEventArr;
                                  return slotArr[index]['meals'].isEmpty
                                      ? const SizedBox()
                                      : Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  slotArr[index]["name"],
                                                  style: const TextStyle(
                                                      color:
                                                          AppColors.blackColor,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  "${slotArr[index]["meals"].length} món| ${getCalories(slotArr[index]["meals"])} kcal",
                                                  style: const TextStyle(
                                                      color:
                                                          AppColors.blackColor,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            ListView.builder(
                                                padding: EdgeInsets.zero,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemCount: slotArr[index]
                                                        ["meals"]
                                                    .length,
                                                itemBuilder:
                                                    (context, itemIndex) {
                                                  var yObj = slotArr[index]
                                                      ["meals"][itemIndex];
                                                  return ExercisesRow(
                                                    ImagePadding: 10,
                                                    eObj: Exercise(
                                                        title: yObj["dish_id"]
                                                            ["name"],
                                                        image: yObj["dish_id"]
                                                            ["image"],
                                                        caloriesBurned: yObj[
                                                                    "dish_id"]
                                                                ["nutritions"]
                                                            [0]["value"],
                                                        id: yObj["id"],
                                                        value: yObj["meal_time"]
                                                            .toString()),
                                                    onPressed: () {
                                                      print(yObj);
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          var mealTime =
                                                              yObj["meal_time"];
                                                          String
                                                              formattedMealTime;
                                                          if (mealTime !=
                                                              null) {
                                                            try {
                                                              DateTime
                                                                  dateTime =
                                                                  DateFormat(
                                                                          "dd/MM/yyyy hh:mm a")
                                                                      .parse(
                                                                          mealTime);
                                                              formattedMealTime =
                                                                  DateFormat(
                                                                          "dd/MM/yyyy hh:mm a")
                                                                      .format(
                                                                          dateTime);
                                                            } catch (e) {
                                                              formattedMealTime =
                                                                  "Định dạng không hợp lệ";
                                                            }
                                                          } else {
                                                            formattedMealTime =
                                                                "Không xác định";
                                                          }

                                                          return ShowLog(
                                                            eObj: yObj
                                                              ..addAll({
                                                                "name": yObj[
                                                                        "dish_id"]
                                                                    ["name"],
                                                                "start_time":
                                                                    formattedMealTime,
                                                              }),
                                                            title:
                                                                "Lịch bữa ăn",
                                                          );
                                                        },
                                                      );
                                                    },
                                                  );
                                                }),
                                          ],
                                        );
                                },
                              ),
                            ),
                      const Text(
                        "Dinh dưỡng bữa ăn hôm nay",
                        style: TextStyle(
                            color: AppColors.blackColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ListView.builder(
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: nutritionGoalArr.length,
                          itemBuilder: (context, index) {
                            return Container(
                                width: media.width,
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: AppColors.whiteColor,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 5,
                                          offset: Offset(0, 2))
                                    ]),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          nutritionGoalArr[index]["title"],
                                          style: const TextStyle(
                                              color: AppColors.blackColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        Image.asset(
                                          "assets/images/fire.png",
                                          width: 20,
                                          height: 20,
                                        ),
                                        const Spacer(),
                                        Text(
                                          nutritionGoalArr[index]["value"],
                                          style: const TextStyle(
                                              color: AppColors.grayColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                    SimpleAnimationProgressBar(
                                      height: 15,
                                      width: media.width * 0.5,
                                      backgroundColor: Colors.grey.shade100,
                                      foregroundColor: Colors.purple,
                                      ratio: getNutrition[index] /
                                          double.parse(nutritionGoalArr[index]
                                                  ["value"]
                                              .split(" ")[0]),
                                      direction: Axis.horizontal,
                                      curve: Curves.fastLinearToSlowEaseIn,
                                      duration: const Duration(seconds: 3),
                                      borderRadius: BorderRadius.circular(7.5),
                                      gradientColor: LinearGradient(
                                          colors: AppColors.primary,
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight),
                                    ),
                                  ],
                                ));
                          }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: InkWell(
        onTap: () {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => AddMealSchedule(
                        date: _selectedDateAppBBar,
                      )));
        },
        child: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppColors.secondary),
              borderRadius: BorderRadius.circular(27.5),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
              ]),
          alignment: Alignment.center,
          child: const Icon(
            Icons.add,
            size: 20,
            color: AppColors.whiteColor,
          ),
        ),
      ),
    );
  }
}

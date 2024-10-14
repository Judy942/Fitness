import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/my_lib/calendar_agenda/lib/calendar_agenda.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';

import '../../../core/utils/app_colors.dart';
import '../../../model/workout.dart';
import '../../../widgets/exercises_row.dart';
import '../../../widgets/showlog.dart';
import '../../onboarding_screen/start_screen.dart';
import 'add_meal_schedule.dart';

Future<List<Map<String, dynamic>>> getMealSchedule(String date) async {
  String? token = await getToken(); // Giả định bạn đã định nghĩa hàm getToken()

  final response = await http.get(
    Uri.parse('http://162.248.102.236:8055/api/meal_schedule?date=$date'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    // Chuyển đổi body của API thành List<Map<String, dynamic>>
    final Map<String, dynamic> responseBody = json.decode(response.body);
    final List<dynamic> data = responseBody['data'] ?? [];

    // Chuyển đổi dữ liệu thành List<Map<String, dynamic>>
    return List<Map<String, dynamic>>.from(data);
  } else {
    // Xử lý lỗi ở đây nếu cần
    throw Exception('Failed to load meal schedule: ${response.statusCode}');
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

  List mealScheduleArr = [];
  List nutritionGoalArr = [
    {
      "title": "Calories",
      "value": "2000 kcal",
    },
    {
      "title": "Protein",
      "value": "100 g",
    },
    {
      "title": "Carbs",
      "value": "200 g",
    },
    {
      "title": "Fat",
      "value": "50 g",
    },
  ];

  List selectDayEventArr = [];

  @override
  void initState() {
    super.initState();
    _selectedDateAppBBar = DateTime.now();
    getMealSchedule(DateFormat('yyyy-MM-dd').format(_selectedDateAppBBar))
        .then((value) {
      mealScheduleArr = value;
      setDayEventMealSchedule();
      getNutritionData();
      print(mealScheduleArr);
      setState(() {});
    });
    // setDayEventMealSchedule();
  }

  void setDayEventMealSchedule() {
    // var date = dateToStartDate(_selectedDateAppBBar);

    selectDayEventArr = mealScheduleArr.map((wObj) {
      return {
        'id': wObj['id'],
        'name': wObj['name'],
        'from_time': wObj['from_time'],
        'to_time': wObj['to_time'],
        'meals': wObj['meals']
            .map((sObj) {
              var mealDate = DateTime.parse(sObj['meal_time']).toLocal();
              // var mealDate = DateTime.parse(sObj['meal_time']);
              return {
                'id': sObj['id'],
                'meal_time': DateFormat('dd/MM/yyyy hh:mm a').format(mealDate),
                'dish_id': {
                  'id': sObj['dish_id']['id'],
                  'name': sObj['dish_id']['name'],
                  'description': sObj['dish_id']['description'],
                  'image':
                      'http://162.248.102.236:8055/assets/${sObj['dish_id']['image']}', //sObj['dish_id']['image'],
                  'nutritions': sObj['dish_id']['nutritions'],
                },
              };
            })
            .where((meal) => meal != null)
            .toList(), // Lọc bỏ các món ăn null
      };
    }).toList();
  }

  int getCalories(List setArr) {
    int calories = 0;
    for (var sObj in setArr) {
      // calories += int.parse(sObj["nutrition"]["calories"]);
      if (sObj["dish_id"] != null &&
          sObj["dish_id"]["nutritions"] != null &&
          sObj["dish_id"]["nutritions"].isNotEmpty) {
        calories += (sObj["dish_id"]["nutritions"][0]["value"] as int);
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
      wObj["meals"].forEach((sObj) {
        carbs += (sObj["dish_id"]["nutritions"][3]["value"] as int);
      });
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

  void getNutritionData() {
    getNutrition = [
      sumCalories(), //calories
      sumProtein(), //protein
      sumCarbs(), //carbs
      sumFat(), //fat
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
          "Meal Schedule",
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
            // fullCalendar: false,
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
              // _selectedDateAppBBar = date;
              DateTime now = DateTime.now();

              _selectedDateAppBBar = DateTime(
                date.year,
                date.month,
                date.day,
                now.hour,
                now.minute,
                now.second, // Thêm giây nếu cần
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
                    // mainAxisAlignment: MainAxisAlignment.start,
                    // verticalDirection: VerticalDirection.up,
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
                                  "No meal schedule for today",
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
                              // height: media.height * 0.6,
                              child: ListView.builder(
                                // scrollDirection: Axis.vertical,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.only(bottom: 20),
                                itemCount: 4,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  var slotArr = selectDayEventArr;
                                  // print(slotArr);
                                  return slotArr[index]['meals'].isEmpty
                                      ? const SizedBox()
                                      : Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  // slotArr[index]["title"],
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
                                                  // "${slotArr[index]["set"].length} meals| ${getCalories(slotArr[index]["set"])} calories",
                                                  "${slotArr[index]["meals"].length} meals| ${getCalories(slotArr[index]["meals"])} calories",
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
                                                itemCount:
                                                    // slotArr[index]["set"].length,
                                                    slotArr[index]["meals"]
                                                        .length,
                                                itemBuilder:
                                                    (context, itemIndex) {
                                                  // var yObj = slotArr[index]["set"][itemIndex];
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
                                                      // showDialog(
                                                      //   context: context,
                                                      //   builder: (context) {
                                                      //     return ShowLog(
                                                      //       eObj: yObj,
                                                      //       title:
                                                      //           "Workout Schedule",
                                                      //     );
                                                      //   },
                                                      // );
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          // Kiểm tra xem meal_time có phải là null không
                                                          var mealTime =
                                                              yObj["meal_time"];
                                                          String
                                                              formattedMealTime;
                                                          if (mealTime !=
                                                              null) {
                                                            DateTime dateTime =
                                                                DateTime.parse(
                                                                    mealTime);
                                                            formattedMealTime =
                                                                DateFormat(
                                                                        "dd/MM/yyyy hh:mm a")
                                                                    .format(
                                                                        dateTime);
                                                          } else {
                                                            formattedMealTime =
                                                                "Không xác định"; // Hoặc xử lý theo cách khác
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
                                                                "Meal Schedule",
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
                        "Today Meal Nutritions",
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
                          itemCount: 4,
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
                                        //text: calories icon: fire
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
                                      foregrondColor: Colors.purple,
                                      // ratio: wObj["progress"] as double? ?? 0.0,
                                      ratio: getNutrition[index] /
                                          int.parse(nutritionGoalArr[index]
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
          Navigator.push(
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

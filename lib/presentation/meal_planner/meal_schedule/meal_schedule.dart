import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/my_lib/calendar_agenda/lib/calendar_agenda.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/date_and_time.dart';
import '../../../widgets/exercises_row.dart';
import '../../../widgets/showlog.dart';
import '../../onboarding_screen/start_screen.dart';
import 'add_meal_schedule.dart';

Future<List<Map<String, dynamic>>> getMealSchedule(String date) async {
  String? token = await getToken(); // Giả định bạn đã định nghĩa hàm getToken()
  
  final response = await http.get(
    Uri.parse('http://162.248.102.236:8055/api/meal_schedule?date=$date'),
        // Uri.parse('http://162.248.102.236:8055/api/meal_schedule?date=2024-10-08'),

    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  if (response.statusCode == 200) {
    final parsedData = json.decode(response.body);
    List<Map<String, dynamic>> mealSchedule = [];

    for (var meal in parsedData['data']) {
  mealSchedule.add({
    'id': meal['id'],
    'name': meal['name'],
    'from_time': meal['from_time'],
    'to_time': meal['to_time'],
    'meals': (meal['meals'] ?? []).map((m) {
      return {
        'id': m['id'],
        'name': m['dish_id']['name'],
        'description': m['dish_id']['description'],
        'image': 'http://162.248.102.236:8055/assets/images/dish/${m['dish_id']['image']}',
        'nutritions': m['dish_id']['nutritions'],
      };
    }).toList()
  });
}


    return mealSchedule;
  } else {
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
    //type 2024-08-20
    getMealSchedule(DateFormat('yyyy-MM-dd').format(_selectedDateAppBBar)).then((value) {
      mealScheduleArr = value;
      setDayEventMealSchedule();
      getNutritionData();
      print(mealScheduleArr);
      
    });
    // setDayEventMealSchedule();
  }
void setDayEventMealSchedule() {
  var date = dateToStartDate(_selectedDateAppBBar);
  selectDayEventArr = mealScheduleArr.map((wObj) {
    // Kiểm tra trường "set" có null không
    var setList = wObj["set"] ?? []; // Nếu null, gán cho danh sách rỗng
    return {
      "title": wObj["title"],
      "set": setList.map((sObj) {
        return {
          "name": sObj["name"],
          "start_time": stringToDate(sObj["time"].toString(),
              formatStr: "dd/MM/yyyy hh:mm aa"),
          "image": sObj["image"],
          "nutrition": sObj["nutrition"]
        };
      }).toList(),
    };
  }).where((wObj) {
    // Kiểm tra nếu "set" không rỗng trước khi truy cập phần tử
    if (wObj["set"].isNotEmpty) {
      return dateToStartDate(wObj["set"][0]["start_time"]) == date;
    }
    return false; // Nếu "set" rỗng, trả về false
  }).toList();

  if (mounted) {
    setState(() {});
  }
}


  int getCalories(List setArr) {
    int calories = 0;
    for (var sObj in setArr) {
      calories += int.parse(sObj["nutrition"]["calories"]);
    }
    return calories;
  }

  int sumCalories() {
    int calories = 0;
    for (var wObj in selectDayEventArr) {
      wObj["set"].forEach((sObj) {
        calories += int.parse(sObj["nutrition"]["calories"]);
        print(calories);
      });
    }
    return calories;
  }

  int sumProtein() {
    int protein = 0;
    for (var wObj in selectDayEventArr) {
      wObj["set"].forEach((sObj) {
        protein += int.parse(sObj["nutrition"]["protein"]);
      });
    }
    return protein;
  }

  int sumCarbs() {
    int carbs = 0;
    for (var wObj in selectDayEventArr) {
      wObj["set"].forEach((sObj) {
        carbs += int.parse(sObj["nutrition"]["carbs"]);
      });
    }
    return carbs;
  }

  int sumFat() {
    int fat = 0;
    for (var wObj in selectDayEventArr) {
      wObj["set"].forEach((sObj) {
        fat += int.parse(sObj["nutrition"]["fat"]);
      });
    }
    return fat;
  }

  List getNutrition = [0,0,0,0];

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
              _selectedDateAppBBar = date;
              setDayEventMealSchedule();
              getNutritionData();
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
                      SizedBox(
                        width: media.width,
                        // height: media.height * 0.6,
                        child: ListView.builder(
                          // scrollDirection: Axis.vertical,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: 4,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            var slotArr = selectDayEventArr.where((wObj) {
                              // return (wObj["date"] as DateTime).hour == index;
                              return (wObj["set"] as List).isNotEmpty;
                            }).toList();
                            return Column(
                              children: slotArr.length <= index
                                  ? [const SizedBox()]
                                  : [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            slotArr[index]["title"],
                                            style: const TextStyle(
                                                color: AppColors.blackColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700),
                                          ),
                                          const Spacer(),
                                          Text(
                                            "${slotArr[index]["set"].length} meals| ${getCalories(slotArr[index]["set"])} calories",
                                            style: const TextStyle(
                                                color: AppColors.blackColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400),
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
                                              slotArr[index]["set"].length,
                                          itemBuilder: (context, itemIndex) {
                                            var yObj = slotArr[index]["set"]
                                                [itemIndex];
                                            return ExercisesRow(
                                              ImagePadding: 10,
                                              eObj: yObj
                                                ..addAll({
                                                  "title": yObj["name"],
                                                  "value": DateFormat("hh:mm a")
                                                      .format(
                                                          yObj["start_time"]),
                                                }),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return ShowLog(
                                                      eObj: yObj
                                                        ..addAll({
                                                          "name": yObj["title"],
                                                          "start_time": DateFormat(
                                                                  "dd/MM/yyyy hh:mm a")
                                                              .format(yObj[
                                                                  "start_time"])
                                                        }),
                                                      title: "Meal Schedule",
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
                                      ratio: getNutrition[index] / int.parse(nutritionGoalArr[index]["value"].split(" ")[0]),
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

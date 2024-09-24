import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/my_lib/calendar_agenda/lib/calendar_agenda.dart';
import 'package:intl/intl.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/date_and_time.dart';
import '../../../widgets/exercises_row.dart';
import '../../../widgets/showlog.dart';

class MealSchedule extends StatefulWidget {
  const MealSchedule({Key? key}) : super(key: key);

  @override
  State<MealSchedule> createState() => _MealScheduleState();
}

class _MealScheduleState extends State<MealSchedule> {
  final CalendarAgendaController _calendarAgendaControllerAppBar =
      CalendarAgendaController();
  late DateTime _selectedDateAppBBar;

  List mealScheduleArr = [
    {
      "title": "Breakfast",
      "set": [
        {
          "name": "Honey Pancakes",
          "time": "21/09/2024 7:00 AM",
          "image": "assets/images/cake.png",
          "nutrition": {
            "calories": "350",
            "protein": "10",
            "carbs": "50",
            "fat": "15"
          },
        },
        {
          "name": "coffee",
          "time": "21/09/2024 8:00 AM",
          "image": "assets/images/coffee.png",
          "nutrition": {
            "calories": "100",
            "protein": "5",
            "carbs": "20",
            "fat": "5"
          },
        },
      ],
    },
    {
      "title": "Lunch",
      "set": [
        {
          "name": "Steak",
          "time": "21/09/2024 11:00 AM",
          "image": "assets/images/steak.png",
          "nutrition": {
            "calories": "500",
            "protein": "20",
            "carbs": "30",
            "fat": "25"
          },
        },
        {
          "name": "milk",
          "time": "21/09/2024 12:00 PM",
          "image": "assets/images/milk.png",
          "nutrition": {
            "calories": "150",
            "protein": "10",
            "carbs": "20",
            "fat": "5"
          },
        },
      ]
    },
    {
      "title": "Snack",
      "set": [
        {
          "name": "Orange",
          "time": "21/09/2024 3:00 PM",
          "image": "assets/images/orange.png",
          "nutrition": {
            "calories": "50",
            "protein": "2",
            "carbs": "10",
            "fat": "1"
          },
        },
        {
          "name": "Apple Pie",
          "time": "21/09/2024 4:00 PM",
          "image": "assets/images/apple_pie.png",
          "nutrition": {
            "calories": "200",
            "protein": "5",
            "carbs": "30",
            "fat": "10"
          },
        },
      ]
    },
    {
      "title": "Dinner",
      "set": [
        {
          "name": "Salad",
          "time": "21/09/2024 7:00 PM",
          "image": "assets/images/salad.png",
          "nutrition": {
            "calories": "200",
            "protein": "5",
            "carbs": "20",
            "fat": "10"
          },
        },
        {
          "name": "oatmeal",
          "time": "21/09/2024 8:00 PM",
          "image": "assets/images/oatmeal.png",
          "nutrition": {
            "calories": "300",
            "protein": "10",
            "carbs": "40",
            "fat": "15"
          },
        },
      ]
    },
    {
      "title": "Breakfast",
      "set": [
        {
          "name": "Honey Pancakes",
          "time": "22/09/2024 7:00 AM",
          "image": "assets/images/cake.png",
          "nutrition": {
            "calories": "350",
            "protein": "10",
            "carbs": "50",
            "fat": "15"
          },
        },
        {
          "name": "coffee",
          "time": "22/09/2024 8:00 AM",
          "image": "assets/images/coffee.png",
          "nutrition": {
            "calories": "100",
            "protein": "5",
            "carbs": "20",
            "fat": "5"
          },
        },
      ],
    },
    {
      "title": "Lunch",
      "set": [
        {
          "name": "Steak",
          "time": "22/09/2024 11:00 AM",
          "image": "assets/images/steak.png",
          "nutrition": {
            "calories": "500",
            "protein": "20",
            "carbs": "30",
            "fat": "25"
          },
        },
        {
          "name": "milk",
          "time": "22/09/2024 12:00 PM",
          "image": "assets/images/milk.png",
          "nutrition": {
            "calories": "150",
            "protein": "10",
            "carbs": "20",
            "fat": "5"
          },
        },
      ]
    },
    {
      "title": "Snack",
      "set": [
        {
          "name": "Orange",
          "time": "22/09/2024 3:00 PM",
          "image": "assets/images/orange.png",
          "nutrition": {
            "calories": "50",
            "protein": "2",
            "carbs": "10",
            "fat": "1"
          },
        },
        {
          "name": "Apple Pie",
          "time": "22/09/2024 4:00 PM",
          "image": "assets/images/apple_pie.png",
          "nutrition": {
            "calories": "200",
            "protein": "5",
            "carbs": "30",
            "fat": "10"
          },
        },
      ]
    },
    {
      "title": "Dinner",
      "set": [
        {
          "name": "Salad",
          "time": "22/09/2024 7:00 PM",
          "image": "assets/images/salad.png",
          "nutrition": {
            "calories": "200",
            "protein": "5",
            "carbs": "20",
            "fat": "10"
          },
        },
        {
          "name": "oatmeal",
          "time": "22/09/2024 8:00 PM",
          "image": "assets/images/oatmeal.png",
          "nutrition": {
            "calories": "300",
            "protein": "10",
            "carbs": "40",
            "fat": "15"
          },
        },
      ]
    },
    {
      "title": "Breakfast",
      "set": [
        {
          "name": "Honey Pancakes",
          "time": "23/09/2024 7:00 AM",
          "image": "assets/images/cake.png",
          "nutrition": {
            "calories": "350",
            "protein": "10",
            "carbs": "50",
            "fat": "15"
          },
        },
        {
          "name": "coffee",
          "time": "23/09/2024 8:00 AM",
          "image": "assets/images/coffee.png",
          "nutrition": {
            "calories": "100",
            "protein": "5",
            "carbs": "20",
            "fat": "5"
          },
        },
      ],
    },
    {
      "title": "Lunch",
      "set": [
        {
          "name": "Steak",
          "time": "23/09/2024 11:00 AM",
          "image": "assets/images/steak.png",
          "nutrition": {
            "calories": "500",
            "protein": "20",
            "carbs": "30",
            "fat": "25"
          },
        },
        {
          "name": "milk",
          "time": "23/09/2024 12:00 PM",
          "image": "assets/images/milk.png",
          "nutrition": {
            "calories": "150",
            "protein": "10",
            "carbs": "20",
            "fat": "5"
          },
        },
      ]
    },
    {
      "title": "Snack",
      "set": [
        {
          "name": "Orange",
          "time": "23/09/2024 3:00 PM",
          "image": "assets/images/orange.png",
          "nutrition": {
            "calories": "50",
            "protein": "2",
            "carbs": "10",
            "fat": "1"
          },
        },
        {
          "name": "Apple Pie",
          "time": "23/09/2024 4:00 PM",
          "image": "assets/images/apple_pie.png",
          "nutrition": {
            "calories": "200",
            "protein": "5",
            "carbs": "30",
            "fat": "10"
          },
        },
      ]
    }
  ];

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
    setDayEventMealSchedule();
  }

  void setDayEventMealSchedule() {
    var date = dateToStartDate(_selectedDateAppBBar);
    selectDayEventArr = mealScheduleArr.map((wObj) {
      return {
        "title": wObj["title"],
        "set": wObj["set"].map((sObj) {
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
      return dateToStartDate(wObj["set"][0]["start_time"]) == date;
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
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) => AddScheduleView(
          //           date: _selectedDateAppBBar,
          //         )));
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

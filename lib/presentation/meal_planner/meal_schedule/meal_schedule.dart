import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/my_lib/calendar_agenda/lib/calendar_agenda.dart';

import '../../../core/utils/app_colors.dart';

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
          "time": "7:00 AM",
          "image": "assets/images/cake.png",
          "nutrition": [
            {"calories": "350", "protein": "10", "carbs": "50", "fat": "15"},
          ]
        },
        {
          "name": "coffee",
          "time": "8:00 AM",
          "image": "assets/images/coffee.png",
          "nutrition": [
            {"calories": "100", "protein": "5", "carbs": "20", "fat": "5"},
          ]
        },
      ],
    },
    {
      "title": "Lunch",
      "set": [
        {
          "name": "Steak",
          "time": "11:00 AM",
          "image": "assets/images/steak.png",
          "nutrition": [
            {"calories": "500", "protein": "20", "carbs": "30", "fat": "25"},
          ]
        },
        {
          "name": "milk",
          "time": "12:00 PM",
          "image": "assets/images/milk.png",
          "nutrition": [
            {"calories": "150", "protein": "10", "carbs": "20", "fat": "5"},
          ]
        },
      ]
    },
    {
      "title": "Snack",
      "set": [
        {
          "name": "Orange",
          "time": "3:00 PM",
          "image": "assets/images/orange.png",
          "nutrition": [
            {"calories": "50", "protein": "2", "carbs": "10", "fat": "1"},
          ]
        },
        {
          "name": "Apple Pie",
          "time": "4:00 PM",
          "image": "assets/images/apple_pie.png",
          "nutrition": [
            {"calories": "200", "protein": "5", "carbs": "30", "fat": "10"},
          ]
        },
      ]
    },
    {
      "title": "Dinner",
      "set": [
        {
          "name": "Salad",
          "time": "7:00 PM",
          "image": "assets/images/salad.png",
          "nutrition": [
            {"calories": "200", "protein": "5", "carbs": "20", "fat": "10"},
          ]
        },
        {
          "name": "oatmeal",
          "time": "8:00 PM",
          "image": "assets/images/oatmeal.png",
          "nutrition": [
            {"calories": "300", "protein": "10", "carbs": "40", "fat": "15"},
          ]
        },
      ]
    },
  ];

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
          "Workout Schedule",
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
              // setDayEventWorkoutList();
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
              margin: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                  child: Column(
                children: [
                                        ListView.builder(
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: mealScheduleArr.length,
                          itemBuilder: (context, index) {
                            var sObj = mealScheduleArr[index] as Map? ?? {};
                            // return ExercisesSetSection(
                            //   sObj: sObj,
                            //   onPressed: (obj) {
                            //     Navigator.push(
                            //       context,
                            //       MaterialPageRoute(
                            //         builder: (context) => ExercisesStepDetails(eObj: obj,),
                            //       ),
                            //     );
                            //   },
                            // );
                          }),
            
                ],
              )),
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

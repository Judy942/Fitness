import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/my_lib/calendar_agenda/lib/calendar_agenda.dart';
import 'package:flutter_application_fitness/presentation/workout/workout_tracker/workout_tracker_screen.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/date_and_time.dart';
import '../../../widgets/showlog.dart';
import '../../onboarding_screen/start_screen.dart';
import 'add_schedule_view.dart';

class WorkoutScheduleView extends StatefulWidget {
  const WorkoutScheduleView({Key? key}) : super(key: key);

  @override
  State<WorkoutScheduleView> createState() => _WorkoutScheduleViewState();
}

class _WorkoutScheduleViewState extends State<WorkoutScheduleView> {
  final CalendarAgendaController _calendarAgendaControllerAppBar =
      CalendarAgendaController();
  late DateTime _selectedDateAppBBar;

  List eventArr = [];
  List workoutArr = [];
  bool isLoading = false;

  Future<void> getWorkoutSchedule(String url) async {
    setState(() {
      isLoading = true; // Đặt lại trạng thái loading
    });
    String? token =
        await getToken(); // Giả định bạn đã định nghĩa hàm getToken()

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      print("jsonResponse: $jsonResponse");
      setState(() {
        eventArr = jsonResponse["data"];
        setDayEventWorkoutList(); // Gọi ở đây để cập nhật selectDayEventArr
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${response.statusCode}')),
      );
      setState(() {
        isLoading = false;
      });
    }
    isLoading = false;
  }

  List selectDayEventArr = [];

  String createWorkoutScheduleUrl(DateTime date) {
    String formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    String startDate = "${formattedDate}T00:00:00%2B07:00";
    String endDate = "${formattedDate}T23:59:00%2B07:00";

    return 'http://162.248.102.236:8055/items/workout_schedule?filter[_and][0][_and][0][status][_neq]=archived&filter[_and][0][_and][1][user_id][_eq]=\$CURRENT_USER&filter[_and][0][_and][2][scheduled_execution_time][_gte]=$startDate&filter[_and][0][_and][3][scheduled_execution_time][_lte]=$endDate';
  }

  @override
  void initState() {
    super.initState();
    _selectedDateAppBBar = DateTime.now();
    getListWorkout().then((workouts) {
      workoutArr = workouts;

      setState(() {});
    });
    getWorkoutSchedule(createWorkoutScheduleUrl(_selectedDateAppBBar));
    setDayEventWorkoutList();
  }

  String formatScheduledTime(String time) {
    DateTime dateTime = DateTime.parse(time); // Parse từ chuỗi
    return DateFormat('dd/MM/yyyy hh:mm a').format(dateTime); // Định dạng lại
  }

  void setDayEventWorkoutList() {
    var date = dateToStartDate(_selectedDateAppBBar);

    selectDayEventArr = eventArr.map((wObj) {
      // Chuyển đổi thời gian từ chuỗi thành DateTime
      DateTime scheduledTime =
          DateTime.parse(wObj["scheduled_execution_time"]).toLocal();
          
      String workoutName = workoutArr.where((w) {
        return w["id"] == wObj["workout_id"];
      }).isNotEmpty
          ? workoutArr.where((w) {
              return w["id"] == wObj["workout_id"];
            }).first["title"]
          : " Workout"; // Hoặc giá trị mặc định khác
      return {
        "name": workoutName,
        "start_time": DateFormat('dd/MM/yyyy hh:mm a').format(scheduledTime),
        "date": scheduledTime,
      };
    }).where((wObj) {
      return dateToStartDate(wObj["date"] as DateTime) == date;
    }).toList();

    if (mounted) {
      setState(() {});
    }
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
            initialDate: _selectedDateAppBBar,
            calendarEventColor: AppColors.primaryColor2,
            firstDate: DateTime.now().subtract(const Duration(days: 140)),
            lastDate: DateTime.now().add(const Duration(days: 60)),
            onDateSelected: (date) async {
              // _selectedDateAppBBar = date;
              DateTime now = DateTime.now();

              // Kết hợp ngày đã chọn với giờ hiện tại
              _selectedDateAppBBar = DateTime(
                date.year,
                date.month,
                date.day,
                now.hour,
                now.minute,
                now.second, // Thêm giây nếu cần
              );
              print("date: $_selectedDateAppBBar");
              getWorkoutSchedule(createWorkoutScheduleUrl(date));
              setDayEventWorkoutList();
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
            child: isLoading
                ? const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: media.width * 1,
                      child: ListView.separated(
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            var availWidth = (media.width * 1.2) - (80 + 40);
                            var slotArr = selectDayEventArr.where((wObj) {
                              return (wObj["date"] as DateTime).hour == index;
                            }).toList();
                            print("slotArr: $slotArr");

                            return Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              height: 40,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 80,
                                    child: Text(
                                      getTime(index * 60),
                                      style: const TextStyle(
                                        color: AppColors.blackColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  if (slotArr.isNotEmpty)
                                    Expanded(
                                      child: ListView.builder(
                                        scrollDirection: Axis
                                            .horizontal, // Hiển thị theo chiều ngang
                                        itemCount: slotArr.length,
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          var sObj = slotArr[index];
                                          return InkWell(
                                            onTap: () {
                                              print("slotArr: $slotArr");
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return ShowLog(
                                                    eObj: sObj,
                                                    title: "Workout Schedule",
                                                  );
                                                },
                                              );
                                            },
                                            child: Container(
                                              height: 35,
                                              width: availWidth * 0.5,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8),
                                              alignment: Alignment.centerLeft,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                    colors:
                                                        AppColors.secondary),
                                                borderRadius:
                                                    BorderRadius.circular(17.5),
                                              ),
                                              child: Text(
                                                "${sObj["name"].toString()}, ${getStringDateToOtherFormate(sObj["start_time"].toString(), outFormatStr: "h:mm aa")}",
                                                maxLines: 1,
                                                style: const TextStyle(
                                                  color: AppColors.whiteColor,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return Divider(
                              color: AppColors.grayColor.withOpacity(0.2),
                              height: 1,
                            );
                          },
                          itemCount: 24),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: InkWell(
        onTap: () {
          // chờ 3giây
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => AddScheduleView(
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

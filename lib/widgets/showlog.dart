import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/presentation/meal_planner/meal_schedule/add_meal_schedule.dart';
import 'package:flutter_application_fitness/presentation/workout/workout_schedule_view/add_schedule_view.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../core/utils/app_colors.dart';
import '../core/utils/date_and_time.dart';
import '../presentation/onboarding_screen/start_screen.dart';
import 'round_gradient_button.dart';

class ShowLog extends StatelessWidget {
  final Map eObj;
  final String title;
  const ShowLog({Key? key, required this.eObj, required this.title})
      : super(key: key);
  Future<void> _editEvent(BuildContext context) async {
    final id = eObj["id"]; // Giả sử eObj chứa id
    String url = "";
    if (eObj["workout_id"] != null) {
      url = 'http://162.248.102.236:8055/items/workout_schedule/$id';
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AddScheduleView(date: DateFormat("dd/MM/yyyy hh:mm a").parse(eObj["start_time"]), obj: eObj, url: url, isEdit: true,),
        ),
      );
    } else if (eObj["dish_id"] != null) {
      url = 'http://162.248.102.236:8055/items/meal_schedule/$id';
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AddMealSchedule(date: DateFormat("dd/MM/yyyy hh:mm a").parse(eObj["start_time"]), obj: eObj, url: url, isEdit: true,),
        ),
      );
      
    } else {
      print("Not found item id: $id to delete");
      print(url);
      return;
    }

  }
  void _deleteEvent(BuildContext context) async {
    String? token = await getToken();
    final id = eObj["id"]; // Giả sử eObj chứa id
    String url = "";
    //kiểm tra phần tử là exercise hay meal
    if (eObj["workout_id"] != null) {
      url = 'http://162.248.102.236:8055/items/workout_schedule/$id';
    } else if (eObj["dish_id"] != null) {
      url = 'http://162.248.102.236:8055/items/meal_schedule/$id';
    } else {
      return;
    }
    print(url);
    final response = await http.delete(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200 ||
        response.statusCode == 204 ||
        response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Deleted successfully!'),
      ),
      );
   
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
      Navigator.pop(context);
      print("Failed to delete workout: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Failed to delete workout!'),
      ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      content: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    height: 30,
                    width: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: AppColors.lightGrayColor,
                        borderRadius: BorderRadius.circular(10)),
                    child: Image.asset(
                      "assets/icons/closed_btn.png",
                      width: 15,
                      height: 15,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
                InkWell(
                  onTap: () {
                    _showOptionsDialog(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    height: 30,
                    width: 30,
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
            const SizedBox(
              height: 15,
            ),
            Text(
              eObj["name"].toString(),
              style: const TextStyle(
                  color: AppColors.blackColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(
              height: 4,
            ),
            Row(children: [
              Image.asset(
                "assets/icons/time_workout.png",
                height: 20,
                width: 20,
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                "${getDayTitle(eObj["start_time"].toString())}|${getStringDateToOtherFormate(eObj["start_time"].toString(), outFormatStr: "h:mm aa")}",
                style:
                    const TextStyle(color: AppColors.grayColor, fontSize: 12),
              )
            ]),
            const SizedBox(
              height: 15,
            ),
            RoundGradientButton(
                title: "Mark Done",
                onPressed: () {
                  Navigator.pop(context);
                }),
          ],
        ),
      ),
    );
  }

  void _showOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Choose an option"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text("Edit"),
                onTap: () {
                  _editEvent(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text("Delete"),
                onTap: () {
                  // Gọi hàm xóa sự kiện ở đây
                  _deleteEvent(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

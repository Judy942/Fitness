import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../core/utils/app_colors.dart';
import '../core/utils/date_and_time.dart';
import '../presentation/onboarding_screen/start_screen.dart';
import 'round_gradient_button.dart';

class ShowLog extends StatelessWidget {
  final Map eObj;
  final String title;
  const ShowLog({Key? key, required this.eObj, required this.title})
      : super(key: key);
void _editEvent() {
  // Thêm logic sửa sự kiện ở đây
  print("Edit event");
}

void _deleteEvent(BuildContext context) async {
    String? token = await getToken();
    final id = eObj["id"]; // Giả sử eObj chứa id
    final url = 'http://162.248.102.236:8055/items/workout_schedule/$id';
print(url);
    final response = await http.delete(Uri.parse(url),
          headers: {'Authorization': 'Bearer $token'},
);

    if (response.statusCode == 204) {

      // Navigator.pop(context);
      const SnackBar(
        content: Text('Workout deleted successfully!'),
      );
      
    } else {
      // Xảy ra lỗi
      // Navigator.pop(context);
      print("Failed to delete workout: ${response.body}");
      // ScaffoldMessenger.of(context).showSnackBar(
      // const SnackBar(
      //   content: Text('Failed to delete workout!'),
      // ),
    // );
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
                Navigator.pop(context);
                                Navigator.pop(context);

                _editEvent();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text("Delete"),
              onTap: () {
                Navigator.pop(context);
                                Navigator.pop(context);

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

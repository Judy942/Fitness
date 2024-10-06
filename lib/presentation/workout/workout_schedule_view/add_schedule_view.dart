
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/date_and_time.dart';
import '../../../widgets/icon_title_next_row.dart';
import '../../../widgets/round_gradient_button.dart';
import '../../onboarding_screen/start_screen.dart';


class AddScheduleView extends StatefulWidget {
   DateTime date;
   AddScheduleView({super.key, required this.date});

  @override
  State<AddScheduleView> createState() => _AddScheduleViewState();
}

class _AddScheduleViewState extends State<AddScheduleView> {
  List whatArr = [];
bool isLoading = true; // Biến để theo dõi trạng thái tải dữ liệu

Future<void> getListWorkout() async {
  String? token = await getToken(); // Giả định bạn đã định nghĩa hàm getToken()

  final response = await http.get(
    Uri.parse('http://162.248.102.236:8055/items/workout?limit=5&page=1&meta=*'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    setState(() {
      whatArr = (jsonResponse['data'] as List).map((item) {
        return {
          'id': item['id'],
          'image': item['image'],
          "title": item['name'],
          "exercises": "${item['exercises'].length} Exercises",
          "time": "${item['time']} mins"
        };
      }).toList();
      isLoading = false; // Đánh dấu rằng dữ liệu đã được tải
    });
  } else {
    // Xử lý lỗi
    print('Có lỗi xảy ra: ${response.statusCode} - ${response.reasonPhrase}');
    setState(() {
      isLoading = false; // Cũng đánh dấu là đã xong
    });
  }
}


  @override
  void initState() {
    super.initState();
    getListWorkout();
  }
  @override
  Widget build(BuildContext context) {
    int timeId = 0; // Initialize timeId with a default value
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
              "assets/icons/closed_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: const Text(
          "Add Schedule",
          style: TextStyle(
              color: AppColors.blackColor, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        // actions: [
        //   InkWell(
        //     onTap: () {
        //     },
        //     child: Container(
        //       margin: const EdgeInsets.all(8),
        //       height: 40,
        //       width: 40,
        //       alignment: Alignment.center,
        //       decoration: BoxDecoration(
        //           color: AppColors.lightGrayColor,
        //           borderRadius: BorderRadius.circular(10)),
        //       child: Image.asset(
        //         "assets/icons/more_icon.png",
        //         width: 15,
        //         height: 15,
        //         fit: BoxFit.contain,
        //       ),
        //     ),
        //   )
        // ],
      ),
      backgroundColor: AppColors.whiteColor,
      body: isLoading
        ? const Center(child: CircularProgressIndicator()) // Hiển thị khi đang tải
        : Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Image.asset(
                "assets/icons/date.png",
                width: 20,
                height: 20,
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                dateToString(widget.date, formatStr: "E, dd MMMM yyyy"),
                style: const TextStyle(color: AppColors.grayColor, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "Time",
            style: TextStyle(
                color: AppColors.blackColor, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          SizedBox(
            height: media.width * 0.35,
            child: CupertinoDatePicker(
              onDateTimeChanged: (newDate) {
                widget.date = newDate;
                print(widget.date);
              },
              initialDateTime: DateTime.now(),
              use24hFormat: false,
              minuteInterval: 1,
              mode: CupertinoDatePickerMode.time,
              
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "Details Workout",
            style: TextStyle(
                color: AppColors.blackColor, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(
            height: 8,
          ),
          
          IconTitleNextRow(
            
              icon: "assets/icons/choose_workout.png",
              title: "Choose Workout",
              time: whatArr.isNotEmpty ?whatArr[timeId]['title']:'',
              color: AppColors.lightGrayColor,
              onPressed: () async {
                  int selectedId = await _showWorkoutDialog(context);
                  setState(() {
                    timeId = selectedId; // Cập nhật ID khi chọn workout
                  });
              },
          ),
          const SizedBox(
            height: 10,
          ),
          IconTitleNextRow(
              icon: "assets/icons/difficulity_icon.png",
              title: "Difficulity",
              time: "Beginner",
              color: AppColors.lightGrayColor,
              onPressed: () {}),
          const SizedBox(
            height: 10,
          ),
          IconTitleNextRow(
              icon: "assets/icons/repetitions.png",
              title: "Custom Repetitions",
              time: "",
              color: AppColors.lightGrayColor,
              onPressed: () {}),
          const SizedBox(
            height: 10,
          ),
          IconTitleNextRow(
              icon: "assets/icons/repetitions.png",
              title: "Custom Weights",
              time: "",
              color: AppColors.lightGrayColor,
              onPressed: () {}),
          const Spacer(),
          RoundGradientButton(title: "Save", onPressed: () {
            

          }),
          const SizedBox(
            height: 20,
          ),
        ]),
      ),
    );
  }
  Future<int> _showWorkoutDialog(BuildContext context) async {
  int selectedWorkoutId = -1; // Giá trị mặc định hoặc bất kỳ giá trị thích hợp nào
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Select Workout'),
        content: SizedBox(
          width: double.maxFinite, // Đảm bảo dialog có chiều rộng tối đa
          child: SingleChildScrollView(
            child: ListBody(
              children: [
                ListView.separated(
                  shrinkWrap: true, // Để ListView không chiếm toàn bộ không gian
                  physics: const NeverScrollableScrollPhysics(), // Tắt cuộn của ListView
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(whatArr[index]['title']??''), // Thay đổi phù hợp với cấu trúc của bạn
                      onTap: () {
                        selectedWorkoutId = whatArr[index]['id'];
                        Navigator.of(context).pop(); // Đóng dialog
                      },
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: whatArr.length,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
  return selectedWorkoutId;
}


}


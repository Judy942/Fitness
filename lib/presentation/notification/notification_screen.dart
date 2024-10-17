import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/utils/app_colors.dart';
import '../../widgets/notification_row.dart';
import '../onboarding_screen/start_screen.dart';


class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<dynamic> notificationArr = [];

  Future<void> getNotification() async {
    String? token = await getToken(); // Đảm bảo phương thức này đã được định nghĩa
    final response = await http.get(
      Uri.parse('http://162.248.102.236:8055/api/activity/nearest?limit=5'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        notificationArr = data['data']; 
              print(data);

      });
    } else {
      print('Failed to load notification');
    }
  }

  @override
  void initState() {
    super.initState();
    getNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset("assets/icons/back_icon.png", width: 15, height: 15),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Notification",
          style: TextStyle(color: AppColors.blackColor, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: Image.asset("assets/icons/more_icon.png", width: 12, height: 12),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        itemCount: notificationArr.length,
        itemBuilder: (context, index) {
          var nObj = notificationArr[index] as Map<String, dynamic>? ?? {};
          return NotificationRow(nObj: nObj);
        },
        separatorBuilder: (context, index) {
          return Divider(color: AppColors.grayColor.withOpacity(0.5), height: 1);
        },
      ),
    );
  }
}

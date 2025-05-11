import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../core/utils/app_colors.dart';
import '../presentation/onboarding_screen/start_screen.dart';
import '../services/user_service.dart';

class TodayMealsRow extends StatefulWidget {
  final Map wObj;
  const TodayMealsRow({Key? key, required this.wObj}) : super(key: key);

  @override
  State<TodayMealsRow> createState() => _TodayMealsRowState();
}

class _TodayMealsRowState extends State<TodayMealsRow> {
  bool positive = true;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)]),
        child: Row(
          children: [
            ClipRRect(
              child: Image.network(
                'http://192.168.194.186:8055/assets/${widget.wObj['dish_id']["image"]}',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.wObj['dish_id']["name"].toString(),
                  style: const TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  'Today | ${DateFormat('hh:mm a').format(DateTime.parse(widget.wObj["meal_time"]).toLocal())}',
                  style: const TextStyle(
                    color: AppColors.grayColor,
                    fontSize: 12,
                  ),
                ),
              ],
            )),
            Checkbox(
              value: widget.wObj['is_completed'] ?? false,
              onChanged: (value) async {
                setState(() {
                  widget.wObj['is_completed'] = value ?? false;
                });
                // Cập nhật lại giá trị trên server
                String? token = await getToken();
                final response = await http.patch(
                  Uri.parse('http://192.168.194.186:8055/items/meal_schedule/${widget.wObj['id']}'),
                  headers: {
                    'Authorization': 'Bearer $token',
                    'Content-Type': 'application/json'
                  },
                  body: json.encode({'is_completed': widget.wObj['is_completed']}),
                );
                
                if (response.statusCode != 200) {
                  // Xử lý lỗi nếu cần
                  print('Cập nhật thất bại: ${response.statusCode}');
                }
              },
              activeColor: Colors.blue,
            ),
          ],
        ));
  }
}

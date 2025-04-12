import 'package:flutter/material.dart';

import '../../../core/utils/app_colors.dart';
import '../../../services/user_service.dart';

class MealHistoryScreen extends StatefulWidget {
  const MealHistoryScreen({Key? key}) : super(key: key);

  @override
  State<MealHistoryScreen> createState() => _MealHistoryScreenState();
}

class _MealHistoryScreenState extends State<MealHistoryScreen> {
  final UserService _userService = UserService();
  List mealHistoryArr = [];

  @override
  void initState() {
    super.initState();
    _fetchMealHistory();
  }

  Future<void> _fetchMealHistory() async {
    // Thay đổi URL API để lấy lịch sử bữa ăn
    List<dynamic> meals = await _userService.fetchData(
      'http://192.168.95.1:8055/items/meal?fields=*&sort=-date'
    );

    setState(() {
      mealHistoryArr = meals;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Lịch sử bữa ăn",
          style: TextStyle(
            color: AppColors.blackColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: mealHistoryArr.isEmpty 
      ? const Center(
          child: Text("Chưa có dữ liệu bữa ăn"),
        )
      : ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: mealHistoryArr.length,
        itemBuilder: (context, index) {
          var meal = mealHistoryArr[index] as Map? ?? {};
          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal["name"] ?? "Bữa ăn không tên",
                  style: const TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Ngày: ${meal["date"] ?? "Không có thông tin"}",
                  style: const TextStyle(
                    color: AppColors.grayColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Calo: ${meal["calories"] ?? "0"} kcal",
                  style: const TextStyle(
                    color: AppColors.grayColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 
import 'package:flutter/material.dart';

import '../../../core/utils/app_colors.dart';
import '../../../services/user_service.dart';
import '../../../widgets/today_meals_row.dart';

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
    List<dynamic> response = await _userService.fetchData(
      'http://192.168.133.102:8055/items/meal_schedule?fields=*,dish_id.*&filter[_and][1][status][_neq]=archived&sort=-meal_time'
    );

    setState(() {
      mealHistoryArr = response;
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
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 1,
            itemBuilder: (context, mealIndex) {
              return TodayMealsRow(wObj: meal); // Sử dụng TodayMealsRow để hiển thị món ăn
            },
          );
        },
      ),
    );
  }
} 
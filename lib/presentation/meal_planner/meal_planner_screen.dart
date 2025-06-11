import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/presentation/activity_tracker/activity_tracker_screen.dart';
import 'package:flutter_application_fitness/widgets/round_button.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

import '../../core/utils/app_colors.dart';
import '../../services/user_service.dart';
import '../../widgets/popular_container.dart';
import '../../widgets/today_meals_row.dart';
import 'meal_planner_detail/meal_planner_detail_screen.dart';
import 'meal_schedule/meal_schedule.dart';

Future<List> fetchDishes(String endpoint) async {
  String? token = await getToken(); // Giả định bạn đã định nghĩa hàm getToken()
  List dishArr = [];

  final response = await http.get(
    Uri.parse(endpoint),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);

    // Lấy danh sách món ăn từ jsonResponse
    for (var item in jsonResponse['data']) {
      var dish = item['dish_id'] ??
          item; // Sử dụng item['dish_id'] nếu có, nếu không thì sử dụng item
      // dishArr.add({
      //   'id': dish['id'],
      //   'name': dish['name'],
      //   'description': dish['description'],
      //   'cooking_time': dish['cooking_time'],
      //   'image': 'http://192.168.133.102:8055/assets/${dish['image']}',
      //   // 'difficulty': dish['difficulty_id'],
      //   'difficulty': dish['difficulty_id']
      //       is Map, //&& dish['difficulty_id'].containsKey('name')) ? dish['difficulty_id']['name'] : null, // Thêm độ khó
      //   'nutritions': dish['nutritions'] ,// Thêm thông tin dinh dưỡng nếu cần
      //   'Type': dish['Type'] ,
      // });
      dishArr.add(dish);
    }
  } else {
    throw Exception('Failed to load dishes: ${response.statusCode}');
  }

  return dishArr;
}

Future<List> getListPopular() async {
  return await fetchDishes(
      'http://192.168.133.102:8055/items/dish?limit=25&fields=*,dish_id.*,dish_id.difficulty_id.*,dish_id.nutritions.*,dish_id.nutritions.nutrition_id.*&sort[]=sort&page=1&filter[status][_neq]=archived');
}

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({Key? key}) : super(key: key);

  @override
  State<MealPlannerScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<MealPlannerScreen> {
  bool isLoading = false;
  List todayMeals = [];
  List popularArr = [];

  Future<void> refreshData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final value = await getMealSchedule(DateTime.now().toString().substring(0, 10));
      print("value today meal: $value");
      final popularValue = await getListPopular();
      
      if (!mounted) return;
      
      setState(() {
        todayMeals = value;
        popularArr = popularValue;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    refreshData();
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
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const ActivityTrackerScreen()));
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
          "Lập kế hoạch bữa ăn",
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
                width: 12,
                height: 12,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: refreshData,
              child: Container(
                height: media.height * 0.9,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Opacity(
                    opacity: isLoading ? 0.5 : 1.0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Bữa ăn hôm nay",
                          style: TextStyle(
                            color: AppColors.blackColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        todayMeals.isEmpty ||
                                todayMeals.every((meal) => meal['meals'].isEmpty)
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Không tìm thấy bữa ăn nào",
                                      style: TextStyle(
                                          color: AppColors.blackColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 10),
                                    Lottie.asset(
                                      'assets/food.json',
                                      height: 100,
                                      width: 100,
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.zero,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: todayMeals.length,
                                itemBuilder: (context, index) {
                                  if (todayMeals[index].isNotEmpty) {
                                    return ListView.builder(
                                      padding: EdgeInsets.zero,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount:
                                          todayMeals[index]['meals'].length,
                                      itemBuilder: (context, mealIndex) {
                                        var wObj = todayMeals[index]['meals']
                                                [mealIndex] as Map? ??
                                            {};
                                        return TodayMealsRow(wObj: wObj);
                                      },
                                    );
                                  }
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "Không có lịch nào",
                                          style: TextStyle(
                                              color: AppColors.blackColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        const SizedBox(height: 10),
                                        Lottie.asset(
                                          'assets/food.json',
                                          height: 100,
                                          width: 100,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                        SizedBox(
                          height: media.width * 0.05,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 15),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor2.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Lịch bữa ăn hôm nay",
                                style: TextStyle(
                                    color: AppColors.blackColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700),
                              ),
                              SizedBox(
                                width: 95,
                                height: 30,
                                child: RoundButton(
                                  type: RoundButtonType.primaryBG,
                                  title: "Kiểm tra",
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const MealSchedule(),
                                      ),
                                    );
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: media.width * 0.05),
                        Row(
                          children: [
                            const Text(
                              "Tìm kiểm món ăn",
                              style: TextStyle(
                                  color: AppColors.blackColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700),
                            ),
                            const Spacer(),
                            TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              MealPlannerDetailScreen(
                                                popularDishes: popularArr,
                                              )));
                                },
                                child: const Text("Xem tất cả"))
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.width *
                              0.25 *
                              popularArr.length,
                          width: MediaQuery.of(context).size.width * 0.98,
                          child: ListView.builder(
                            itemBuilder: (context, position) {
                              var wObj = popularArr[position] as Map? ?? {};
                              return Container(
                                  margin: const EdgeInsets.only(bottom: 15, left: 10,right: 10),
                                  child: PopularContainer(wObj: wObj));
                            },
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),

                            // scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: popularArr.length,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}

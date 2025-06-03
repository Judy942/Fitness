import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/widgets/recommendation_container.dart';
import 'package:http/http.dart' as http;

import '../../../core/utils/app_colors.dart';
import '../../../services/user_service.dart';
import '../../../widgets/category_container.dart';
import '../../../widgets/popular_container.dart';
import '../../../widgets/round_button.dart';
import '../../onboarding_screen/start_screen.dart';
import 'meal_details_screen.dart';

Future<List> getRecommendation(List popularDishes) async {
  List recommendedDishes = [];
  String bmiString = await getBmi(); // Lấy giá trị BMI dưới dạng String
  double bmi = double.tryParse(bmiString) ??
      0.0; // Chuyển đổi sang double, nếu không thành công thì gán 0.0
  int mealType = 0;

  if (bmi >= 18.5 && bmi <= 24.9) {
    mealType = 0; // Cân đối
  } else if (bmi > 24.9) {
    mealType = 1; // Thừa cân
  } else if (bmi < 18.5) {
    mealType = 2; // Thiếu cân
  }

  for (var dish in popularDishes) {
    if (dish['Type'] != null && dish['Type'] == mealType) {
      recommendedDishes.add(dish);
    }
  }
  return recommendedDishes;
}

class MealPlannerDetailScreen extends StatefulWidget {
  final List popularDishes;
  const MealPlannerDetailScreen({Key? key, required this.popularDishes})
      : super(key: key);

  @override
  State<MealPlannerDetailScreen> createState() =>
      _MealPlannerDetailScreenState();
}

class _MealPlannerDetailScreenState extends State<MealPlannerDetailScreen> {
  bool isLoading = true; // Biến để theo dõi trạng thái tải dữ liệu

  List categoryArr = [];
  List recommendationArr = [];
  List filteredDishes = [];
  String searchQuery = '';

  Future<void> getListCategory() async {
    String? token =
        await getToken(); // Giả định bạn đã định nghĩa hàm getToken()

    final response = await http.get(
      Uri.parse(
          'http://192.168.133.100:8055/items/dish_category?filter[status][_neq]=archived'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      setState(() {
        categoryArr = (jsonResponse['data'] as List).map((item) {
          return {
            'id': item['id'],
            'image': 'http://192.168.133.100:8055/assets/${item['image']}',
            "name": item['name'],
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
    getListCategory();
    getRecommendation(widget.popularDishes).then((value) {
      setState(() {
        recommendationArr = value;
        filteredDishes = widget.popularDishes;
      });
    });
  }

  void _filterDishes(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredDishes = widget.popularDishes;
      } else {
        filteredDishes = widget.popularDishes
            .where((dish) => (dish['name'] as String)
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('recommendationArr: $recommendationArr');
    print('widget.popularDishes: ${widget.popularDishes}');
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
          'Lập kế hoạch bữa ăn',
          style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 20,
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
            Container(
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                      onChanged: (query) => _filterDishes(query),
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm món ăn...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    if (searchQuery.isNotEmpty)
                      Container(
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: ListView.builder(
                          itemCount: filteredDishes.length,
                          itemBuilder: (context, index) {
                            var wObj = filteredDishes[index] as Map? ?? {};
                            return ListTile(
                              leading: Image.network(
                                'http://192.168.133.100:8055/assets/${wObj["image"]}',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.error);
                                },
                              ),
                              title: Text(wObj['name'] ?? 'Món ăn'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MealDetailsScreen(
                                      dObj: wObj,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Danh mục',
                      style: TextStyle(
                          color: AppColors.blackColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.width * 0.35,
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: ListView.builder(
                        itemBuilder: (context, position) {
                          if (position % 2 == 0) {
                            var wObj = categoryArr[position] as Map? ?? {};
                            return Container(
                                margin: const EdgeInsets.only(right: 15),
                                width: MediaQuery.of(context).size.width * 0.25,
                                child: CategoryContainer(wObj: wObj));
                          } else {
                            var wObj = categoryArr[position] as Map? ?? {};
                            return Container(
                                margin: const EdgeInsets.only(right: 15),
                                width: MediaQuery.of(context).size.width * 0.25,
                                child: CategoryContainer(
                                    wObj: wObj,
                                    type: RoundButtonType.secondaryBG));
                          }
                        },
                        padding: EdgeInsets.zero,
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: categoryArr.length,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Đề xuất cho bữa ăn',
                      style: TextStyle(
                          color: AppColors.blackColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    recommendationArr.isEmpty
                        ? const Center(
                            child: Text(
                              'Không có đề xuất nào.',
                              style: TextStyle(
                                color: AppColors.grayColor,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : SizedBox(
                            height: MediaQuery.of(context).size.width > 450
                                ? MediaQuery.of(context).size.width * 0.60
                                : MediaQuery.of(context).size.width * 0.7,
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: ListView.builder(
                              itemBuilder: (context, position) {
                                if (position % 2 == 0) {
                                  var wObj =
                                      recommendationArr[position] as Map? ?? {};
                                  return Container(
                                      margin: const EdgeInsets.only(right: 15),
                                      width:
                                          MediaQuery.of(context).size.width >
                                                  400
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.45
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.55,
                                      child:
                                          RecommendationContainer(wObj: wObj));
                                } else {
                                  var wObj =
                                      recommendationArr[position] as Map? ?? {};
                                  return Container(
                                      margin: const EdgeInsets.only(right: 15),
                                      width:
                                          MediaQuery.of(context).size.width >
                                                  400
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.45
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.55,
                                      child: RecommendationContainer(
                                          wObj: wObj,
                                          type: RoundButtonType.secondaryBG));
                                }
                              },
                              padding: EdgeInsets.zero,
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: recommendationArr.length,
                            ),
                          ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Phổ biến',
                      style: TextStyle(
                          color: AppColors.blackColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.width *
                          0.25 *
                          widget.popularDishes.length,
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: ListView.builder(
                        itemBuilder: (context, position) {
                          var wObj =
                              widget.popularDishes[position] as Map? ?? {};
                          return Container(
                              margin: const EdgeInsets.all(5),
                              child: PopularContainer(wObj: wObj));
                        },
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: widget.popularDishes.length,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

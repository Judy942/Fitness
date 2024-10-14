import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/widgets/recommendation_container.dart';
import 'package:http/http.dart' as http;

import '../../../core/utils/app_colors.dart';
import '../../../widgets/category_container.dart';
import '../../../widgets/popular_container.dart';
import '../../../widgets/round_button.dart';
import '../../../widgets/search_bar.dart';
import '../../onboarding_screen/start_screen.dart';

Future<List> getRecommendation() async {
  String? token = await getToken(); // Giả định bạn đã định nghĩa hàm getToken()
  print(token);
  List recommendationArr = [];
  
  final response = await http.get(
    Uri.parse('http://162.248.102.236:8055/items/dish_recommendation?limit=25&fields=*,dish_id.*,dish_id.difficulty_id.*,dish_id.nutritions.*,dish_id.nutritions.nutrition_id.*&sort[]=sort&page=1&filter[status][_neq]=archived'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    
    // Lấy danh sách món ăn từ jsonResponse
    for (var item in jsonResponse['data']) {
      var dish = item['dish_id'];
      recommendationArr.add({
        'id': dish['id'],
        'name': dish['name'],
        'description': dish['description'],
        'cooking_time': dish['cooking_time'],
        'image': 'http://162.248.102.236:8055/assets/${dish['image']}',
        'difficulty': dish['difficulty_id']?['name'], // Thêm độ khó
        'nutritions': dish['nutritions'] // Thêm thông tin dinh dưỡng nếu cần
      });
    }
  } else {
    throw Exception('Failed to load recommendations: ${response.statusCode}');
  }

  return recommendationArr;
}

Future<List> getListPopular() async {
  String? token = await getToken(); 
  List popularArr = [];
  final response = await http.get(
    Uri.parse('http://162.248.102.236:8055/items/dish_popular?limit=25&fields=*,dish_id.*,dish_id.difficulty_id.*,dish_id.nutritions.*,dish_id.nutritions.nutrition_id.*&sort[]=sort&page=1&filter[status][_neq]=archived'),
        headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    
    // Lấy danh sách món ăn từ jsonResponse
    for (var item in jsonResponse['data']) {
      var dish = item['dish_id'];
      popularArr.add({
        'id': dish['id'],
        'name': dish['name'],
        'description': dish['description'],
        'cooking_time': dish['cooking_time'],
        'image': 'http://162.248.102.236:8055/assets/${dish['image']}',
        'difficulty_id': dish['difficulty_id'],
        'nutritions': dish['nutritions'] // Thêm thông tin dinh dưỡng nếu cần
      });
    }
  } else {
    throw Exception('Failed to load recommendations: ${response.statusCode}');
  }
  return popularArr;
}




class MealPlannerDetailScreen extends StatefulWidget {
  final String title;
  const MealPlannerDetailScreen({Key? key, required this.title})
      : super(key: key);

  @override
  State<MealPlannerDetailScreen> createState() =>
      _MealPlannerDetailScreenState();
}

class _MealPlannerDetailScreenState extends State<MealPlannerDetailScreen> {
  late String title;
    bool isLoading = true; // Biến để theo dõi trạng thái tải dữ liệu

  List categoryArr = [];

  
Future<void> getListCategory() async {
  String? token = await getToken(); // Giả định bạn đã định nghĩa hàm getToken()

  final response = await http.get(
    Uri.parse('http://162.248.102.236:8055/items/dish_category?filter[status][_neq]=archived'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    setState(() {
      categoryArr = (jsonResponse['data'] as List).map((item) {
        return {
          'id': item['id'],
          'image': 'http://162.248.102.236:8055/assets/${item['image']}',
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

  List recommendationArr = [];

  List popularArr = [];
  

  @override
  void initState() {
    super.initState();
    title = widget.title;
    getListCategory();
    getRecommendation().then((value) {
      setState(() {
        recommendationArr = value;
      });
    });
    getListPopular().then((value) {
      setState(() {
        popularArr = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
                    ? const Center(child: CircularProgressIndicator())
                    :Scaffold(
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
        title: Text(
          title,
          style: const TextStyle(
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
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: SingleChildScrollView(
            // physics: const AlwaysScrollableScrollPhysics(),
            // scrollDirection: Axis.vertical,
            // controller: ScrollController(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                const SearchBarRow(),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Category',
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
                                wObj: wObj, type: RoundButtonType.secondaryBG));
                      }
                    },
                    padding: EdgeInsets.zero,
                    // physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: categoryArr.length,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Recommendation for Diet',
                  style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(
                  height: 10,
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.width > 450 ? MediaQuery.of(context).size.width * 0.55 : MediaQuery.of(context).size.width * 0.65,
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: ListView.builder(
                    itemBuilder: (context, position) {
                      if (position % 2 == 0) {
                        var wObj = recommendationArr[position] as Map? ?? {};
                        return Container(
                            margin: const EdgeInsets.only(right: 15),
                            width: MediaQuery.of(context).size.width > 400 ? MediaQuery.of(context).size.width * 0.45 : MediaQuery.of(context).size.width * 0.55,
                            child: RecommendationContainer(wObj: wObj));
                      } else {
                        var wObj = recommendationArr[position] as Map? ?? {};
                        return Container(
                            margin: const EdgeInsets.only(right: 15),
                            width: MediaQuery.of(context).size.width > 400 ? MediaQuery.of(context).size.width * 0.45 : MediaQuery.of(context).size.width * 0.55,
                            child: RecommendationContainer(
                                wObj: wObj, type: RoundButtonType.secondaryBG));
                      }
                    },
                    padding: EdgeInsets.zero,
                    // physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: recommendationArr.length,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Popular',
                  style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.25*popularArr.length,
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: ListView.builder(

                    itemBuilder: (context, position) {
                      var wObj = popularArr[position] as Map? ?? {};
                      return Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          // width: MediaQuery.of(context).size.width * 0.9,
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
    );
  }
}

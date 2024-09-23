import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/widgets/recommendation_container.dart';

import '../../../core/utils/app_colors.dart';
import '../../../widgets/category_container.dart';
import '../../../widgets/popular_container.dart';
import '../../../widgets/round_button.dart';
import '../../../widgets/search_bar.dart';

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
  List<Map<String, String>> categoryArr = [
    {
      "name": "Salad",
      "image": "assets/images/salad.png",
    },
    {
      "name": "Cake",
      "image": "assets/images/cake.png",
    },
    {
      "name": "Pie",
      "image": "assets/images/pie.png",
    },
    {
      "name": "Smoothies",
      "image": "assets/images/orange.png",
    },
  ];

  List<Map<String, String>> recommendationArr = [
    {
      "name": "Honey Pancake",
      "image": "assets/images/cake.png",
      "difficulty": "Easy",
      "time": "30 mins",
      "calories": "180kCal",
    },
    {
      "name": "Canai Bread",
      "image": "assets/images/canai_bread.png",
      "difficulty": "Easy",
      "time": "20 mins",
      "calories": "200kCal",
    }
  ];

  List<Map<String, String>> popularArr = [
    {
      "name": "Blueberry Pancake",
      "image": "assets/images/blueberry_pancake.png",
      "difficulty": "Medium",
      "time": "30 mins",
      "calories": "180kCal",
    },
    {
      "name": "Salmon Nigiri",
      "image": "assets/images/salmon_nigiri.png",
      "difficulty": "Medium",
      "time": "30 mins",
      "calories": "180kCal",
    },
    {
      "name": "Canai Bread",
      "image": "assets/images/canai_bread.png",
      "difficulty": "Easy",
      "time": "20 mins",
      "calories": "200kCal",
    },
    {
      "name": "Honey Pancake",
      "image": "assets/images/cake.png",
      "difficulty": "Easy",
      "time": "30 mins",
      "calories": "180kCal",
    },
    
  ];

  @override
  void initState() {
    super.initState();
    title = widget.title;
  }

  @override
  Widget build(BuildContext context) {
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
                  height: MediaQuery.of(context).size.width > 400 ? MediaQuery.of(context).size.width * 0.5 : MediaQuery.of(context).size.width * 0.6,
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
                  width: MediaQuery.of(context).size.width * 0.9,
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

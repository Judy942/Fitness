import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../widgets/round_gradient_button.dart';
import '../../../widgets/step_detail_row.dart';

class MealDetailsScreen extends StatefulWidget {
  final Map dObj;
  const MealDetailsScreen({Key? key, required this.dObj}) : super(key: key);

  @override
  State<MealDetailsScreen> createState() => _MealDetailsScreenState();
}

class _MealDetailsScreenState extends State<MealDetailsScreen> {
  List nutritionArr = [
    {"image": "assets/images/fire.png", "title": "Calories", "value": "320"},
    {"image": "assets/images/protein.png", "title": "Protein", "value": "20g"},
    {"image": "assets/images/fat.png", "title": "Fat", "value": "10g"},
    {"image": "assets/images/carbs.png", "title": "Carbs", "value": "30g"},
  ];

  List ingredientsArr = [
    {
      "image": "assets/images/wheat_flour.png",
      "title": "Wheat Flour",
      "value": "100gr"
    },
    {"image": "assets/images/sugar.png", "title": "Sugar", "value": "3 tbsp"},
    {
      "image": "assets/images/baking_soda.png",
      "title": "Baking Soda",
      "value": "2 tsp"
    },
    {"image": "assets/images/eggs.png", "title": "Eggs", "value": "2 items"},
  ];

  List stepArr = [
    {
      "no": "01",
      "title": "Step 1",
      "detail":
          "Prepare all of the ingredients and utensils that needed to make the pancakes."
    },
    {
      "no": "02",
      "title": "Step 2",
      "detail": "Mix flour, sugar, salt, and baking soda in a large bowl."
    },
    {
      "no": "03",
      "title": "Step 3",
      "detail":
          "In a separate place, mix the eggs and liquid milk until blended."
    },
    {
      "no": "04",
      "title": "Step 4",
      "detail":
          "Pour the egg mixture into the flour mixture, stirring until smooth."
    },
    {
      "no": "05",
      "title": "Step 5",
      "detail":
          "Heat a non-stick skillet over medium heat, then pour the pancake batter into the skillet."
    },
    {
      "no": "06",
      "title": "Step 6",
      "detail":
          "Cook the pancakes until bubbles form on the surface, then flip them over and cook until golden brown."
    },
    {
      "no": "07",
      "title": "Step 7",
      "detail":
          "Serve the pancakes with syrup, butter, or fruit, and enjoy your meal!"
    },
  ];

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Container(
      decoration:
          BoxDecoration(gradient: LinearGradient(colors: AppColors.primary)),
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.transparent,
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
                      width: 15,
                      height: 15,
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              ],
            ),
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leadingWidth: 0,
              leading: Container(),
              expandedHeight: media.width * 0.4,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  color: AppColors.whiteColor.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  widget.dObj["image"].toString(),
                  width: media.width * 0.5,
                  height: media.width * 0.5,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ];
        },
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: const BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25), topRight: Radius.circular(25))),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 50,
                        height: 4,
                        decoration: BoxDecoration(
                            color: AppColors.grayColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(3)),
                      ),
                      SizedBox(
                        height: media.width * 0.05,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.dObj["name"].toString(),
                                  style: const TextStyle(
                                      color: AppColors.blackColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  "${widget.dObj["exercises"].toString()} | ${widget.dObj["time"].toString()} | 320 Calories Burn",
                                  style: const TextStyle(
                                      color: AppColors.grayColor, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Image.asset(
                              "assets/icons/fav_icon.png",
                              width: 15,
                              height: 15,
                              fit: BoxFit.contain,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: media.width * 0.05,
                      ),

                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Nutrition",
                            style: TextStyle(
                                color: AppColors.blackColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: nutritionArr.length,
                            itemBuilder: (context, index) {
                              var yObj = nutritionArr[index] as Map? ?? {};
                              return InkWell(
                                onTap: () {},
                                child: Container(
                                  margin: const EdgeInsets.only(right: 15),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                      color: AppColors.primaryColor1
                                          .withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        yObj["image"].toString(),
                                        width: 20,
                                        height: 20,
                                        fit: BoxFit.contain,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        "${yObj["value"].toString()} ${yObj["title"].toString()}",
                                        style: const TextStyle(
                                            color: AppColors.blackColor,
                                            fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ),
                      SizedBox(
                        height: media.width * 0.05,
                      ),
                      const Text(
                        "Descriptions",
                        style: TextStyle(
                            color: AppColors.blackColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      //description read more
                      const ReadMoreText(
                        "Pancakes are some people's favorite breakfast food. They are a type of flatbread that is made from a batter and cooked on a hot surface. Pancakes are usually served with syrup, butter, or fruit. They are a popular breakfast food in many countries around the world. Pancakes are a type of flatbread that is made from a batter and cooked on a hot surface. Pancakes are usually served with syrup, butter, or fruit. They are a popular breakfast food in many countries around the world.",
                        trimLines: 4,
                        colorClickableText: AppColors.blackColor,
                        trimMode: TrimMode.Line,
                        trimCollapsedText: ' Read More ...',
                        trimExpandedText: ' Read Less',
                        style: TextStyle(
                          color: AppColors.grayColor,
                          fontSize: 14,
                        ),
                        moreStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryColor1),
                        lessStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryColor1),
                      ),
                      SizedBox(
                        height: media.width * 0.05,
                      ),
                      const Text(
                        "Ingredients That You Will Need",
                        style: TextStyle(
                            color: AppColors.blackColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w700),
                      ),

                      SizedBox(
                        height: media.width * 0.4,
                        child: ListView.builder(
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: ingredientsArr.length,
                            itemBuilder: (context, index) {
                              var yObj = ingredientsArr[index] as Map? ?? {};
                              return Container(
                                margin: const EdgeInsets.only(bottom: 15),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: AppColors.lightGrayColor
                                        .withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                          color: AppColors.lightGrayColor,
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      child: Image.asset(
                                        yObj["image"].toString(),
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      yObj["title"].toString(),
                                      style: const TextStyle(
                                          color: AppColors.blackColor,
                                          fontSize: 16),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      yObj["value"].toString(),
                                      style: const TextStyle(
                                          color: AppColors.grayColor,
                                          fontSize: 14),
                                    ),
                                  ],
                                ),
                              );
                            }),
                      ),
                      SizedBox(
                        height: media.width * 0.03,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Step by Step",
                            style: TextStyle(
                                color: AppColors.blackColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w700),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "${stepArr.length} Steps",
                              style: const TextStyle(
                                  color: AppColors.grayColor, fontSize: 14),
                            ),
                          )
                        ],
                      ),
                      ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: stepArr.length,
                        itemBuilder: ((context, index) {
                          var sObj = stepArr[index] as Map? ?? {};

                          return StepDetailRow(
                            sObj: sObj,
                            isLast: stepArr.last == sObj,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      RoundGradientButton(
                          title: "Add to Breakfast Meal", onPressed: () {})
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

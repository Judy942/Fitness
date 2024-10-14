import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:readmore/readmore.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../widgets/round_gradient_button.dart';
import '../../../widgets/step_detail_row.dart';
import '../../onboarding_screen/start_screen.dart';
import '../meal_schedule/add_meal_schedule.dart';

Future<Map<String, dynamic>> getDishDetails(int id) async {
  String url =
      'http://162.248.102.236:8055/items/dish/$id?fields=*,difficulty_id.*,nutritions.*,nutritions.nutrition_id.*,ingredients.*,ingredients.ingredient_id.*,process_steps.*&filter[status][_neq]=archived';

  Map<String, dynamic> dishDetails = {};
  String? token = await getToken(); // Giả định bạn đã định nghĩa hàm getToken()

  try {
    var response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      dishDetails = jsonResponse['data']; // Trả về dữ liệu
    } else {
      throw Exception('Failed to load dish details: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching dish details: $e');
  }

  return dishDetails; // Trả về thông tin món ăn
}

class MealDetailsScreen extends StatefulWidget {
  final Map dObj;
  const MealDetailsScreen({Key? key, required this.dObj}) : super(key: key);

  @override
  State<MealDetailsScreen> createState() => _MealDetailsScreenState();
}

class _MealDetailsScreenState extends State<MealDetailsScreen> {
  Map<String, dynamic> dishDetails = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getDishDetails(widget.dObj["id"]).then((value) {
      setState(() {
        dishDetails = value;
        print(dishDetails);
        isLoading = false;
      });
    });
  }

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
                child: Image.network(
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
                  child: isLoading
                      ? const LinearProgressIndicator()
                      : Column(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.dObj["name"].toString(),
                                        style: const TextStyle(
                                            color: AppColors.blackColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Text(
                                        "${widget.dObj["cooking_time"].toString()}hours | ${widget.dObj["nutritions"][0]['value']} Kcal",
                                        style: const TextStyle(
                                            color: AppColors.grayColor,
                                            fontSize: 12),
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
                                  itemCount: dishDetails["nutritions"].length,
                                  itemBuilder: (context, index) {
                                    var yObj = dishDetails["nutritions"][index]
                                            as Map? ??
                                        {};
                                    return InkWell(
                                      onTap: () {},
                                      child: Container(
                                        margin:
                                            const EdgeInsets.only(right: 15),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                            color: AppColors.primaryColor1
                                                .withOpacity(0.3),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Row(
                                          children: [
                                            // Image.asset(
                                            //   yObj["image"].toString(),
                                            //   width: 20,
                                            //   height: 20,
                                            //   fit: BoxFit.contain,
                                            // ),

                                            Image.network(
                                              'http://162.248.102.236:8055/assets/${yObj["nutrition_id"]["image"].toString()}',
                                              width: 20,
                                              height: 20,
                                              fit: BoxFit.contain,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              "${yObj["value"].toString()} ${yObj["unit"].toString()}",
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
                            ReadMoreText(
                              dishDetails["description"].toString(),
                              trimLines: 2,
                              colorClickableText: AppColors.blackColor,
                              trimMode: TrimMode.Line,
                              trimCollapsedText: ' Read More ...',
                              trimExpandedText: ' Read Less',
                              style: const TextStyle(
                                color: AppColors.grayColor,
                                fontSize: 14,
                              ),
                              moreStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryColor1),
                              lessStyle: const TextStyle(
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
                              height: media.width * 0.5,
                              child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount: dishDetails["ingredients"].length,
                                  itemBuilder: (context, index) {
                                    var yObj = dishDetails["ingredients"][index]
                                            as Map? ??
                                        {};
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 15),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          color: AppColors.lightGrayColor
                                              .withOpacity(0.3),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                                color: AppColors.lightGrayColor,
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                            // child: Image.asset(
                                            //   yObj["image"].toString(),
                                            //   width: 50,
                                            //   height: 50,
                                            //   fit: BoxFit.contain,
                                            // ),
                                            child: Image.network(
                                              'http://162.248.102.236:8055/assets/${yObj["ingredient_id"]["image"].toString()}',
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            yObj['ingredient_id']["name"]
                                                .toString(),
                                            style: const TextStyle(
                                                color: AppColors.blackColor,
                                                fontSize: 15),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            "${yObj["value"]} ${yObj["unit"]}",
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
                                    "${dishDetails["process_steps"].length} Steps",
                                    style: const TextStyle(
                                        color: AppColors.grayColor,
                                        fontSize: 14),
                                  ),
                                )
                              ],
                            ),
                            ListView.builder(
                              padding: const EdgeInsets.only(bottom: 80),
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: dishDetails["process_steps"].length,
                              itemBuilder: ((context, index) {
                                var sObj = dishDetails["process_steps"][index]
                                        as Map? ??
                                    {};

                                return StepDetailRow(
                                  sObj: sObj,
                                  isLast:
                                      dishDetails["process_steps"].last == sObj,
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
                          title: "Add to Meal",
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddMealSchedule(
                                          date: DateTime.now(),
                                        )));
                          })
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

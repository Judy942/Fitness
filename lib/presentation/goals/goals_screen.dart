import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/presentation/welcome/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/app_colors.dart';
import '../../widgets/round_gradient_button.dart';

Future<void> setGoal(String goal) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('goal', goal);
}

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({Key? key}) : super(key: key);

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  List pageList = [
    {
      "title": "Cải thiện vóc dáng",
      "subtitle":
          "Tôi có lượng mỡ thấp\nvà cần / muốn xây dựng\nthêm cơ bắp",
      "image": "assets/images/goal_1.png"
    },
    {
      "title": "Gọn gàng & Săn chắc",
      "subtitle":
          "Tôi là người 'gầy nhưng có mỡ'. Trông gầy nhưng\nkhông có hình dáng. Tôi muốn tăng cơ\nđúng cách",
      "image": "assets/images/goal_2.png"
    },
    {
      "title": "Giảm mỡ",
      "subtitle":
          "Tôi cần giảm hơn 9kg. Tôi muốn\ngiảm hết mỡ và tăng\ncơ bắp",
      "image": "assets/images/goal_3.png"
    }
  ];
  CarouselSliderController? carouselController = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    String goal = "";
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: CarouselSlider(
                items: pageList
                    .map((obj) => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            gradient: LinearGradient(
                                colors: AppColors.primary,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight),
                          ),
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                              vertical: media.width * 0.01, horizontal: 25),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  obj["image"],
                                  width: media.width * 0.5,
                                  fit: BoxFit.cover,
                                ),
                                SizedBox(height: media.width * 0.02),
                                Text(
                                  obj["title"],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.whiteColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: media.width * 0.01),
                                Container(
                                  width: 50,
                                  height: 1,
                                  color: AppColors.lightGrayColor,
                                ),
                                SizedBox(height: media.width * 0.02),
                                Text(
                                  obj["subtitle"],
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  maxLines: 3,
                                  style: const TextStyle(
                                    color: AppColors.whiteColor,
                                    fontSize: 12,
                                    fontFamily: "Poppins",
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
                carouselController: carouselController,
                options: CarouselOptions(
                  autoPlay: false,
                  enlargeCenterPage: true,
                  viewportFraction: 0.7,
                  aspectRatio: 0.74,
                  initialPage: 0,
                  onPageChanged: (index, reason) => {
                    setState(() {
                      goal = pageList[index]["title"];
                    })
                  },
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: SizedBox(
                width: media.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(
                      "Mục tiêu của bạn là gì?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Điều này sẽ giúp chúng tôi chọn\nchương trình tốt nhất cho bạn",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.grayColor,
                        fontSize: 12,
                        fontFamily: "Poppins",
                      ),
                    ),
                    const Spacer(),
                    SizedBox(height: media.width * 0.05),
                    RoundGradientButton(
                      title: "Xác nhận",
                      onPressed: () {
                        setGoal(goal);
                        // Navigator.pushReplacementNamed(
                        //     context, AppRoutes.welcomeScreen);
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) {
                          return const WelcomeScreen();
                        }));
                      },
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

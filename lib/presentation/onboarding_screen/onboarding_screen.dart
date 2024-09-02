import 'package:flutter/material.dart';

import '../../core/utils/app_colors.dart';
import 'page_widget.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();

}

class _OnboardingScreenState extends State<OnboardingScreen>{
  PageController pageController = PageController();

  List pages = [
    {
      "title": "Track Your Goal",
      "subtitle":
          "Don't worry if you have trouble determining your goals, We can help you determine your goals and track your goals",
      "image": "assets/images/on_board1.png"
    },
    {
      "title": "Get Burn",
      "subtitle":
          "Let’s keep burning, to achive yours goals, it hurts only temporarily, if you give up now you will be in pain forever",
      "image": "assets/images/on_board2.png"
    },
    {
      "title": "Eat Well",
      "subtitle":
          "Let's start a healthy lifestyle with us, we can determine your diet every day. healthy eating is fun",
      "image": "assets/images/on_board3.png"
    },
    {
      "title": "Improve Sleep Quality",
      "subtitle":
          "Improve the quality of your sleep with us, good quality sleep can bring a good mood in the morning",
      "image": "assets/images/on_board4.png"
    }
  ];
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Stack(
        alignment: Alignment.bottomRight,
        children: [
          PageView.builder(
            itemCount: pages.length,
            controller: pageController,
            onPageChanged: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
            itemBuilder: (context, index) {
              var page = pages[index];
              return PageWidget(obj: page);
                
            },
            

          ),
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor1,
                    value: (selectedIndex + 1) / pages.length,
                    strokeWidth: 3,
                  ),
                ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  color: AppColors.primaryColor1,

                  ),
                  child: IconButton(
                    onPressed: () {
                      if (selectedIndex == pages.length - 1) {
                        Navigator.pushReplacementNamed(context, "/loginScreen");
                      } else {
                        selectedIndex =selectedIndex + 1;
                        pageController.animateToPage(selectedIndex, duration: const Duration(milliseconds: 300), curve: Curves.easeInSine);
                      }
                    },
                    icon: const Icon(
                      Icons.arrow_forward,
                      color: AppColors.whiteColor,
                    ),
                ),
              ),
              ],
            )
          ),
        ]

      )
    );
  }
 

}
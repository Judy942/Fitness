import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/presentation/login/login_screen.dart';

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
      "title": "Theo dõi mục tiêu",
      "subtitle":
          "Đừng lo lắng nếu bạn gặp khó khăn trong việc xác định mục tiêu. Chúng tôi có thể giúp bạn xác định và theo dõi mục tiêu của mình",
      "image": "assets/images/on_board1.png"
    },
    {
      "title": "Đốt cháy calo",
      "subtitle":
          "Hãy tiếp tục đốt cháy để đạt được mục tiêu của bạn. Đau đớn chỉ là tạm thời, nếu bạn bỏ cuộc bây giờ, bạn sẽ đau đớn mãi mãi",
      "image": "assets/images/on_board2.png"
    },
    {
      "title": "Ăn uống lành mạnh",
      "subtitle":
          "Hãy bắt đầu lối sống lành mạnh với chúng tôi. Chúng tôi có thể xác định chế độ ăn của bạn mỗi ngày. Ăn uống lành mạnh thật thú vị",
      "image": "assets/images/on_board3.png"
    },
    {
      "title": "Cải thiện chất lượng giấc ngủ",
      "subtitle":
          "Cải thiện chất lượng giấc ngủ của bạn với chúng tôi. Giấc ngủ chất lượng tốt có thể mang lại tâm trạng tốt vào buổi sáng",
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
                        // Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                          return const LoginScreen();
                        }));
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
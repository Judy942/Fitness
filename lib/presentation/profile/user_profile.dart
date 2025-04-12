import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/app_colors.dart';
import '../../widgets/round_button.dart';
import '../../widgets/setting_row.dart';
import '../../widgets/title_cell.dart';
import '../home/home_screen.dart';
import '../login/login_screen.dart';
import '../meal_planner/meal_history/meal_history_screen.dart';
import '../workout/workout_history/workout_history_screen.dart';
import 'complete_profile_screen.dart';

Future<void> logout(BuildContext context) async {
  try {
    // Clear the locally stored token
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // Redirect to Login Screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  } catch (e) {
    // Handle errors gracefully
    print("Error during logout: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error occurred during logout')),
    );
  }
}

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  Map<String, dynamic> userData = {};
  @override
  void initState() {
    super.initState();
    getUserData().then((data) {
      setState(() {
        userData = data;
      });
    });
  }

  Future<void> handleLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Xóa tất cả thông tin lưu trữ
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false, // Xóa toàn bộ stack điều hướng
    );
  }

  bool positive = false;

  List accountArr = [
    {
      "image": "assets/icons/p_personal.png",
      "name": "Lịch sử tập luyện",
      "tag": "1",
      "action": (BuildContext context) => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const WorkoutHistoryScreen(),
            ),
          ),
    },
    {
      "image": "assets/icons/p_achi.png",
      "name": "Lịch sử bữa ăn",
      "tag": "2",
      "action": (BuildContext context) => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MealHistoryScreen(),
            ),
          ),
    },
    {
      "image": "assets/icons/p_activity.png",
      "name": "Lịch sử hoạt động",
      "tag": "3"
    },
    {
      "image": "assets/icons/p_workout.png",
      "name": "Workout Progress",
      "tag": "4"
    }
  ];

  List otherArr = [
    {"image": "assets/icons/p_contact.png", "name": "Contact Us", "tag": "5"},
    {
      "image": "assets/icons/p_privacy.png",
      "name": "Privacy Policy",
      "tag": "6"
    },
    {"image": "assets/icons/p_setting.png", "name": "Setting", "tag": "7"},
    {
      "image": "assets/icons/p_personal.png",
      "name": "Logout",
      "tag": "8",
      "action": (BuildContext context) => showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Confirm Logout"),
              content: const Text("Are you sure you want to log out?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context), // Close the dialog
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog

                    final state =
                        context.findAncestorStateOfType<_UserProfileState>();
                    state?.handleLogout();
                    logout(context);
                  },
                  child: const Text("Logout"),
                ),
              ],
            ),
          ),
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.asset(
                      "assets/images/user.png",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData['last_name'] ?? "you",
                          // allData['last_name'] ?? "you",
                          style: const TextStyle(
                            color: AppColors.blackColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    height: 25,
                    child: RoundButton(
                      title: "Edit",
                      type: RoundButtonType.primaryBG,
                      onPressed: () async {
                        final result = await Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CompleteProfileScreen(isBackToProfile: true),
                          ),
                        );
                        // Kiểm tra xem có giá trị trả về không
                        if (result != null) {
                          getUserData().then((data) {
                            setState(() {
                              userData = data;
                            });
                          });
                        }
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Expanded(
                    child: TitleSubtitleCell(
                      title: userData['height'].toString(),
                      subtitle: "Height",
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: TitleSubtitleCell(
                      title: userData['weight'].toString(),
                      subtitle: "Weight",
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: TitleSubtitleCell(
                      //now-usetData['birthday']
                      title: userData['birthday'] ?? "0",
                      subtitle: "birthday",
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 2)
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Account",
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: accountArr.length,
                      itemBuilder: (context, index) {
                        var iObj = accountArr[index] as Map? ?? {};
                        return SettingRow(
                          icon: iObj["image"].toString(),
                          title: iObj["name"].toString(),
                          onPressed: () {
                            if (iObj["action"] != null) {
                              iObj["action"](context);
                            }
                          },
                        );
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 2)
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Notification",
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    SizedBox(
                      height: 30,
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset("assets/icons/p_notification.png",
                                height: 15, width: 15, fit: BoxFit.contain),
                            const SizedBox(
                              width: 15,
                            ),
                            const Expanded(
                              child: Text(
                                "Pop-up Notification",
                                style: TextStyle(
                                  color: AppColors.blackColor,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            CustomAnimatedToggleSwitch<bool>(
                              current: positive,
                              values: const [false, true],
                              indicatorSize: const Size.square(30.0),
                              animationDuration:
                                  const Duration(milliseconds: 200),
                              animationCurve: Curves.linear,
                              onChanged: (b) => setState(() => positive = b),
                              iconBuilder: (context, local, global) {
                                return const SizedBox();
                              },
                              onTap: (b) =>
                                  setState(() => positive = !positive),
                              iconsTappable: false,
                              wrapperBuilder: (context, global, child) {
                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Positioned(
                                        left: 10.0,
                                        right: 10.0,
                                        height: 30.0,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              // colors: AppColors.secondary
                                              colors: positive
                                                  ? AppColors.secondary
                                                  : [
                                                      AppColors.grayColor,
                                                      AppColors.grayColor
                                                    ],
                                            ),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(30.0)),
                                          ),
                                        )),
                                    child,
                                  ],
                                );
                              },
                              foregroundIndicatorBuilder: (context, global) {
                                return SizedBox.fromSize(
                                  size: const Size(10, 10),
                                  child: const DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: AppColors.whiteColor,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(50.0)),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black38,
                                            spreadRadius: 0.05,
                                            blurRadius: 1.1,
                                            offset: Offset(0.0, 0.8))
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ]),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 2)
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Other",
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: otherArr.length,
                      itemBuilder: (context, index) {
                        var iObj = otherArr[index] as Map? ?? {};
                        return SettingRow(
                          icon: iObj["image"].toString(),
                          title: iObj["name"].toString(),
                          onPressed: () {
                            if (iObj["action"] != null) {
                              iObj["action"](
                                  context); // Pass only the context as expected
                            }
                          },
                        );
                      },
                    ),

                    // ListView.builder(
                    //   physics: const NeverScrollableScrollPhysics(),
                    //   padding: EdgeInsets.zero,
                    //   shrinkWrap: true,
                    //   itemCount: otherArr.length,
                    //   itemBuilder: (context, index) {
                    //     var iObj = otherArr[index] as Map? ?? {};
                    //     return SettingRow(
                    //       icon: iObj["image"].toString(),
                    //       title: iObj["name"].toString(),
                    //       onPressed: () {
                    //         if (iObj["action"] != null) {
                    //           iObj["action"](context);
                    //         }
                    //       },
                    //     );
                    //   },
                    // )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

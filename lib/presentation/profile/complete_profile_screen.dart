import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/app_colors.dart';
import '../../widgets/round_gradient_button.dart';
import '../../widgets/round_textfield.dart';
import '../onboarding_screen/start_screen.dart';
import 'user_profile.dart';

// Future<Map<String, dynamic>> getUserData() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   return {
//     'first_name': prefs.getString('first_name') ?? '',
//     'last_name': prefs.getString('last_name') ?? '',
//     'email': prefs.getString('email') ?? '',
//     'height': prefs.getDouble('height') ?? 0.0,
//     'weight': prefs.getDouble('weight') ?? 0.0,
//     'birthday': prefs.getString('birthday') ?? '',
//     'gender': prefs.getString('gender') ?? '',
//   };
// }

class CompleteProfileScreen extends StatefulWidget {
  bool isBackToProfile;
  CompleteProfileScreen({Key? key, required this.isBackToProfile})
      : super(key: key);

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  Map<String, dynamic> allData = {};

  @override
  void initState() {
    super.initState();
    allUserData.then((value) {
      allData = value;
      print('giá trị alldata$allData');
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(right: 15, left: 15),
            child: Column(
              children: [
                InkWell(
                  child: const Icon(Icons.arrow_back_ios),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                Image.asset("assets/images/complete_profile.png",
                    width: media.width),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  "Let’s complete your profile",
                  style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 5),
                const Text(
                  "It will help us to know more about you!",
                  style: TextStyle(
                    color: AppColors.grayColor,
                    fontSize: 12,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 25),
                Container(
                  decoration: BoxDecoration(
                      color: AppColors.lightGrayColor,
                      borderRadius: BorderRadius.circular(15)),
                  child: Row(
                    children: [
                      Container(
                          alignment: Alignment.center,
                          width: 50,
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Image.asset(
                            "assets/icons/gender_icon.png",
                            width: 20,
                            height: 20,
                            fit: BoxFit.contain,
                            color: AppColors.grayColor,
                          )),
                      Expanded(
                          child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          items: ["Male", "Female"]
                              .map((name) => DropdownMenuItem(
                                  value: name,
                                  child: Text(
                                    name,
                                    style: const TextStyle(
                                        color: AppColors.grayColor,
                                        fontSize: 14),
                                  )))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              // usetData['gender'] = value;
                              SharedPreferences.getInstance().then((prefs) {
                                prefs.setString('gender', value!);
                              });
                            });
                          },
                          isExpanded: true,
                          hint: Text(allData['gender'] ?? '',

                              // usetData['gender'] ?? '',
                              style: const TextStyle(
                                  color: AppColors.grayColor, fontSize: 12)),
                        ),
                      )),
                      const SizedBox(
                        width: 8,
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                RoundTextField(
                  onChanged: (p0) {
                    setState(() {
                      // usetData['birthday'] = p0;
                      SharedPreferences.getInstance().then((prefs) {
                        prefs.setString('birthday', p0);
                      });
                    });
                  },
                  hintText: allData['birthday'] ?? '',
                  //  usetData['birthday'] ?? "Your Birthday",
                  icon: "assets/icons/calendar_icon.png",
                  textInputType: TextInputType.datetime,
                ),
                const SizedBox(height: 15),
                RoundTextField(
                  onChanged: (p0) {
                    // usetData['weight'] = p0;
                    SharedPreferences.getInstance().then((prefs) {
                      prefs.setString('weight', p0);
                    });
                  },
                  hintText: allData['weight'] ?? '',
                  //  usetData['weight'] == 0.0
                  //     ? "Your Weight"
                  //     : usetData['weight'].toString(),
                  icon: "assets/icons/weight_icon.png",
                  textInputType: TextInputType.text,
                ),
                const SizedBox(height: 15),
                RoundTextField(
                  onChanged: (p0) {
                    // usetData['height'] = p0;
                    SharedPreferences.getInstance().then((prefs) {
                      prefs.setString('height', p0);
                    });
                  },
                  hintText: allData['height'] ?? '',
                  //  usetData['height'] == 0.0
                  //     ? "Your Height"
                  //     : usetData['height'].toString(),
                  icon: "assets/icons/swap_icon.png",
                  textInputType: TextInputType.text,
                ),
                const SizedBox(height: 15),
                RoundGradientButton(
                  title: "Next >",
                  onPressed: () async {
                    // save data to server
                    String? token = await getToken();
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    try {
                      final response = await http.patch(
                        Uri.parse('http://162.248.102.236:8055/users/me'),
                        headers: {'Authorization': 'Bearer $token'},
                        body: {
                          'first_name': prefs.getString('first_name') ?? '',
                          'last_name': prefs.getString('last_name') ?? '',
                          'email': prefs.getString('email') ?? '',
                          'height': prefs.getString('height') ?? '',
                          'weight': prefs.getString('weight') ?? '',
                          'birthday': prefs.getString('birthday') ?? '',
                          'gender': prefs.getString('gender') ?? '',
                        },
                      );
                      if (response.statusCode == 200) {
                        if (widget.isBackToProfile) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushNamed(context, '/goalsScreen');
                        }
                      } else {
                        print(response.body);
                      }
                    } catch (e) {
                      print(e);
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

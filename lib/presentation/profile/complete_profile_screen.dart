import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/utils/app_colors.dart';
import '../../widgets/round_gradient_button.dart';
import '../../widgets/round_textfield.dart';
import '../home/home_screen.dart';
import '../onboarding_screen/start_screen.dart';

class CompleteProfileScreen extends StatefulWidget {
  bool isBackToProfile;
  CompleteProfileScreen({Key? key, required this.isBackToProfile})
      : super(key: key);

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  Map<String, dynamic> userData = {};
  Future<void> updateUserData(Map<String, String> data) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await getToken();
    try {
    String json = jsonEncode(data);
    print(json);
      final response = await http.patch(
          Uri.parse('http://162.248.102.236:8055/users/me'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          },
          body: json);
      if (response.statusCode == 200) {
        print('Update user data success');
        print(response.body);
        if (widget.isBackToProfile) {
          Navigator.pop(context, true);
        } else {
          Navigator.pushNamed(context, '/goalsScreen');
        }
      } else {
        print(response.body);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData().then((data) {
      setState(() {
        userData = data;
      });
    });
  }

  // Future<void> loadUserData() async {
  //   allData = await getAllData() as Map<String, dynamic>;
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
        // final prefsNotifier = Provider.of<PreferencesNotifier>(context);
        // Map<String, dynamic> usetData = prefsNotifier.userData;
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
                            userData['gender'] = value!.toUpperCase();
                            setState(() {});
                          },
                          isExpanded: true,
                          hint: Text(userData['gender'] ?? (userData['gender'] == 'null'? 'Choose Gender': 'Choose gender'),

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
                    userData['birthday'] = p0;
                    setState(() {
                      
                    });
                  },
                  hintText: 
                   userData['birthday'] ?? (userData['birthday'] == 'null'? 'dd/mm/yyyy': 'dd/mm/yyyy'),
                  icon: "assets/icons/calendar_icon.png",
                  textInputType: TextInputType.datetime,
                ),
                const SizedBox(height: 15),
                RoundTextField(
                  onChanged: (p0) {
                    userData['weight'] = p0;
                    setState(() {});
                  },
                  hintText: userData['weight'].toString(),
                  icon: "assets/icons/weight_icon.png",
                  textInputType: TextInputType.text,
                ),
                const SizedBox(height: 15),
                RoundTextField(
                  onChanged: (p0) {
                    userData['height'] = p0;
                    setState(() {});
                  },
                  hintText: userData['height'].toString(),
                  icon: "assets/icons/swap_icon.png",
                  textInputType: TextInputType.text,
                ),
                const SizedBox(height: 15),
                RoundGradientButton(
                  title: "Next >",
                  onPressed: () {
                    Map<String, String> data = {
                      // 'first_name': usetData['first_name'],
                      // 'last_name': usetData['last_name'],
                      'gender': userData['gender'],
                      'height': userData['height'].toString(),
                      'weight': userData['weight'].toString(),
                      //chuyển data về dạng yyyy-mm-dd
                      'birthday': userData['birthday']

                    };
                    updateUserData(
                      data,
                    );
                    //  prefsNotifier.updateUserData('gender', data['gender']);
                    //  prefsNotifier.updateUserData('birthday', data['birthday']);
                    //   prefsNotifier.updateUserData('weight', data['weight']);
                    //   prefsNotifier.updateUserData('height', data['height']);
                      
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

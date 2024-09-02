import 'package:customevetedbutton/customevetedbutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/core/utils/size_utils.dart';
import 'package:flutter_application_fitness/localization/app_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../theme/custom_button_styles.dart';
import '../../theme/custom_text_styles.dart';
import '../../theme/theme_helper.dart';
import 'bloc/welcome_screen_one_bloc.dart';
import 'models/welcome_screen_one_model.dart';


class WelcomeScreenOneScreen extends StatelessWidget {
  const WelcomeScreenOneScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return BlocProvider<WelcomeScreenOneBloc>(
      create: (context) => WelcomeScreenOneBloc(WelcomeScreenOneState(welcomeScreenOneModelObj: const WelcomeScreenOneModel()))
      ..add(WelcomeScreenOneInitialEvent()),
      child: const WelcomeScreenOneScreen(),
    );
  }

@override
Widget build(BuildContext context) {
    return BlocBuilder<WelcomeScreenOneBloc, WelcomeScreenOneState>(
      builder: (context, state) {
        return SafeArea(
          child: Scaffold(
            body: Container(
              width: double.maxFinite,
              padding: EdgeInsets.symmetric(
              horizontal: 30.h,
              vertical: 260.h),
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 96.h,
                ),
                // _buildHeaderSection(context),
                SizedBox(
      width: double.maxFinite,
      child: Column(
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Fitness".tr,
                  style: theme.textTheme.displaySmall,
                ),
                // TextSpan(
                //   text: "lbl_s".tr,
                //   style: theme.textTheme.displaySmall,

                // ),
                TextSpan(
                  text: "x".tr,
                  style: theme.textTheme.displayMedium,
                ),

              ],
              
          ),

          textAlign: TextAlign.left,
        
      ),

      Text(
        "Everybody Can Train".tr,
        style: CustomTextStyles.bodyLargeErrorContainer,
      ),
    ],
  ),
                )
              ],
            ),
            ),
            bottomNavigationBar: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCtaButton(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Fitness".tr,
                  style: theme.textTheme.displaySmall,
                ),
                // TextSpan(
                //   text: "lbl_s".tr,
                //   style: theme.textTheme.displaySmall,

                // ),
                TextSpan(
                  text: "x".tr,
                  style: theme.textTheme.displayMedium,
                ),

              ],
              
          ),

          textAlign: TextAlign.left,
        
      ),

      Text(
        "Everybody Can Train".tr,
        style: CustomTextStyles.bodyLargeErrorContainer,
      ),
    ],
  ),
    );

  }

  Widget _buildCtaButton(BuildContext context) {
    return CustomElevatedButton(
      text: "Get Started".tr,

      margin: EdgeInsets.only(
        bottom: 40.h,
        left: 30.h,
        right: 30.h,
      ),

      buttonStyle: CustomButtonStyles.none,
      decoration: CustomButtonStyles.gradientPrimaryToBlueDecoration,
    );
  }
  
}
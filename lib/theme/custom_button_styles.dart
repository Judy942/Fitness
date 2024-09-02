import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/core/utils/size_utils.dart';
import 'package:flutter_application_fitness/theme/theme_helper.dart';


class CustomButtonStyles {
  static BoxDecoration get gradientPrimaryToBlueDecoration => BoxDecoration(
        borderRadius: BorderRadius.circular(30.h),
        boxShadow: [
          BoxShadow(
            color: appTheme.indigoA1004c,
            spreadRadius: 2.h,
            blurRadius: 2.h,
            offset: const Offset(0, 10,
            ),
          ),

        ],

        gradient: LinearGradient(colors: [
          theme.colorScheme.primary,
          appTheme.blue20001,
        ]),
      );

  static ButtonStyle get none => ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
        elevation: WidgetStateProperty.all<double>(0),
        side : WidgetStateProperty.all<BorderSide>(const BorderSide(color: Colors.transparent)),

      );


}
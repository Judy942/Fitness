// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/core/utils/size_utils.dart';
import 'package:flutter_application_fitness/theme/theme_helper.dart';

extension on TextStyle {
  TextStyle get inter {
    return copyWith(
      fontFamily: 'Inter',
    );
  }

  TextStyle get poppins {
    return copyWith(
      fontFamily: 'Poppins',
    );
  }
}

class CustomTextStyles{
  static get bodyLargeErrorContainer => theme.textTheme.bodyLarge!.copyWith(
    color: theme.colorScheme.errorContainer.withOpacity(1),
    fontSize: 18.fSize,
  );

}
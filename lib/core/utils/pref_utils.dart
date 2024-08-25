// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:ui';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefUtils {
  PrefUtils(){
    SharedPreferences.getInstance().then((prefs) {
      _sharedPreferences = prefs;
    });
  }


SharedPreferences? _sharedPreferences;

Future<void> init() async {
  _sharedPreferences ??= await SharedPreferences.getInstance();
  print('Shared Preferences Initialized');

}

void clearPreferencesData() async {
  _sharedPreferences!.clear();
}

Future<void> setThemeData(String themeType) {
  return _sharedPreferences!.setString('themeData', themeType);
}

String getThemeData() {
  try {
    return _sharedPreferences!.getString('themeData')!;
  } catch (e) {
    return 'primary';
  }
}


}


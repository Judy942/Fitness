import 'package:flutter/material.dart';

class NavigatorService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  static Future<dynamic> pushNamed(String routeName, {dynamic arguments}) async {
    return navigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
  }
  static void goBack() {
  return navigatorKey.currentState?.pop();
  }


}


import 'package:flutter/material.dart';

class AppRoutes {
  static const String initialRoute = '/initialRoute';

  static Map<String, WidgetBuilder> get routes => {
    initialRoute: (context) => Container(),
  };
}
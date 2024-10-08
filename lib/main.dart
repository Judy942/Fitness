import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_fitness/core/utils/navigator_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/utils/pref_utils.dart';
import 'core/utils/size_utils.dart';
import 'localization/app_localization.dart';
import 'routes/app_routes.dart';
import 'theme/bloc/theme_bloc.dart';

var golobalMessage = GlobalKey<ScaffoldMessengerState>();
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
  ]).then((value) {
    PrefUtils().init();
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return BlocProvider(
          create: (context) => ThemeBloc(
            ThemeState(
              themeType: PrefUtils().getThemeData(),
            ),
          ),

          child: BlocBuilder<ThemeBloc, ThemeState>(builder: (context, state) {
            return MaterialApp(
              title: "my app",
              navigatorKey: NavigatorService.navigatorKey,
              debugShowCheckedModeBanner: false,
              localizationsDelegates: const [
                AppLocalizationDelegate(),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', ''),
              ],
              initialRoute: AppRoutes.initialRoute,
              routes: AppRoutes.routes,
            );
          },)
        );
      },
    );
}
}
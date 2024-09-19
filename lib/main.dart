

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_fitness/core/utils/navigator_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/utils/pref_utils.dart';
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
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
          // initialRoute: AppRoutes.startScreen,
          initialRoute: AppRoutes.mealPlannerDetailScreen,
          routes: AppRoutes.routes,
        );
      },)
    );
}
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_fitness/core/utils/navigator_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/utils/pref_utils.dart';
import 'localization/app_localization.dart';
import 'routes/app_routes.dart';
import 'theme/bloc/theme_bloc.dart';
import 'package:provider/provider.dart';

class PreferencesNotifier extends ChangeNotifier {
  Map<String, dynamic> _userData = {};

  Map<String, dynamic> get userData => _userData;

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userData = {};
    for (String key in prefs.getKeys()) {
      _userData[key] = prefs.get(key);
    }
    notifyListeners(); // Thông báo rằng dữ liệu đã thay đổi
  }

  Future<void> updateUserData(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value.toString());
    await loadUserData(); // Tải lại dữ liệu
  }
}

var golobalMessage = GlobalKey<ScaffoldMessengerState>();
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
  ]).then((value) {
    PrefUtils().init();
    runApp(
      ChangeNotifierProvider(
      create: (context) => PreferencesNotifier()..loadUserData(),
      child: const MyApp(),
    ),
    );
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
          initialRoute: AppRoutes.startScreen,
          // initialRoute: AppRoutes.mealScheduleScreen,
          routes: AppRoutes.routes,
        );
      },)
    );
}
}
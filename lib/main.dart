<<<<<<< Updated upstream
<<<<<<< Updated upstream
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_fitness/core/utils/navigator_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
=======
=======
>>>>>>> Stashed changes
import 'package:email_otp/email_otp.dart';
import "package:flutter/material.dart";
import "package:flutter_application_fitness/chat_box/consts.dart";
import "package:flutter_application_fitness/presentation/dashboard/dashboard_screen.dart";
import "package:flutter_application_fitness/presentation/onboarding_screen/start_screen.dart";
import "package:flutter_gemini/flutter_gemini.dart";
>>>>>>> Stashed changes

import 'core/utils/pref_utils.dart';
import 'core/utils/size_utils.dart';
import 'localization/app_localization.dart';
import 'routes/app_routes.dart';
import 'theme/bloc/theme_bloc.dart';

var golobalMessage = GlobalKey<ScaffoldMessengerState>();
void main() {
<<<<<<< Updated upstream
<<<<<<< Updated upstream
  WidgetsFlutterBinding.ensureInitialized();
  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
  ]).then((value) {
    PrefUtils().init();
    runApp(MyApp());
  });
=======
=======
>>>>>>> Stashed changes
    EmailOTP.config(
    appName: 'Fitness App',
    otpType: OTPType.numeric,
    emailTheme: EmailTheme.v1,
    expiry: 50000,
    otpLength: 6,
  );
    EmailOTP.setSMTP(
    host: 'smtp.gmail.com',
        // host: '162.248.102.236',
    emailPort: EmailPort.port587,
    secureType: SecureType.tls,
    username: 'trinhthuc130902@gmail.com',
    password: 'gkkt dvcr sbry mcya',
  );
  Gemini.init(apiKey: GEMINI_API_KEY,);
  runApp(const MyApp());
>>>>>>> Stashed changes
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
<<<<<<< Updated upstream
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
=======
    return MaterialApp(
      // title: 'Chat Box',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: const StartScreen(),
      home: DashboardScreen(),
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
    );
}
}
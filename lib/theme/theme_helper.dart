import 'package:flutter/material.dart ';
import 'package:flutter_application_fitness/core/utils/size_utils.dart';

import '../core/utils/pref_utils.dart';

LightCodeColors get appTheme => ThemeHelper().themeColor();
ThemeData get theme => ThemeHelper().themeData();

class ThemeHelper {
  final _appTheme = PrefUtils().getThemeData();

  LightCodeColors themeColor() => _getThemeColors();

  ThemeData themeData() => _getThemeData();

  final Map<String, LightCodeColors> _supportedCustomColor = {
    'light': LightCodeColors(),
  };

  final Map<String, ColorScheme> _supportedColorScheme = {
    'light': ColorSchemes.lightCodeColorScheme,
  };

  LightCodeColors _getThemeColors() {
    return _supportedCustomColor[_appTheme]?? LightCodeColors();
  }

  ThemeData _getThemeData() {
    var colorScheme = _supportedColorScheme[_appTheme]?? ColorSchemes.lightCodeColorScheme;

    return ThemeData(
      visualDensity: VisualDensity.standard,
      colorScheme: colorScheme,
      textTheme: TextThemes.textTheme(colorScheme),
      scaffoldBackgroundColor: appTheme.whiteA700,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          shadowColor: appTheme.indigoA1004c,
          elevation: 10,
          visualDensity: const VisualDensity(
            horizontal: -4,
            vertical: -4,
          ),
          padding: EdgeInsets.zero,
        ),
      ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return colorScheme.primary;
        }
        return Colors.transparent;
      }),

      side: const BorderSide(
        width: 1,
      ),
      visualDensity: const VisualDensity(horizontal: -4,
      vertical: -4),

    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(),
    dividerTheme: DividerThemeData(
        space: 1,
        thickness: 1,
        color: appTheme.gray300,
      ),
    );


  }
}

class TextThemes{
  static TextTheme textTheme(ColorScheme colorScheme) => TextTheme(
    displayMedium: TextStyle(
      color: appTheme.purple200,
      fontSize: 50.fSize,
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w700,
      
    ),

    displaySmall: TextStyle(
      color: appTheme.gray90001,
      fontSize: 36.fSize,
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w700,
      
    ),
  );

  
}


class ColorSchemes{
  static const lightCodeColorScheme = ColorScheme.light(
    primary: Color(0xFF92A3FD),
    primaryContainer: Color(0xFF2E2E2E),
    secondaryContainer: Color(0xFFE89B34),
    errorContainer: Color(0x197B6F72),
    onError: Color(0xFFFA9E97),
    onErrorContainer: Color(0xFF0F0F0F),
    onPrimary: Color(0xFF27192E),
    onPrimaryContainer: Color(0xFFFFFFCF),
  );
}

class LightCodeColors {
  Color get amber200 => const Color(0xFFFDE588); 
  Color get amber300 => const Color(0xFFFFCA5E);  
Color get amber3001 => const Color(0xFFFFC850);  
Color get amber600 => const Color(0xFFFFB506);  
Color get amber700 => const Color(0xFFF0A508);  
Color get amberA200 => const Color(0xFFFBCB43);
Color get black900 => const Color(0xFF000000);  
// Blue  
Color get blue200 => const Color(0xFF8FBBFF);  
Color get blue20001 => const Color(0xFF9DCEFF);  
Color get blue20002 => const Color(0xFF98BFFD);  
Color get blue20003 => const Color(0xFF97BEFC);  
Color get blue50 => const Color(0xFFE0E6FF);  
Color get blueA400 => const Color(0xFF1877F2);  
// BlueGray  
Color get blueGray400 => const Color(0xFF679E97);  
Color get blueGray50 => const Color(0xFFE8EDF2);  
Color get blueGray600 => const Color(0xFF605A8F);  
Color get blueGray60001 => const Color(0xFF636183);  
Color get blueGray700 => const Color(0xFF295C69);  
Color get blueGray70001 => const Color(0xFF455A64);  
Color get blueGray800 => const Color(0xFF393762);  
Color get blueGray80001 => const Color(0xFF2C3E50);  
Color get blueGray80002 => const Color(0xFF343057);  
Color get blueGray90002 => const Color(0xFF263238);

Color get blueGray90003 => const Color(0xFF3B2645);  
Color get blueGray90004 => const Color(0xFF2B2B2B);  
// Cyan  
Color get cyan700 => const Color(0xFF069FAD);  
// DeepOrange  
Color get deepOrange100 => const Color(0xFFE1CCBB);  
Color get deepOrange1001 => const Color(0xFFE2CAB3);  
Color get deepOrange1002 => const Color(0xFFE5CBAA);  
Color get deepOrange1003 => const Color(0xFFEDECB9);  
Color get deepOrange200 => const Color(0xFFFF5AC2);  
Color get deepOrange300 => const Color(0xFFFF725E);  
Color get deepOrange50 => const Color(0xFFFFEDE5);  
Color get deepOrange800 => const Color(0xFFCC6720);  
Color get deepOrange8001 => const Color(0xFFCC562A);  
Color get deepOrange900 => const Color(0x0ffb502e);  
Color get deepOrange9001 => const Color(0xFFBB5200);  
Color get deepOrange9002 => const Color(0xFF914940);  
Color get deepOrangeA100 => const Color(0xffff5a784);  
Color get deepOrangeA1001 => const Color(0xffff5a96c);  
Color get deepOrangeA400 => const Color(0xffffe1600);  
// DeepPurple  
Color get deepPurple100 => const Color(0xFF7D71EB);  
Color get deepPurple50 => const Color(0xFFE3DC7F);  
Color get deepPurple5001 => const Color(0xFF9E9E5F);  
Color get deepPurple5002 => const Color(0xFFE2EDFF);  
Color get deepPurpleA100 => const Color(0x0ff58bf2);  
// Gray  
Color get gray100 => const Color(0xFFF4F4F4);  
Color get gray200 => const Color(0xFFFFFFFF);  
Color get gray20001 => const Color(0xFFEBEAEA); 

Color get gray20002 => const Color(0xFFE8E8E8);  
Color get gray300 => const Color(0xFFDD9D9A);  
Color get gray30001 => const Color(0xFFE0E0E0);  
Color get gray30003 => const Color(0xFFE5E5E5);  
Color get gray400 => const Color(0xFFFAFAFA);  
Color get gray40001 => const Color(0xFFBBFBFB);  
Color get gray40002 => const Color(0xFFC6C6C6);  
Color get gray500 => const Color(0xFFF7F7F7);  
Color get gray50001 => const Color(0xfffafa8c7);  
Color get gray50002 => const Color(0xFFACACAC);  
Color get gray50003 => const Color(0xFF99A2A7);  
Color get gray50004 => const Color(0xffacac3a5);  
Color get gray50005 => const Color(0xFFAB8DA8);  
Color get gray50006 => const Color(0xFFABFAFA);  
Color get gray5001 => const Color(0xFFFAFAFA);  
Color get gray600 => const Color(0xFF757C80);  
Color get gray60001 => const Color(0xFFE85858);  
Color get gray60002 => const Color(0xFF626B8A);  
Color get gray60003 => const Color(0xFFAAFA7A);  
Color get gray60004 => const Color(0xFF8383B7);  
Color get gray60005 => const Color(0xFF7E707D);  
Color get gray700 => const Color(0xFF6A5C69);  
Color get gray70001 => const Color(0xFFB5B25C);  
Color get gray800 => const Color(0xFF474747);  
Color get gray80001 => const Color(0xFF484840);

Color get gray80002 => const Color(0xFF472938);  
Color get gray80003 => const Color(0xFF383838);  
Color get gray80004 => const Color(0xFF48264C);  
Color get gray80005 => const Color(0xFF54375E);  
Color get gray900 => const Color(0x0ff300d3);  
Color get gray90001 => const Color(0xFF1D1517);  
Color get gray90002 => const Color(0xFF212121);  
Color get gray90003 => const Color(0x0ff3329e);  
Color get gray90004 => const Color(0xFF1C242A);  
Color get gray90005 => const Color(0xFF222D1E);  
Color get gray90011 => const Color(0xFF1F1F1F);  
// Grayc  
Color get gray9000c => const Color(0x0C1D242A);  
// Green  
Color get green500 => const Color(0xFF41D641);  
Color get green700 => const Color(0xFF3E9F32);  
// Indigo  
Color get indigo100 => const Color(0xFFB9B5EC);  
Color get indigo10001 => const Color(0xFFB3BFD5);  
Color get indigo400 => const Color(0xFF5080C0);  
// IndigoAc  
Color get indigoA1004c => const Color(0x4C95ADFE);  
// LightBlue  
Color get lightBlue800 => const Color(0xFF006EC3);  
// LightGreen  
Color get lightGreen100 => const Color(0xFF7ED8C8);  
Color get lightGreen400 => const Color(0xFFAD7D55);  
Color get lightGreen500 => const Color(0xFF97C7D4);

Color get lightGreen50001 => const Color(0x0ff4b24a);  
Color get lightGreen50002 => const Color(0xFF8D854F);  
Color get lightGreen600 => const Color(0xFF68993E);  
Color get lightGreen700 => const Color(0xFF789894);  
Color get lightGreen70002 => const Color(0xFF68824A);  
Color get lightGreen800 => const Color(0xFF647039);  
Color get lightGreen80002 => const Color(0xFF5C7732);  
Color get lightGreen900 => const Color(0xFF5C7732);  
Color get lightGreenA100 => const Color(0xFFD4F582);  

// Lime  
Color get lime300 => const Color(0xFFBEE86E);  
Color get lime50 => const Color(0xFFFDFF8E);  
Color get lime700 => const Color(0xFFBA9732);  
Color get lime70001 => const Color(0xFFC98E36);  
Color get lime800 => const Color(0xFF8D82EF);  
Color get lime80001 => const Color(0xFF8D963D);  
Color get lime900 => const Color(0xFF6C3200);  

  
  // Orange  
Color get orange200 => const Color(0xFFFFC56D);  
Color get orange20001 => const Color(0x0fffff76);  
Color get orange20002 => const Color(0x0fffff85);  
Color get orange300 => const Color(0x0fffc356);  
Color get orange30001 => const Color(0xFFFFB842);  
Color get orange30002 => const Color(0xFFE96536);  
Color get orange400 => const Color(0xFFFFE6B6);  
Color get orange500 => const Color(0x0ffea8d8);  
Color get orange50001 => const Color(0xFFFFFBDC);
  
Color get orangeA100 => const Color(0xffffdd76f);  
Color get orangeA200 => const Color(0xffffea2744);  
Color get orangeA2001 => const Color(0xffffea39042);  
Color get orangeA20002 => const Color(0xffff9a353);  

// Pink  
Color get pink100 => const Color(0xffffeea4ce);  
Color get pink200 => const Color(0xffffbb93af);  
Color get pink300 => const Color(0xffffea7c99);  
Color get pink3001 => const Color(0xffffe27798);  
Color get pink600 => const Color(0xffffd72f5d);  
Color get pink700 => const Color(0xffffc73a54);  
Color get pink70001 => const Color(0xffffb22e5d);  
Color get pink800 => const Color(0xffff9b4471);  
Color get pink900 => const Color(0xffff843860);  
Color get pinkA100 => const Color(0xFFFF8D8A);  

// Purple  
Color get purple100 => const Color(0xffefe8cee5);  
Color get purple10001 => const Color(0xffffd6bed3);  
Color get purple200 => const Color(0xffffcc8fed);  

// Red  
Color get red200 => const Color(0xffffdeb89a);  
Color get red20001 => const Color(0xffff399b9);  
Color get red20002 => const Color(0xffff58497);  
Color get red20003 => const Color(0xFFFF6495);  
Color get red20004 => const Color(0xffff3ac8a);  
Color get red20005 => const Color(0xffff28f8f);  
Color get red300 => const Color(0xFFFFC7C7);  
Color get red30001 => const Color(0xFFFFD366);  
Color get red30002 => const Color(0xffffe835c);

Color get red30003 => const Color(0xFFDE835C);  
Color get red30004 => const Color(0x0ff45673);  
Color get red30005 => const Color(0x0ffeb55b);  
Color get red30006 => const Color(0xFFEB035C);  
Color get red30007 => const Color(0x00ff845c);  
Color get red400 => const Color(0x0ffeb569);  
Color get red40001 => const Color(0x0ff64646);  
Color get red40002 => const Color(0x00ff534a);  
Color get red40003 => const Color(0x0ffdb449);  
Color get red40005 => const Color(0x00ff665d);  
Color get red40006 => const Color(0x0ff26757);  
Color get red500 => const Color(0x0ffee433);  
Color get red50001 => const Color(0x00ff523b);  
Color get red60001 => const Color(0x0ff74444);  
Color get red60002 => const Color(0x0ff39590);  
Color get red800 => const Color(0xFFBC2921);  
Color get red80001 => const Color(0xFFCA2C21);  
Color get redA100 => const Color(0xFFef7e8A);  
Color get redA10001 => const Color(0xFFff927D);  
Color get redA700 => const Color(0xFFFF0000);  

// Teal  
Color get teal200 => const Color(0x0ff85cc6);  
Color get teal400 => const Color(0xFF4292A6);  
Color get teal50 => const Color(0x0ff9e7ec);  

// White  
Color get whiteA700 => const Color(0xFFFFFFFF);

// Yellow  
Color get yellow100 => const Color(0xfffffedc4);  
Color get yellow400 => const Color(0xfffffdc64);  
Color get yellow50 => const Color(0xFFFFFE9F);  
Color get yellow600 => const Color(0xffffe2d38);  
Color get yellow700 => const Color(0xffff4bc2f);  
Color get yellow7001 => const Color(0xffffebe30);  
Color get yellow800 => const Color(0xffffebe20);  
Color get yellow8001 => const Color(0xffffdbb523);  
Color get yellow8002 => const Color(0xffefe2952c);  
Color get yellow8003 => const Color(0xffffea328);  
Color get yellow900 => const Color(0xfffff38e1c);  
Color get yellow9001 => const Color(0xffffd88121);  
Color get yellow9002 => const Color(0xffffe87f18);  
Color get yellow9003 => const Color(0xffffe2802c);  
Color get yellow9004 => const Color(0xFFDA480D);  
Color get yellow9005 => const Color(0xffffcc752e);
  


}


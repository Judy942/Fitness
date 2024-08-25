import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_fitness/core/utils/navigator_service.dart';


extension LocalizationExtension on String {
  String get tr => AppLocalization.of().getString(this);
}

class AppLocalization {
  final Locale locale;

  AppLocalization(this.locale);

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'hello': 'Hello',
      'world': 'World',
    },
  };

  static AppLocalization of() {
    return Localizations.of<AppLocalization>(NavigatorService.navigatorKey.currentContext!, AppLocalization)!;
  }

  static List<String> languages() => _localizedValues.keys.toList();
  String getString(String key) => _localizedValues[locale.languageCode]![key]??key;


}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalization> {
  const AppLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalization.languages().contains(locale.languageCode);

  @override
  Future<AppLocalization> load(Locale locale) {
    return SynchronousFuture<AppLocalization>(AppLocalization(locale));
  }

  @override
  bool shouldReload(AppLocalizationDelegate old) => false;
}
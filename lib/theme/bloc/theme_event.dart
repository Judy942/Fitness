part of 'theme_bloc.dart';

class ThemeEvent extends Equatable {

  @override
  List<Object> get props => throw UnimplementedError();
}

class ThemeChangedEvent extends ThemeEvent {
  final String themeType;

  ThemeChangedEvent({required this.themeType}):super(){
    PrefUtils().setThemeData(themeType);
  }

  @override
  List<Object> get props => [];
}
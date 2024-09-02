part of 'welcome_screen_one_bloc.dart';

class WelcomeScreenOneState extends Equatable {
  WelcomeScreenOneState({this.welcomeScreenOneModelObj});

  WelcomeScreenOneModel? welcomeScreenOneModelObj;

  @override
  List<Object?> get props => [welcomeScreenOneModelObj];

  WelcomeScreenOneState copyWith({
    WelcomeScreenOneModel? welcomeScreenOneModelObj,
  }) {
    return WelcomeScreenOneState(
      welcomeScreenOneModelObj: welcomeScreenOneModelObj ?? this.welcomeScreenOneModelObj,
    );
  }
}
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../models/welcome_screen_one_model.dart';


part 'welcome_screen_one_event.dart';
part 'welcome_screen_one_state.dart';


class WelcomeScreenOneBloc extends Bloc<WelcomeScreenOneEvent, WelcomeScreenOneState> {
  WelcomeScreenOneBloc(WelcomeScreenOneState initialState) : super(initialState){ 
    on<WelcomeScreenOneInitialEvent>(_onInitialEvent);
  }

  _onInitialEvent(WelcomeScreenOneInitialEvent event, Emitter<WelcomeScreenOneState> emit) async {
    Future.delayed(const Duration(seconds: 3), () {
      // NavigatorService.popAndPushNamed(AppRoutes.initialRoute);
    });
  }
}
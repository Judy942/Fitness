import 'package:equatable/equatable.dart';
import 'package:flutter_application_fitness/presentation/onboarding_one_screen/models/onboarding_one_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart ';

part  'onboarding_one_event.dart';
part  'onboarding_one_state.dart';

class OnboardingOneBloc extends Bloc<OnboardingOneEvent, OnboardingOneState> {
  OnboardingOneBloc(OnboardingOneState initialState) : super(initialState){
    on<OnboardingOneInitialEvent>(_onInitialize);
  }

  _onInitialize(OnboardingOneInitialEvent event, Emitter<OnboardingOneState> emit) async {
  }

}

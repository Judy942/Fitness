part of 'onboarding_one_bloc.dart';

// ignore: must_be_immutable
class OnboardingOneState extends Equatable {
  OnboardingOneModel? onboardingOneModelObj;
  OnboardingOneState({ this.onboardingOneModelObj});

  @override
  List<Object?> get props => [onboardingOneModelObj];

  OnboardingOneState copyWith({
    OnboardingOneModel? onboardingOneModelObj,
  }) {
    return OnboardingOneState(
      onboardingOneModelObj: onboardingOneModelObj ?? this.onboardingOneModelObj,
    );
  }

}




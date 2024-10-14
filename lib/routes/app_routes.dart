import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/presentation/activity_tracker/activity_tracker_screen.dart';
import 'package:flutter_application_fitness/presentation/camera/photo_progress/progress_photo_screen.dart';
import 'package:flutter_application_fitness/presentation/dashboard/dashboard_screen.dart';
import 'package:flutter_application_fitness/presentation/goals/goals_screen.dart';
import 'package:flutter_application_fitness/presentation/home/home_screen.dart';
import 'package:flutter_application_fitness/presentation/login/login_screen.dart';
import 'package:flutter_application_fitness/presentation/meal_planner/meal_planner_detail/meal_planner_detail_screen.dart';
import 'package:flutter_application_fitness/presentation/meal_planner/meal_planner_screen.dart';
import 'package:flutter_application_fitness/presentation/meal_planner/meal_schedule/meal_schedule.dart';
import 'package:flutter_application_fitness/presentation/notification/notification_screen.dart';
import 'package:flutter_application_fitness/presentation/onboarding_screen/onboarding_screen.dart';
import 'package:flutter_application_fitness/presentation/onboarding_screen/start_screen.dart';
import 'package:flutter_application_fitness/presentation/profile/complete_profile_screen.dart';
import 'package:flutter_application_fitness/presentation/profile/user_profile.dart';
import 'package:flutter_application_fitness/presentation/signup/signup_screen.dart';
import 'package:flutter_application_fitness/presentation/welcome/welcome_screen.dart';
import 'package:flutter_application_fitness/presentation/workout/finish_workout/finish_workout_screen.dart';
import 'package:flutter_application_fitness/presentation/workout/workout_schedule_view/add_schedule_view.dart';
import 'package:flutter_application_fitness/presentation/workout/workout_schedule_view/workout_schedule_view.dart';
import 'package:flutter_application_fitness/presentation/workout/workout_tracker/workout_tracker_screen.dart';

import '../presentation/home/how_to_calculate_bmi.dart';

class AppRoutes {
  // static const String initialRoute = '/initialRoute';
  static const String startScreen = '/startScreen';
  static const String onboardingScreen = '/onboardingScreen';
  static const String homeScreen = '/homeScreen';
  static const String loginScreen = '/loginScreen';
  static const String signUpScreen = '/signUpScreen';
  static const String completeProfileScreen = '/completeProfileScreen';
  static const String notificationScreen = '/notificationScreen';
  static const String activityTrackerScreen = '/activityTrackerScreen';
  static const String finishWorkoutScreen = '/finishWorkoutScreen';
  static const String welcomeScreen = '/welcomeScreen';
  static const String goalsScreen = '/goalsScreen';
  static const String workoutScheduleView = '/workoutScheduleView';
  static const String dashboardScreen = '/dashboardScreen';
  static const String howToCalculateBmi = '/howToCalculateBmi';
  static const String workoutTrackerScreen = '/workoutTrackerScreen';
  static const String userProfile = '/userProfile';
  static const String progressPhotoScreen = '/progressPhotoScreen';
  static const String addScheduleView = '/addScheduleView';
  static const String mealPlannerScreen = '/mealPlannerScreen';
  static const String foodRowWidget = '/foodRowWidget';
  static const String mealPlannerDetailScreen = '/mealPlannerDetailScreen';
  static const String mealScheduleScreen = '/mealScheduleScreen';


  static Map<String, WidgetBuilder> routes = {
    // initialRoute: (context) => const StartScreen(),
    startScreen: (context) => const StartScreen(),
    onboardingScreen: (context) => const OnboardingScreen(),
    loginScreen: (context) => const LoginScreen(),
    signUpScreen: (context) => const SignupScreen(),
    completeProfileScreen: (context) =>  CompleteProfileScreen(isBackToProfile: false,),
    notificationScreen: (context) => const NotificationScreen(),
    activityTrackerScreen: (context) => const ActivityTrackerScreen(),
    finishWorkoutScreen: (context) => const FinishWorkoutScreen(),
    welcomeScreen: (context) => const WelcomeScreen(),
    goalsScreen: (context) => const GoalsScreen(),
    workoutScheduleView: (context) => const WorkoutScheduleView(),
    dashboardScreen: (context) => const DashboardScreen(),
    howToCalculateBmi: (context) =>  const HowToCalculateBmi(),
    homeScreen: (context) => const HomeScreen(),
    workoutTrackerScreen: (context) => const WorkoutTrackerScreen(),
    progressPhotoScreen: (context) => const ProgressPhotoScreen(),
    userProfile: (context) => const UserProfile(),
    addScheduleView : (context) => AddScheduleView(date: DateTime.now()),
    mealPlannerScreen: (context) => const MealPlannerScreen(),
    mealPlannerDetailScreen: (context) =>  const MealPlannerDetailScreen( title: "title",),
    mealScheduleScreen: (context) =>  const MealSchedule(),


  };
}
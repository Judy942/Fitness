// import 'package:flutter/material.dart';
// import 'package:flutter_application_fitness/core/utils/size_utils.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:custom_image_view/custom_image_view.dart';
// import 'bloc/onboarding_one_bloc.dart';
// import 'models/onboarding_one_model.dart';


// class OnboardingOneScreen extends StatelessWidget {
//   const OnboardingOneScreen({Key? key}) : super(key: key);

//   static Widget builder(BuildContext context) {
//     return BlocProvider<OnboardingOneBloc>(create: (context)=> OnboardingOneBloc (OnboardingOneState(onboardingOneModelObj: OnboardingOneModel()))..add(OnboardingOneInitialEvent()),child: const OnboardingOneScreen(),);
//   }

//   @override
//   Widget build(BuildContext context){
//     return BlocBuilder<OnboardingOneBloc, OnboardingOneState>(builder: (context, state) {
//       return SafeArea(
//         child: Scaffold(
//           body: SizedBox(width: double.maxFinite,
//           child: SingleChildScrollView(child: Column(
//             children: [
              
//              CustomImageView(
//                 imagePath: ImageConstant.imgGroup,
//                 height: 400.h,
//                 width: double.maxFinite,
//               ),

//           //     Expanded(
//           // child: Image.asset('assets/images/Frame.png', width: double.maxFinite, height: 400.h, fit: BoxFit.fill,),
//           //     ),
//               SizedBox(
//                 height: 64.h,
                
//               ),
//               _buildGoalTrackingSection(context),
//               SizedBox(
//                 height: 4.h,
//               ),
//             ],
// //
//           ),)
//           ),
//         ),
//           );
//     },);

//   }

  
// }




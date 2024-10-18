
// import 'package:flutter/material.dart';
// import 'package:flutter_application_fitness/core/utils/app_colors.dart';

// import '../../../widgets/icon_title_next_row.dart';
// import '../../../widgets/round_button.dart';
// import 'result_view.dart';

// class ComparisonView extends StatefulWidget {
//   const ComparisonView({super.key});

//   @override
//   State<ComparisonView> createState() => _ComparisonViewState();
// }

// class _ComparisonViewState extends State<ComparisonView> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.whiteColor,
//         centerTitle: true,
//         elevation: 0,
//         leading: InkWell(
//           onTap: () {
//             Navigator.pop(context);
//           },
//           child: Container(
//             margin: const EdgeInsets.all(8),
//             height: 40,
//             width: 40,
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//                 color: AppColors.lightGrayColor,
//                 borderRadius: BorderRadius.circular(10)),
//             child: Image.asset(
//               "assets/icons/back_icon",
//               width: 15,
//               height: 15,
//               fit: BoxFit.contain,
//             ),
//           ),
//         ),
//         title: const Text(
//           "Comparison",
//           style: TextStyle(
//               color: AppColors.blackColor, fontSize: 16, fontWeight: FontWeight.w700),
//         ),
//       ),
//       backgroundColor: AppColors.whiteColor,
//       body: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
//         child: Column(
//           children: [
//             IconTitleNextRow(
//                 icon:"assets/icons/calendar_icon",

//                 title: "Select Month 1",
//                 time: "May",
//                 onPressed: () {},
//                 color: AppColors.lightGrayColor),
//             const SizedBox(
//               height: 15,
//             ),
//             IconTitleNextRow(
//                 icon:"icons/calendar_icon",
//                 title: "Select Month 2",
//                 time: "select Month",
//                 onPressed: () {},
//                 color: AppColors.lightGrayColor),
//             const Spacer(),
//             RoundButton(
//                 title: "Compare",
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => ResultView(
//                         date1: DateTime(2023, 5, 1),
//                         date2: DateTime(2023, 6, 1),
//                       ),
//                     ),
//                   );
//                 }),
//             const SizedBox(
//               height: 15,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/core/utils/app_colors.dart';

import '../../../widgets/icon_title_next_row.dart';
import '../../../widgets/round_button.dart';
import 'result_view.dart';

class ComparisonView extends StatefulWidget {
  const ComparisonView({super.key});

  @override
  State<ComparisonView> createState() => _ComparisonViewState();
}

class _ComparisonViewState extends State<ComparisonView> {
  String selectedMonth1 = "Select Month 1";
  String selectedMonth2 = "Select Month 2";

  final List<String> months = [
    'January', 'February', 'March', 'April', 'May',
    'June', 'July', 'August', 'September', 'October',
    'November', 'December'
  ];

  Future<void> _selectMonth(BuildContext context, int monthIndex) async {

    final selectedMonth = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return Container(
          height: 250,
          child: Column(
            children: [
              Text('Select Month', style: TextStyle(fontSize: 18)),
              Expanded(
                child: ListView.builder(
                  itemCount: months.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(months[index]),
                      onTap: () {
                        Navigator.pop(context, months[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selectedMonth != null) {
      setState(() {
        if (monthIndex == 1) {
          selectedMonth1 = selectedMonth;
        } else {
          selectedMonth2 = selectedMonth;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: AppColors.lightGrayColor,
                borderRadius: BorderRadius.circular(10)),
            child: Image.asset(
              "assets/icons/back_icon",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: const Text(
          "Comparison",
          style: TextStyle(
              color: AppColors.blackColor, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      backgroundColor: AppColors.whiteColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          children: [
            IconTitleNextRow(
              icon: "assets/icons/calendar_icon",
              title: "Select Month 1",
              time: selectedMonth1,
              onPressed: () => _selectMonth(context, 1),
              color: AppColors.lightGrayColor,
            ),
            const SizedBox(height: 15),
            IconTitleNextRow(
              icon: "assets/icons/calendar_icon",
              title: "Select Month 2",
              time: selectedMonth2,
              onPressed: () => _selectMonth(context, 2),
              color: AppColors.lightGrayColor,
            ),
            const Spacer(),
            RoundButton(
              title: "Compare",
              onPressed: () {
                int month1 = months.indexOf(selectedMonth1) + 1;
                int month2 = months.indexOf(selectedMonth2) + 1;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultView(
                      date1: DateTime(2024, month1, 1),
                      date2: DateTime(2024, month2, 1),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}

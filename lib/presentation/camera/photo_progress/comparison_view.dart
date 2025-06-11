import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/core/utils/app_colors.dart';
import 'package:flutter_application_fitness/presentation/dashboard/dashboard_screen.dart';

import '../../../widgets/icon_title_next_row.dart';
import '../../../widgets/round_button.dart';
import 'result_view.dart';

class ComparisonView extends StatefulWidget {
  const ComparisonView({super.key});

  @override
  State<ComparisonView> createState() => _ComparisonViewState();
}

class _ComparisonViewState extends State<ComparisonView> {
  String selectedMonth1 = "Chọn tháng 1";
  String selectedMonth2 = "Chọn tháng 2";
  int selectedYear1 = DateTime.now().year;
  int selectedYear2 = DateTime.now().year;

  final List<String> months = [
    'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5',
    'Tháng 6', 'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10',
    'Tháng 11', 'Tháng 12'
  ];

  final List<int> years = List.generate(5, (index) => DateTime.now().year - 2 + index);

  Future<void> _selectMonth(BuildContext context, int monthIndex) async {
    String tempSelectedMonth = monthIndex == 1 ? selectedMonth1 : selectedMonth2;
    int tempSelectedYear = monthIndex == 1 ? selectedYear1 : selectedYear2;

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                children: [
                  const Text('Chọn tháng và năm', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 20),
                  // Year Selection
                  Container(
                    height: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.lightGrayColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: tempSelectedYear,
                        isExpanded: true,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        items: years.map((year) {
                          return DropdownMenuItem(
                            value: year,
                            child: Text(year.toString()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() {
                              tempSelectedYear = value;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Month Selection
                  Expanded(
                    child: ListView.builder(
                      itemCount: months.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(months[index]),
                          selected: months[index] == tempSelectedMonth,
                          onTap: () {
                            Navigator.pop(context, {
                              'month': months[index],
                              'year': tempSelectedYear,
                            });
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
      },
    );

    if (result != null) {
      setState(() {
        if (monthIndex == 1) {
          selectedMonth1 = result['month'];
          selectedYear1 = result['year'];
        } else {
          selectedMonth2 = result['month'];
          selectedYear2 = result['year'];
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
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashboardScreen(initialTab: DashboardTab.camera,)));
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
              "assets/icons/closed_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: const Text(
          "So sánh",
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
              
              icon: "assets/icons/date.png",
              title: "Chọn tháng 1",
              time: "$selectedMonth1 $selectedYear1",
              onPressed: () => _selectMonth(context, 1),
              color: AppColors.lightGrayColor,
            ),
            const SizedBox(height: 15),
            IconTitleNextRow(
              icon: "assets/icons/date.png",
              title: "Chọn tháng 2",
              time: "$selectedMonth2 $selectedYear2",
              onPressed: () => _selectMonth(context, 2),
              color: AppColors.lightGrayColor,
            ),
            const Spacer(),
            RoundButton(
              title: "So sánh",
              onPressed: () {
                if (selectedMonth1 == "Chọn tháng 1" ||
                    selectedMonth2 == "Chọn tháng 2") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Vui lòng chọn cả hai tháng"),
                    ),
                  );
                  return;
                }
                int month1 = months.indexOf(selectedMonth1) + 1;
                int month2 = months.indexOf(selectedMonth2) + 1;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultView(
                      date1: DateTime(selectedYear1, month1, 1),
                      date2: DateTime(selectedYear2, month2, 1),
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

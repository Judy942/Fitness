import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/utils/app_colors.dart';
import '../../../widgets/round_button.dart';
import '../../onboarding_screen/start_screen.dart';

class ResultView extends StatefulWidget {
  final DateTime date1;
  final DateTime date2;
  const ResultView({super.key, required this.date1, required this.date2});

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  Future<List<dynamic>> fetchProcessTrackerByMounth(String m) async {
    String? token = await getToken();
    final url = Uri.parse(
        'http://162.248.102.236:8055/items/process_tracker?limit=25&fields[]=*&sort[]=date_upload&page=1&filter[user_id][_eq]=\$CURRENT_USER&filter[month(date_upload)][_eq]=$m&filter[year(date_upload)][_eq]=${widget.date1.year}');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['data'] != null && jsonResponse['data'].isNotEmpty) {
          return jsonResponse['data'];
        } else {
          return []; // Trả về danh sách rỗng nếu không có dữ liệu
        }
      } else {
        return []; // Trả về danh sách rỗng nếu không có dữ liệu
      }
    } catch (e) {
      print("Error fetching data: $e");
      return []; // Trả về danh sách rỗng trong trường hợp lỗi
    }
  }

  List imaArr = [];

  List statArr = [];

  List tracker_position = [
    "Front Facing",
    "Back Facing",
    "Left Facing",
    "Right Facing",
  ];

  @override
  void initState() {
    super.initState();
    fetchProcessTrackerByMounth(widget.date1.month.toString()).then((value) {
      setState(() {
        imaArr = value;
      });
    });
    fetchProcessTrackerByMounth(widget.date2.month.toString()).then((value) {
      setState(() {
        statArr = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var groupedData = <int, List<dynamic>>{};
    for (var item in statArr) {
      int positionId = item['tracker_position_id'];
      if (!groupedData.containsKey(positionId)) {
        groupedData[positionId] = [];
      }
      groupedData[positionId]!.add(item);
    }

    var groupedData2 = <int, List<dynamic>>{};
    for (var item in imaArr) {
      int positionId = item['tracker_position_id'];
      if (!groupedData2.containsKey(positionId)) {
        groupedData2[positionId] = [];
      }
      groupedData2[positionId]!.add(item);
    }

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
              "assets/icons/back_icon.png",
              width: 25,
              height: 25,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: const Text(
          "Result",
          style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 22,
              fontWeight: FontWeight.w700),
        ),
      ),
      backgroundColor: AppColors.whiteColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 4,
                itemBuilder: (context, index) {
                  int positionId = index + 1;
                  if (!groupedData.containsKey(positionId) &&
                      !groupedData2.containsKey(positionId)) {
                    return const SizedBox();
                  }
                  List<dynamic> items = groupedData[positionId] ?? [];
                  List<dynamic> items2 = groupedData2[positionId] ?? [];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          tracker_position[positionId - 1],
                          style: const TextStyle(
                              color: AppColors.grayColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Before",
                            style: TextStyle(
                                color: AppColors.blackColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: items2.length,
                            itemBuilder: (context, i) {
                              return AspectRatio(
                                aspectRatio: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.lightGrayColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(
                                      'http://162.248.102.236:8055/assets/${items2[i]['image']}',
                                      errorBuilder: (BuildContext context,
                                          Object error,
                                          StackTrace? stackTrace) {
                                        return Container(
                                          color: Colors.grey,
                                          child: const Icon(Icons.error_outline),
                                        );
                                      },
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const Text(
                            "After",
                            style: TextStyle(
                                color: AppColors.blackColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: items.length,
                            itemBuilder: (context, i) {
                              return AspectRatio(
                                aspectRatio: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.lightGrayColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(
                                      'http://162.248.102.236:8055/assets/${items[i]['image']}',
                                      errorBuilder: (BuildContext context,
                                          Object error,
                                          StackTrace? stackTrace) {
                                        return Container(
                                          color: Colors.grey,
                                          child: const Icon(Icons.error_outline),
                                        );
                                      },
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
              RoundButton(
                title: "Back to Home",
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}

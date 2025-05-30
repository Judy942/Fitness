import 'package:fl_chart/fl_chart.dart'; // Thêm thư viện để vẽ đồ thị
import 'package:flutter/material.dart';
import 'package:health/health.dart';

import '../../core/utils/app_colors.dart';

class StatisticsScreen extends StatefulWidget {
  final String title;
  final String type;

  const StatisticsScreen({
    Key? key,
    required this.title,
    required this.type,
  }) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final Health _health = Health();
  Map<String, List<Map<String, dynamic>>> allData = {
    'steps': [],
    'distance': [],
    'total_burn_calories': [],
  };
  bool isLoading = true;
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => isLoading = true);
    try {
      final startOfMonth = DateTime(selectedYear, selectedMonth, 1);
      final endOfMonth = DateTime(selectedYear, selectedMonth + 1, 0, 23, 59, 59);

      // Lấy dữ liệu cho cả 3 loại
      final types = [
        HealthDataType.STEPS,
        HealthDataType.DISTANCE_DELTA,
        HealthDataType.TOTAL_CALORIES_BURNED,
      ];

      // Xin quyền truy cập
      bool requested = await _health.requestAuthorization(types);
      if (!requested) {
        setState(() {
          allData = {
            'steps': [],
            'distance': [],
            'total_burn_calories': [],
          };
          isLoading = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không có quyền truy cập dữ liệu sức khỏe')),
          );
        });
        return;
      }

      final data = await _health.getHealthDataFromTypes(
        types: types,
        startTime: startOfMonth,
        endTime: endOfMonth,
      );

      // Xử lý dữ liệu cho từng loại
      Map<String, Map<int, double>> dataMap = {
        'steps': {},
        'distance': {},
        'total_burn_calories': {},
      };

      for (var point in data) {
        final day = point.dateFrom.day;
        if (point.value is NumericHealthValue) {
          final value = (point.value as NumericHealthValue).numericValue;
          if (value != null) {
            String type = '';
            if (point.type == HealthDataType.STEPS) {
              type = 'steps';
            } else if (point.type == HealthDataType.DISTANCE_DELTA) {
              type = 'distance';
            } else if (point.type == HealthDataType.TOTAL_CALORIES_BURNED) {
              type = 'total_burn_calories';
            }
            
            if (type.isNotEmpty) {
              dataMap[type]![day] = (dataMap[type]![day] ?? 0) + value;
            }
          }
        }
      }

      // Chuyển đổi thành danh sách và sắp xếp
      allData = {
        'steps': dataMap['steps']!.entries.map((e) => {
          'day': e.key,
          'value': e.value,
        }).toList(),
        'distance': dataMap['distance']!.entries.map((e) => {
          'day': e.key,
          'value': e.value,
        }).toList(),
        'total_burn_calories': dataMap['total_burn_calories']!.entries.map((e) => {
          'day': e.key,
          'value': e.value,
        }).toList(),
      };

      // Sắp xếp dữ liệu theo ngày
      allData.forEach((key, value) {
        value.sort((a, b) => a['day'].compareTo(b['day']));
      });

    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')),
        );
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _selectMonthYear(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(selectedYear, selectedMonth),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null && (picked.year != selectedYear || picked.month != selectedMonth)) {
      setState(() {
        selectedYear = picked.year;
        selectedMonth = picked.month;
      });
      _loadAllData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.blackColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thống kê hoạt động',
          style: TextStyle(color: AppColors.blackColor),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: AppColors.blackColor),
            onPressed: () => _selectMonthYear(context),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : allData.values.every((data) => data.isEmpty)
              ? const Center(child: Text('Không có dữ liệu để hiển thị biểu đồ'))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Biểu đồ Steps
                        if (allData['steps']!.isNotEmpty) ...[
                          const Text(
                            'Biểu đồ đường - Số bước chân',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 300,
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(show: true, drawVerticalLine: true),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 30,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          value.toInt().toString(),
                                          style: const TextStyle(fontSize: 10),
                                        );
                                      },
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 30,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          value.toInt().toString(),
                                          style: const TextStyle(fontSize: 10),
                                        );
                                      },
                                    ),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border.all(color: AppColors.primaryColor1, width: 1),
                                ),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: allData['steps']!.map((data) {
                                      final day = data['day'] as int;
                                      final value = data['value'] as double;
                                      return FlSpot(day.toDouble(), value);
                                    }).toList(),
                                    isCurved: true,
                                    color: AppColors.primaryColor1,
                                    barWidth: 3,
                                    belowBarData: BarAreaData(show: true, color: AppColors.primaryColor1.withOpacity(0.3)),
                                  ),
                                ],
                                minX: 1,
                                maxX: 31,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Biểu đồ Distance
                        if (allData['distance']!.isNotEmpty) ...[
                          const Text(
                            'Biểu đồ cột - Quãng đường',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 300,
                            child: BarChart(
                              BarChartData(
                                gridData: FlGridData(show: true),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 30,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          value.toInt().toString(),
                                          style: const TextStyle(fontSize: 10),
                                        );
                                      },
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 30,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          value.toInt().toString(),
                                          style: const TextStyle(fontSize: 10),
                                        );
                                      },
                                    ),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border.all(color: Colors.black, width: 1),
                                ),
                                barGroups: allData['distance']!.map((data) {
                                  final day = data['day'] as int;
                                  final value = data['value'] as double;
                                  return BarChartGroupData(
                                    x: day,
                                    barRods: [
                                      BarChartRodData(
                                        toY: value,
                                        color: AppColors.primaryColor2,
                                        width: 12, // Giảm kích thước thanh
                                        backDrawRodData: BackgroundBarChartRodData(
                                          show: true,
                                          toY: 0,
                                          color: AppColors.primaryColor2.withOpacity(0.1),
                                        ),
                                        borderSide: const BorderSide(color: Colors.black, width: 1), // Thêm viền màu đen
                                      ),
                                    ],
                                  );
                                }).toList(),
                                barTouchData: BarTouchData(
                                  enabled: true,
                                  touchTooltipData: BarTouchTooltipData(
                                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                      return BarTooltipItem(
                                        rod.toY.toStringAsFixed(0),
                                        const TextStyle(color: Colors.white),
                                      );
                                    },
                                  ),
                                ),
                                alignment: BarChartAlignment.spaceAround,
                                maxY: allData['distance']!.map((e) => e['value'] as double).fold<double>(0, (prev, el) => el > prev ? el : prev) + 10,
                              ),
                              swapAnimationDuration: const Duration(milliseconds: 800),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Biểu đồ Calories
                        if (allData['total_burn_calories']!.isNotEmpty) ...[
                          const Text(
                            'Biểu đồ đường - Calo',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 300,
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(show: true, drawVerticalLine: true),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 30,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          value.toInt().toString(),
                                          style: const TextStyle(fontSize: 10),
                                        );
                                      },
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 30,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          value.toInt().toString(),
                                          style: const TextStyle(fontSize: 10),
                                        );
                                      },
                                    ),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border.all(color: AppColors.primaryColor1, width: 1),
                                ),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: allData['total_burn_calories']!.map((data) {
                                      final day = data['day'] as int;
                                      final value = data['value'] as double;
                                      return FlSpot(day.toDouble(), value);
                                    }).toList(),
                                    isCurved: true,
                                    color: AppColors.primaryColor1,
                                    barWidth: 3,
                                    belowBarData: BarAreaData(show: true, color: AppColors.primaryColor1.withOpacity(0.3)),
                                  ),
                                ],
                                minX: 1,
                                maxX: 31,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }
} 
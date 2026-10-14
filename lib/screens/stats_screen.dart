import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/school_data.dart';
import '../models/attendance.dart';
import '../theme/app_theme.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<SchoolDataProvider>();
    final att = context.watch<AttendanceProvider>();

    int totalStudents = data.students.length;
    int totalTeachers = data.teachers.length;

    final studentsPerClass = data.classes
        .map((c) => MapEntry(c, data.studentsOf(c).length))
        .toList();

    int totalAbsent = 0;
    for (final date in att.attendance.keys) {
      for (final cls in att.attendance[date]!.keys) {
        for (final student in att.attendance[date]![cls]!.keys) {
          if (att.attendance[date]![cls]![student] == 'absent') totalAbsent++;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkNavy,
        title: const Text("الإحصائيات",
            style: TextStyle(color: AppColors.gold, fontFamily: 'Changa')),
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Row(children: [
                _statCard("الطلاب", "$totalStudents", Icons.school,
                    AppColors.blue),
                const SizedBox(width: 10),
                _statCard("المعلمون", "$totalTeachers", Icons.person,
                    AppColors.green),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                _statCard("الفصول", "${data.classes.length}",
                    Icons.class_, AppColors.orange),
                const SizedBox(width: 10),
                _statCard("حالات الغياب", "$totalAbsent",
                    Icons.event_busy, AppColors.red),
              ]),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.darkNavy,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text("عدد الطلاب في كل فصل",
                        style: TextStyle(
                            color: AppColors.gold,
                            fontSize: 16,
                            fontFamily: 'Changa',
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 250,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: false),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(
                                sideTitles:
                                    SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles:
                                    SideTitles(showTitles: false)),
                            leftTitles: const AxisTitles(
                                sideTitles:
                                    SideTitles(showTitles: true)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (v, meta) {
                                  final i = v.toInt();
                                  if (i < 0 ||
                                      i >= studentsPerClass.length) {
                                    return const SizedBox();
                                  }
                                  return Text(
                                    studentsPerClass[i].key.length > 8
                                        ? studentsPerClass[i].key
                                            .substring(0, 8)
                                        : studentsPerClass[i].key,
                                    style: const TextStyle(
                                        color: AppColors.gold,
                                        fontSize: 10,
                                        fontFamily: 'Changa'),
                                  );
                                },
                              ),
                            ),
                          ),
                          barGroups: List.generate(
                            studentsPerClass.length,
                            (i) => BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: studentsPerClass[i]
                                      .value
                                      .toDouble(),
                                  color: AppColors.gold,
                                  width: 22,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.darkNavy,
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'Changa',
                    fontWeight: FontWeight.bold)),
            Text(label,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontFamily: 'Changa')),
          ],
        ),
      ),
    );
  }
}

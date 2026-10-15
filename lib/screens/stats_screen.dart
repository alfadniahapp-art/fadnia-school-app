import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/school_data.dart';
import '../models/settings.dart';
import '../models/attendance.dart';
import '../models/fees.dart';
import '../theme/app_theme.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<SchoolDataProvider>();
    final settings = context.watch<SettingsProvider>();
    final att = context.watch<AttendanceProvider>();
    final fees = context.watch<FeesProvider>();

    final primary = settings.primaryColor;
    final currency = settings.currencySymbol;

    final totalStudents = data.students.length;
    final totalTeachers = data.teachers.length;
    final totalGuardians = data.guardians.length;

    final studentsPerClass = data.classes
        .map((c) => MapEntry(c, data.studentsOf(c).length))
        .toList();

    int totalAbsent = 0;
    for (final date in att.attendance.keys) {
      for (final cls in att.attendance[date]!.keys) {
        for (final student in att.attendance[date]![cls]!.keys) {
          if (att.attendance[date]![cls]![student] == 'absent') {
            totalAbsent++;
          }
        }
      }
    }

    final totalCollected = fees.totalCollected();
    final totalRemaining = fees.totalRemaining();
    final totalExpected = fees.totalExpected();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: settings.backgroundColor,
        title: Text("الإحصائيات",
            style: TextStyle(
                color: primary, fontFamily: 'Changa')),
        iconTheme: IconThemeData(color: primary),
      ),
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              // ============ إحصائيات رئيسية ============
              Row(children: [
                _statCard("الطلاب", "$totalStudents",
                    Icons.school, AppColors.blue, primary),
                const SizedBox(width: 10),
                _statCard("المعلمون", "$totalTeachers",
                    Icons.person, AppColors.green, primary),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                _statCard("أولياء الأمور", "$totalGuardians",
                    Icons.family_restroom, AppColors.orange, primary),
                const SizedBox(width: 10),
                _statCard("الفصول", "${data.classes.length}",
                    Icons.class_, AppColors.blue, primary),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                _statCard("الغياب", "$totalAbsent",
                    Icons.event_busy, AppColors.red, primary),
                const SizedBox(width: 10),
                _statCard("المواد", "${_totalSubjects(data)}",
                    Icons.book, AppColors.green, primary),
              ]),

              // ============ مخطط الطلاب لكل فصل ============
              const SizedBox(height: 20),
              _chartContainer(
                title: "📊 عدد الطلاب في كل فصل",
                child: studentsPerClass.isEmpty
                    ? const Text("لا توجد بيانات",
                        style: TextStyle(
                            color: Colors.white54,
                            fontFamily: 'Changa'))
                    : SizedBox(
                        height: 220,
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
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  getTitlesWidget: (v, meta) => Text(
                                    v.toInt().toString(),
                                    style: TextStyle(
                                        color: primary, fontSize: 10),
                                  ),
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (v, meta) {
                                    final i = v.toInt();
                                    if (i < 0 ||
                                        i >= studentsPerClass.length) {
                                      return const SizedBox();
                                    }
                                    final name =
                                        studentsPerClass[i].key;
                                    return Text(
                                      name.length > 8
                                          ? name.substring(0, 8)
                                          : name,
                                      style: TextStyle(
                                          color: primary,
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
                                    color: primary,
                                    width: 22,
                                    borderRadius:
                                        BorderRadius.circular(6),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
              ),

              // ============ ملخص مالي ============
              const SizedBox(height: 15),
              _chartContainer(
                title: "💰 الملخص المالي",
                child: Column(
                  children: [
                    _moneyRow("📋 إجمالي المطلوب",
                        _fmt(totalExpected, currency), AppColors.blue),
                    _moneyRow("✅ المحصّل",
                        _fmt(totalCollected, currency), AppColors.green),
                    _moneyRow("⏳ المتبقي",
                        _fmt(totalRemaining, currency), AppColors.red),
                    const Divider(color: AppColors.border),
                    _moneyRow(
                      "🎁 الإعفاءات",
                      _fmt(fees.totalExemptions(), currency),
                      AppColors.orange,
                    ),
                    const SizedBox(height: 10),
                    // شريط تقدم
                    if (totalExpected > 0)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "نسبة التحصيل: ${((totalCollected / totalExpected) * 100).toStringAsFixed(1)}%",
                            style: TextStyle(
                                color: primary,
                                fontFamily: 'Changa',
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: totalCollected / totalExpected,
                              minHeight: 12,
                              backgroundColor: AppColors.border,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  primary),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // ============ أعلى تحصيل ============
              const SizedBox(height: 15),
              _chartContainer(
                title: "🏆 أكثر الفصول تحصيلاً",
                child: _topPayingClasses(
                    data, fees, currency, primary),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  int _totalSubjects(SchoolDataProvider data) {
    int total = 0;
    for (final c in data.classes) {
      total += data.subjectsOf(c).length;
    }
    return total;
  }

  String _fmt(double v, String c) => '${v.toStringAsFixed(0)} $c';

  Widget _statCard(String label, String value, IconData icon,
      Color color, Color primary) {
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
                    fontSize: 12,
                    fontFamily: 'Changa')),
          ],
        ),
      ),
    );
  }

  Widget _chartContainer(
      {required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.darkNavy,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 16,
                  fontFamily: 'Changa',
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  Widget _moneyRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white70,
                    fontFamily: 'Changa',
                    fontSize: 13)),
          ),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontFamily: 'Changa',
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ],
      ),
    );
  }

  Widget _topPayingClasses(SchoolDataProvider data, FeesProvider fees,
      String currency, Color primary) {
    final list = data.classes.map((c) {
      final total = fees
          .forClass(c)
          .fold(0.0, (s, r) => s + r.paidAmount);
      return MapEntry(c, total);
    }).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (list.isEmpty || list.every((e) => e.value == 0)) {
      return const Text("لا توجد بيانات",
          style: TextStyle(
              color: Colors.white54, fontFamily: 'Changa'));
    }

    return Column(
      children: list.take(5).map((e) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(e.key,
                    style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Changa',
                        fontSize: 13)),
              ),
              Text(_fmt(e.value, currency),
                  style: TextStyle(
                      color: primary,
                      fontFamily: 'Changa',
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

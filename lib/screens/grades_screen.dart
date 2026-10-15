import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/school_data.dart';
import '../models/settings.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});
  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  String? _cls;
  String _search = '';
  bool _sortByAvg = false;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<SchoolDataProvider>();
    final settings = context.watch<SettingsProvider>();
    _cls ??= data.classes.first;
    final allStudents = data.studentsOf(_cls!);
    final subjects = data.subjectsOf(_cls!);

    // فلترة + ترتيب
    var students = allStudents.where((s) {
      if (_search.isEmpty) return true;
      return s.name.contains(_search);
    }).toList();

    if (_sortByAvg) {
      students.sort((a, b) {
        return _avg(data, a.name, subjects)
            .compareTo(_avg(data, b.name, subjects));
      });
      students = students.reversed.toList();
    }

    // إحصائيات
    int excellent = 0;
    int failed = 0;
    double classTotal = 0;
    for (final s in allStudents) {
      final a = _avg(data, s.name, subjects);
      classTotal += a;
      if (a >= 90) excellent++;
      if (a < 50 && a > 0) failed++;
    }
    final classAvg =
        allStudents.isEmpty ? 0.0 : classTotal / allStudents.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: settings.backgroundColor,
        title: Text("درجات الطلاب",
            style: TextStyle(
                color: settings.primaryColor, fontFamily: 'Changa')),
        iconTheme: IconThemeData(color: settings.primaryColor),
        actions: [
          IconButton(
            icon: Icon(
              _sortByAvg ? Icons.sort : Icons.sort_outlined,
              color: settings.primaryColor,
            ),
            tooltip: _sortByAvg ? "إلغاء الترتيب" : "ترتيب حسب المعدل",
            onPressed: () => setState(() => _sortByAvg = !_sortByAvg),
          ),
        ],
      ),
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              const CustomLabel("الفصل:"),
              DropdownButtonFormField<String>(
                value: _cls,
                isExpanded: true,
                dropdownColor: AppColors.darkNavy,
                items: data.classes
                    .map((c) =>
                        DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _cls = v),
              ),
              const SizedBox(height: 10),

              // ============ ملخص ============
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.darkNavy,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _stat("📊", "معدل الفصل",
                        classAvg.toStringAsFixed(1),
                        settings.primaryColor),
                    _stat("🏆", "متفوق", "$excellent",
                        AppColors.green),
                    _stat("⚠️", "ضعيف", "$failed",
                        AppColors.red),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // ============ البحث ============
              if (students.isNotEmpty)
                TextField(
                  onChanged: (v) => setState(() => _search = v),
                  decoration: InputDecoration(
                    hintText: "🔍 ابحث عن طالب",
                    prefixIcon: Icon(Icons.search,
                        color: settings.primaryColor),
                    isDense: true,
                  ),
                ),
              const SizedBox(height: 10),

              // ============ الجدول ============
              Expanded(
                child: students.isEmpty || subjects.isEmpty
                    ? Center(
                        child: Text(
                          students.isEmpty
                              ? "أضف طلاباً أولاً"
                              : "أضف مواد أولاً من شاشة المواد",
                          style: const TextStyle(
                              color: Colors.white54,
                              fontFamily: 'Changa'),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(
                                settings.backgroundColor),
                            border: TableBorder.all(
                                color: AppColors.border),
                            columnSpacing: 10,
                            headingTextStyle: TextStyle(
                              color: settings.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              fontFamily: 'Changa',
                            ),
                            dataTextStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontFamily: 'Changa',
                            ),
                            columns: [
                              const DataColumn(label: Text("#")),
                              const DataColumn(label: Text("الطالب")),
                              ...subjects
                                  .map((s) => DataColumn(label: Text(s))),
                              const DataColumn(label: Text("المعدل")),
                            ],
                            rows: List.generate(students.length, (i) {
                              final s = students[i];
                              final avg =
                                  _avg(data, s.name, subjects);

                              return DataRow(cells: [
                                DataCell(Text('${i + 1}',
                                    style: TextStyle(
                                        color: settings.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Changa'))),
                                DataCell(Text(s.name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Changa'))),
                                ...subjects.map((subj) {
                                  return DataCell(
                                    InkWell(
                                      onTap: () => _editGrade(context,
                                          data, _cls!, s.name, subj),
                                      child: Container(
                                        padding:
                                            const EdgeInsets.all(6),
                                        constraints:
                                            const BoxConstraints(
                                                minWidth: 36),
                                        child: Text(
                                          data.getGrade(_cls!, s.name,
                                                  subj)
                                              ?.toStringAsFixed(0) ??
                                              '-',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Changa'),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                                DataCell(Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _avgColor(avg).withOpacity(0.2),
                                    border: Border.all(
                                        color: _avgColor(avg)),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    avg == 0
                                        ? '-'
                                        : avg.toStringAsFixed(1),
                                    style: TextStyle(
                                        color: _avgColor(avg),
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Changa',
                                        fontSize: 12),
                                  ),
                                )),
                              ]);
                            }),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _avg(SchoolDataProvider data, String student,
      List<String> subjects) {
    double sum = 0;
    int count = 0;
    for (final s in subjects) {
      final g = data.getGrade(_cls!, student, s);
      if (g != null) {
        sum += g;
        count++;
      }
    }
    return count == 0 ? 0 : sum / count;
  }

  Color _avgColor(double avg) {
    if (avg >= 90) return AppColors.green;
    if (avg >= 75) return AppColors.blue;
    if (avg >= 50) return AppColors.orange;
    if (avg > 0) return AppColors.red;
    return Colors.white54;
  }

  Widget _stat(String emoji, String label, String value, Color color) {
    return Column(children: [
      Text(emoji, style: const TextStyle(fontSize: 20)),
      Text(value,
          style: TextStyle(
              color: color,
              fontFamily: 'Changa',
              fontWeight: FontWeight.bold,
              fontSize: 16)),
      Text(label,
          style: const TextStyle(
              color: Colors.white54,
              fontFamily: 'Changa',
              fontSize: 10)),
    ]);
  }

  void _editGrade(BuildContext context, SchoolDataProvider data,
      String cls, String student, String subj) {
    final ctrl = TextEditingController(
      text: data.getGrade(cls, student, subj)?.toStringAsFixed(0) ?? '',
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkNavy,
        title: Text("$student - $subj",
            style: const TextStyle(
                color: AppColors.gold,
                fontFamily: 'Changa',
                fontSize: 15)),
        content: TextField(
          controller: ctrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: const InputDecoration(hintText: "أدخل الدرجة (0-100)"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              final v = double.tryParse(ctrl.text);
              if (v != null) {
                data.setGrade(cls, student, subj, v);
              }
              Navigator.pop(context);
            },
            child: const Text("حفظ",
                style: TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );
  }
}

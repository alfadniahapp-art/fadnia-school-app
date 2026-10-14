import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/school_data.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});
  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  String? _cls;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<SchoolDataProvider>();
    _cls ??= data.classes.first;
    final students = data.studentsOf(_cls!);
    final subjects = data.subjectsOf(_cls!);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkNavy,
        title: const Text("درجات الطلاب",
            style: TextStyle(color: AppColors.gold, fontFamily: 'Changa')),
        iconTheme: const IconThemeData(color: AppColors.gold),
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
              Expanded(
                child: students.isEmpty || subjects.isEmpty
                    ? Center(
                        child: Text(
                          students.isEmpty
                              ? "أضف طلاباً أولاً من شاشة قائمة الطلاب"
                              : "أضف مواد أولاً من شاشة تقسيم المواد",
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
                            headingRowColor:
                                MaterialStateProperty.all(AppColors.navy),
                            border:
                                TableBorder.all(color: AppColors.border),
                            headingTextStyle: const TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              fontFamily: 'Changa',
                            ),
                            dataTextStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Changa',
                            ),
                            columns: [
                              const DataColumn(label: Text("الطالب")),
                              ...subjects
                                  .map((s) => DataColumn(label: Text(s))),
                              const DataColumn(label: Text("المعدل")),
                            ],
                            rows: students.map((s) {
                              double sum = 0;
                              int count = 0;
                              for (final subj in subjects) {
                                final g = data.getGrade(
                                    _cls!, s.name, subj);
                                if (g != null) {
                                  sum += g;
                                  count++;
                                }
                              }
                              final avg = count == 0
                                  ? '-'
                                  : (sum / count).toStringAsFixed(1);

                              return DataRow(cells: [
                                DataCell(Text(s.name,
                                    style: const TextStyle(
                                        color: AppColors.gold,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Changa'))),
                                ...subjects.map((subj) {
                                  return DataCell(
                                    InkWell(
                                      onTap: () => _editGrade(context, data,
                                          _cls!, s.name, subj),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        constraints: const BoxConstraints(
                                            minWidth: 40),
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
                                DataCell(Text(avg,
                                    style: const TextStyle(
                                        color: AppColors.blue,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Changa'))),
                              ]);
                            }).toList(),
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
                color: AppColors.gold, fontFamily: 'Changa', fontSize: 16)),
        content: TextField(
          controller: ctrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(hintText: "أدخل الدرجة"),
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

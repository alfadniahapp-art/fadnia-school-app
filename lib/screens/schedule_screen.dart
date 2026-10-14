import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/school_data.dart';
import '../services/pdf_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Text("إدارة جدول الحصص", style: AppTheme.titleStyle),
                const Spacer(),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    children: [
                      Row(children: [
                        NavButton(
                          label: "حصص الجدول",
                          height: 60,
                          icon: Icons.edit_calendar,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const InputLessonScreen()),
                          ),
                        ),
                        const SizedBox(width: 12),
                        NavButton(
                          label: "الجدول",
                          height: 60,
                          icon: Icons.table_chart,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ViewScheduleScreen()),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        NavButton(
                          label: "تراجع",
                          height: 60,
                          icon: Icons.arrow_back,
                          onTap: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 12),
                        NavButton(
                          label: "✕ إغلاق",
                          height: 60,
                          isExit: true,
                          onTap: () => Navigator.popUntil(
                              context, (r) => r.isFirst),
                        ),
                      ]),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InputLessonScreen extends StatefulWidget {
  const InputLessonScreen({super.key});
  @override
  State<InputLessonScreen> createState() => _InputLessonScreenState();
}

class _InputLessonScreenState extends State<InputLessonScreen> {
  String? _cls;
  String _day = "الأحد";
  String _lesson = "الأولى";
  String? _assignment;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<SchoolDataProvider>();
    _cls ??= data.classes.first;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkNavy,
        title: const Text("حصص الجدول",
            style: TextStyle(color: AppColors.gold, fontFamily: 'Changa')),
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: SingleChildScrollView(
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
                Row(children: [
                  Expanded(
                    child: Column(children: [
                      const CustomLabel("اليوم:"),
                      DropdownButtonFormField<String>(
                        value: _day,
                        isExpanded: true,
                        dropdownColor: AppColors.darkNavy,
                        items: data.days
                            .map((d) => DropdownMenuItem(
                                value: d, child: Text(d)))
                            .toList(),
                        onChanged: (v) => setState(() => _day = v!),
                      ),
                    ]),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(children: [
                      const CustomLabel("الحصة:"),
                      DropdownButtonFormField<String>(
                        value: _lesson,
                        isExpanded: true,
                        dropdownColor: AppColors.darkNavy,
                        items: data.lessons
                            .map((l) => DropdownMenuItem(
                                value: l, child: Text(l)))
                            .toList(),
                        onChanged: (v) => setState(() => _lesson = v!),
                      ),
                    ]),
                  ),
                ]),
                const CustomLabel("المعلم والمادة:"),
                DropdownButtonFormField<String>(
                  value: _assignment,
                  isExpanded: true,
                  dropdownColor: AppColors.darkNavy,
                  hint: const Text("اختر"),
                  items: data.teachers
                      .map((t) => DropdownMenuItem(
                            value: t.display,
                            child: Text(t.display),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _assignment = v),
                ),
                const SizedBox(height: 20),
                SuccessButton(
                  label: "حفظ الحصة في الجدول",
                  icon: Icons.save,
                  onTap: () {
                    if (_assignment == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("اختر المعلم والمادة أولاً"),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }
                    context.read<SchoolDataProvider>().assignLesson(
                          cls: _cls!,
                          day: _day,
                          lesson: _lesson,
                          value: _assignment!,
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("تم الحفظ بنجاح ✓"),
                        backgroundColor: AppColors.green,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ViewScheduleScreen extends StatefulWidget {
  const ViewScheduleScreen({super.key});
  @override
  State<ViewScheduleScreen> createState() => _ViewScheduleScreenState();
}

class _ViewScheduleScreenState extends State<ViewScheduleScreen> {
  String? _cls;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<SchoolDataProvider>();
    _cls ??= data.classes.first;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkNavy,
        title: const Text("عرض الجدول",
            style: TextStyle(color: AppColors.gold, fontFamily: 'Changa')),
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Row(children: [
                const Text("الفصل:",
                    style: TextStyle(
                        color: AppColors.gold,
                        fontFamily: 'Changa',
                        fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _cls,
                    isExpanded: true,
                    dropdownColor: AppColors.darkNavy,
                    items: data.classes
                        .map((c) => DropdownMenuItem(
                            value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _cls = v),
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              Expanded(child: _buildTable(data)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: SuccessButton(
                    label: "📱 عرض أفقي",
                    color: AppColors.orange,
                    icon: Icons.screen_rotation,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LandscapeScheduleScreen(cls: _cls!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SuccessButton(
                    label: "🖨️ طباعة PDF",
                    color: AppColors.blue,
                    icon: Icons.print,
                    onTap: () => PdfService.printSchedule(data, _cls!),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTable(SchoolDataProvider data) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF080F22),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(AppColors.navy),
            border: TableBorder.all(color: AppColors.border),
            columnSpacing: 12,
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
              const DataColumn(label: Text("اليوم")),
              ...data.lessons.map((l) => DataColumn(label: Text(l))),
            ],
            rows: data.days.map((d) {
              return DataRow(cells: [
                DataCell(Text(d,
                    style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Changa'))),
                ...data.lessons.map((l) => DataCell(
                      Text(data.getLesson(_cls!, d, l)),
                    )),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class LandscapeScheduleScreen extends StatelessWidget {
  final String cls;
  const LandscapeScheduleScreen({super.key, required this.cls});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<SchoolDataProvider>();
    final reversedLessons = data.lessons.reversed.toList();

    return Scaffold(
      backgroundColor: AppColors.darkest,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "جدول حصص: $cls",
                      style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 15,
                          fontFamily: 'Changa'),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("✕ إغلاق",
                        style: TextStyle(fontFamily: 'Changa')),
                  ),
                ],
              ),
              const Divider(color: AppColors.gold, thickness: 2),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.gold, width: 2),
                    color: const Color(0xFF080F22),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        headingRowColor:
                            MaterialStateProperty.all(AppColors.navy),
                        border: TableBorder.all(
                          color: AppColors.border,
                          style: BorderStyle.solid,
                        ),
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
                          const DataColumn(label: Text("اليوم")),
                          ...reversedLessons
                              .map((l) => DataColumn(label: Text(l))),
                        ],
                        rows: data.days.map((d) {
                          return DataRow(cells: [
                            DataCell(Text(d,
                                style: const TextStyle(
                                    color: AppColors.gold,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Changa'))),
                            ...reversedLessons.map((l) => DataCell(
                                  Text(data.getLesson(cls, d, l)),
                                )),
                          ]);
                        }).toList(),
                      ),
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
}

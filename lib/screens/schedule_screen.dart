import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/school_data.dart';
import '../models/settings.dart';
import '../services/pdf_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return Scaffold(
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Text("إدارة جدول الحصص",
                    style: TextStyle(
                        color: settings.primaryColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Changa')),
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

// ============ شاشة إدخال الحصة ============
class InputLessonScreen extends StatefulWidget {
  const InputLessonScreen({super.key});
  @override
  State<InputLessonScreen> createState() => _InputLessonScreenState();
}

class _InputLessonScreenState extends State<InputLessonScreen> {
  String? _cls;
  String _day = "الأحد";
  String _lesson = "الأولى";
  String? _teacher;
  String? _subject;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<SchoolDataProvider>();
    final settings = context.watch<SettingsProvider>();
    _cls ??= data.classes.first;
    final subjects = data.subjectsOf(_cls!);
    final teachers = _subject == null
        ? data.teachers
        : data.teachersForSubject(_subject!);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: settings.backgroundColor,
        title: Text("حصص الجدول",
            style: TextStyle(
                color: settings.primaryColor, fontFamily: 'Changa')),
        iconTheme: IconThemeData(color: settings.primaryColor),
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
                  onChanged: (v) => setState(() {
                    _cls = v;
                    _subject = null;
                    _teacher = null;
                  }),
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
                const CustomLabel("المادة:"),
                if (subjects.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      border: Border.all(color: Colors.redAccent),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                        "⚠️ لا توجد مواد لهذا الفصل. أضف مواد أولاً من شاشة المواد.",
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontFamily: 'Changa')),
                  )
                else
                  DropdownButtonFormField<String>(
                    value: _subject,
                    isExpanded: true,
                    dropdownColor: AppColors.darkNavy,
                    hint: const Text("اختر المادة"),
                    items: subjects
                        .map((s) => DropdownMenuItem(
                            value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() {
                      _subject = v;
                      _teacher = null;
                    }),
                  ),
                const CustomLabel("المعلم:"),
                if (_subject == null)
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text("اختر المادة أولاً",
                        style: TextStyle(
                            color: Colors.white54,
                            fontFamily: 'Changa')),
                  )
                else if (teachers.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      border: Border.all(color: Colors.orange),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                        "⚠️ لا يوجد معلم لهذه المادة. أضف المواد للمعلمين.",
                        style: TextStyle(
                            color: Colors.orange, fontFamily: 'Changa')),
                  )
                else
                  DropdownButtonFormField<String>(
                    value: _teacher,
                    isExpanded: true,
                    dropdownColor: AppColors.darkNavy,
                    hint: const Text("اختر المعلم"),
                    items: teachers
                        .map((t) => DropdownMenuItem(
                            value: t.name, child: Text(t.name)))
                        .toList(),
                    onChanged: (v) => setState(() => _teacher = v),
                  ),
                const SizedBox(height: 20),
                SuccessButton(
                  label: "حفظ الحصة في الجدول",
                  icon: Icons.save,
                  onTap: () {
                    if (_subject == null || _teacher == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("اختر المادة والمعلم أولاً"),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }
                    // 🔍 منع التعارض
                    final conflict = _checkConflict(data, _teacher!);
                    if (conflict != null) {
                      _showConflictDialog(context, conflict);
                      return;
                    }
                    context.read<SchoolDataProvider>().assignLesson(
                          cls: _cls!,
                          day: _day,
                          lesson: _lesson,
                          value: "$_subject - $_teacher",
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

  String? _checkConflict(SchoolDataProvider data, String teacher) {
    for (final c in data.classes) {
      if (c == _cls) continue;
      final val = data.schedule[c]?[_day]?[_lesson];
      if (val != null && val.contains(teacher)) {
        return "المعلم $teacher مُسجّل في نفس الحصة في فصل: $c";
      }
    }
    return null;
  }

  void _showConflictDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkNavy,
        title: const Text("⚠️ تعارض",
            style: TextStyle(
                color: Colors.orange, fontFamily: 'Changa')),
        content: Text(message,
            style: const TextStyle(
                color: Colors.white, fontFamily: 'Changa')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("حسناً"),
          ),
        ],
      ),
    );
  }
}

// ============ شاشة عرض الجدول ============
class ViewScheduleScreen extends StatefulWidget {
  const ViewScheduleScreen({super.key});
  @override
  State<ViewScheduleScreen> createState() => _ViewScheduleScreenState();
}

class _ViewScheduleScreenState extends State<ViewScheduleScreen> {
  String? _cls;
  bool _isLandscape = false;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<SchoolDataProvider>();
    final settings = context.watch<SettingsProvider>();
    _cls ??= data.classes.first;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: settings.backgroundColor,
        title: Text("عرض الجدول",
            style: TextStyle(
                color: settings.primaryColor, fontFamily: 'Changa')),
        iconTheme: IconThemeData(color: settings.primaryColor),
        actions: [
          IconButton(
            icon: Icon(
                _isLandscape ? Icons.stay_current_portrait : Icons.screen_rotation,
                color: settings.primaryColor),
            tooltip: _isLandscape ? "عرض رأسي" : "عرض أفقي",
            onPressed: () =>
                setState(() => _isLandscape = !_isLandscape),
          ),
        ],
      ),
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Row(children: [
                Text("الفصل:",
                    style: TextStyle(
                        color: settings.primaryColor,
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
              Expanded(child: _buildTable(data, settings)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: SuccessButton(
                    label: _isLandscape
                        ? "📱 عرض رأسي"
                        : "📺 عرض أفقي",
                    color: AppColors.orange,
                    icon: Icons.screen_rotation,
                    onTap: () =>
                        setState(() => _isLandscape = !_isLandscape),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SuccessButton(
                    label: "🖨️ طباعة PDF",
                    color: AppColors.blue,
                    icon: Icons.print,
                    onTap: () => PdfService.printSchedule(
                      data,
                      _cls!,
                      isLandscape: _isLandscape,
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTable(SchoolDataProvider data, SettingsProvider settings) {
    final table = Container(
      decoration: BoxDecoration(
        color: const Color(0xFF080F22),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor:
                MaterialStateProperty.all(settings.backgroundColor),
            border: TableBorder.all(color: AppColors.border),
            columnSpacing: 12,
            headingTextStyle: TextStyle(
              color: settings.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              fontFamily: 'Changa',
            ),
            dataTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontFamily: 'Changa',
            ),
            columns: [
              const DataColumn(label: Text("اليوم")),
              ...data.lessons.map((l) => DataColumn(label: Text(l))),
            ],
            rows: data.days.map((d) {
              return DataRow(cells: [
                DataCell(Text(d,
                    style: TextStyle(
                        color: settings.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Changa'))),
                ...data.lessons.map((l) => DataCell(
                      Text(data.getLesson(_cls!, d, l),
                          textAlign: TextAlign.center),
                    )),
              ]);
            }).toList(),
          ),
        ),
      ),
    );

    if (_isLandscape) {
      return RotatedBox(quarterTurns: 1, child: table);
    }
    return table;
  }
}

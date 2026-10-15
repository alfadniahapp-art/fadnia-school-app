import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/school_data.dart';
import '../models/settings.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class TeacherDailyScreen extends StatefulWidget {
  const TeacherDailyScreen({super.key});
  @override
  State<TeacherDailyScreen> createState() => _TeacherDailyScreenState();
}

class _TeacherDailyScreenState extends State<TeacherDailyScreen> {
  String? _teacher;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<SchoolDataProvider>();
    final settings = context.watch<SettingsProvider>();
    _teacher ??= data.teachers.isEmpty ? null : data.teachers.first.name;

    final today = _currentDayName(data.days);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: settings.backgroundColor,
        title: Text("جدول المعلم اليومي",
            style: TextStyle(
                color: settings.primaryColor, fontFamily: 'Changa')),
        iconTheme: IconThemeData(color: settings.primaryColor),
      ),
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              const CustomLabel("اختر المعلم:"),
              DropdownButtonFormField<String>(
                value: _teacher,
                isExpanded: true,
                dropdownColor: AppColors.darkNavy,
                items: data.teachers
                    .map((t) => DropdownMenuItem(
                        value: t.name, child: Text(t.name)))
                    .toList(),
                onChanged: (v) => setState(() => _teacher = v),
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: settings.primaryColor.withOpacity(0.1),
                  border: Border.all(color: settings.primaryColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.today,
                        color: settings.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _teacher ?? '—',
                      style: TextStyle(
                          color: settings.primaryColor,
                          fontFamily: 'Changa',
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                    const Spacer(),
                    Text(
                      today.isEmpty ? 'اليوم: عطلة' : 'اليوم: $today',
                      style: const TextStyle(
                          color: Colors.white70,
                          fontFamily: 'Changa',
                          fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: data.teachers.isEmpty || _teacher == null
                    ? const Center(
                        child: Text("لا يوجد معلمون",
                            style: TextStyle(
                                color: Colors.white54,
                                fontFamily: 'Changa')))
                    : ListView.builder(
                        itemCount: data.days.length,
                        itemBuilder: (_, i) {
                          final day = data.days[i];
                          final schedule =
                              data.getTeacherDaySchedule(_teacher!, day);
                          final isToday = day == today;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: AppColors.darkNavy,
                              border: Border.all(
                                  color: isToday
                                      ? settings.primaryColor
                                      : AppColors.border,
                                  width: isToday ? 2 : 1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ExpansionTile(
                              initiallyExpanded: isToday,
                              title: Row(
                                children: [
                                  Text(
                                    day,
                                    style: TextStyle(
                                        color: isToday
                                            ? settings.primaryColor
                                            : Colors.white,
                                        fontFamily: 'Changa',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  if (isToday) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: settings.primaryColor,
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                      child: const Text("اليوم",
                                          style: TextStyle(
                                              color: AppColors.darkest,
                                              fontSize: 10,
                                              fontFamily: 'Changa')),
                                    ),
                                  ],
                                  const Spacer(),
                                  Text("${schedule.length} حصة",
                                      style: const TextStyle(
                                          color: Colors.white54,
                                          fontFamily: 'Changa',
                                          fontSize: 12)),
                                ],
                              ),
                              iconColor: settings.primaryColor,
                              collapsedIconColor: settings.primaryColor,
                              children: schedule.isEmpty
                                  ? [
                                      const Padding(
                                        padding: EdgeInsets.all(15),
                                        child: Text("لا توجد حصص",
                                            style: TextStyle(
                                                color: Colors.white38,
                                                fontFamily: 'Changa')),
                                      )
                                    ]
                                  : data.lessons
                                      .where(
                                          (l) => schedule.containsKey(l))
                                      .map((lesson) {
                                      final cls = schedule[lesson];
                                      return ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: AppColors.navy,
                                          child: Text(
                                            lesson.substring(0, 2),
                                            style: const TextStyle(
                                                color: AppColors.gold,
                                                fontFamily: 'Changa',
                                                fontSize: 11),
                                          ),
                                        ),
                                        title: Text(cls!,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Changa')),
                                        subtitle: Text("الحصة $lesson",
                                            style: TextStyle(
                                                color:
                                                    settings.primaryColor,
                                                fontFamily: 'Changa',
                                                fontSize: 12)),
                                      );
                                    }).toList(),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _currentDayName(List<String> days) {
    const map = {
      7: "الأحد",
      1: "الإثنين",
      2: "الثلاثاء",
      3: "الأربعاء",
      4: "الخميس",
      5: "الجمعة",
      6: "السبت",
    };
    final name = map[DateTime.now().weekday];
    return days.contains(name) ? (name ?? '') : '';
  }
}

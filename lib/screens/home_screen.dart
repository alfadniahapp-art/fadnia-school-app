import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/school_data.dart';
import '../models/settings.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'schedule_screen.dart';
import 'teachers_screen.dart';
import 'subjects_screen.dart';
import 'students_screen.dart';
import 'grades_screen.dart';
import 'attendance_screen.dart';
import 'reports_screen.dart';
import 'certificates_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import 'calendar_screen.dart';
import 'fees_screen.dart';
import 'teacher_daily_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<SchoolDataProvider>();
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Row(
                  children: [
                    const SizedBox(width: 40),
                    Expanded(
                      child: Column(
                        children: [
                          Text(data.name, style: AppTheme.titleStyle),
                          Text("المرحلة ${data.stage} - ${data.type}",
                              style: AppTheme.subtitleStyle),
                          const SizedBox(height: 4),
                          Text(
                              "${settings.academicYear} | ${settings.semester}",
                              style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                  fontFamily: 'Changa')),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings,
                          color: AppColors.gold),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SettingsScreen()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    children: [
                      Row(children: [
                        NavButton(
                          label: "جدول الحصص",
                          icon: Icons.calendar_month,
                          onTap: () => _nav(context, const ScheduleScreen()),
                        ),
                        const SizedBox(width: 12),
                        NavButton(
                          label: "المعلمون",
                          icon: Icons.person,
                          onTap: () => _nav(context, const TeachersScreen()),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        NavButton(
                          label: "المواد",
                          icon: Icons.book,
                          onTap: () => _nav(context, const SubjectsScreen()),
                        ),
                        const SizedBox(width: 12),
                        NavButton(
                          label: "الطلاب",
                          icon: Icons.school,
                          onTap: () => _nav(context, const StudentsScreen()),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        NavButton(
                          label: "الدرجات",
                          icon: Icons.grade,
                          onTap: () => _nav(context, const GradesScreen()),
                        ),
                        const SizedBox(width: 12),
                        NavButton(
                          label: "الغياب",
                          icon: Icons.event_busy,
                          onTap: () => _nav(context, const AttendanceScreen()),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        NavButton(
                          label: "التقويم",
                          icon: Icons.calendar_today,
                          onTap: () => _nav(context, const CalendarScreen()),
                        ),
                        const SizedBox(width: 12),
                        NavButton(
                          label: "الرسوم",
                          icon: Icons.attach_money,
                          onTap: () => _nav(context, const FeesScreen()),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        NavButton(
                          label: "جدول المعلم",
                          icon: Icons.person_pin_circle,
                          onTap: () => _nav(context, const TeacherDailyScreen()),
                        ),
                        const SizedBox(width: 12),
                        NavButton(
                          label: "الشهادات",
                          icon: Icons.card_membership,
                          onTap: () => _nav(context, const CertificatesScreen()),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        NavButton(
                          label: "التقارير",
                          icon: Icons.assessment,
                          onTap: () => _nav(context, const ReportsScreen()),
                        ),
                        const SizedBox(width: 12),
                        NavButton(
                          label: "الإحصائيات",
                          icon: Icons.bar_chart,
                          onTap: () => _nav(context, const StatsScreen()),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        NavButton(
                          label: "✕ تسجيل خروج",
                          isExit: true,
                          icon: Icons.exit_to_app,
                          onTap: () => _confirmExit(context),
                        ),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _nav(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkNavy,
        title: const Text("تأكيد",
            style: TextStyle(color: AppColors.gold, fontFamily: 'Changa')),
        content: const Text("هل تريد الخروج من الحساب؟",
            style: TextStyle(color: Colors.white, fontFamily: 'Changa')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء")),
          TextButton(
            onPressed: () async {
              await AuthService.setLoggedIn(false);
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (r) => false,
              );
            },
            child: const Text("خروج",
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

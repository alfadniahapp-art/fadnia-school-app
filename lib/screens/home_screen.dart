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
import 'guardians_screen.dart';
import 'grades_screen.dart';
import 'attendance_screen.dart';
import 'reports_screen.dart';
import 'certificates_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import 'calendar_screen.dart';
import 'fees_screen.dart';
import 'teacher_daily_screen.dart';
import 'employees_screen.dart';
import 'payroll_screen.dart';
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
                // ============ الترويسة ============
                Row(
                  children: [
                    const SizedBox(width: 40),
                    Expanded(
                      child: Column(
                        children: [
                          Text(data.name, style: AppTheme.titleStyle),
                          Text(
                            "المرحلة ${data.stage} - ${data.type}",
                            style: AppTheme.subtitleStyle,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${settings.academicYear} | ${settings.semester}",
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              fontFamily: 'Changa',
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.settings,
                          color: settings.primaryColor),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SettingsScreen()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ============ الأزرار الديناميكية ============
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    children: _buildButtons(context, settings),
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

  List<Widget> _buildButtons(
      BuildContext context, SettingsProvider settings) {
    final buttons = <Widget>[];

    void addRow(Widget? a, Widget? b) {
      if (a == null && b == null) return;
      if (a != null && b != null) {
        buttons.add(Row(children: [a, const SizedBox(width: 12), b]));
      } else {
        buttons.add(Row(children: [a ?? b!]));
      }
      buttons.add(const SizedBox(height: 12));
    }

    Widget? btn(String key, String label, IconData icon, Widget screen) {
      if (!settings.isEnabled(key)) return null;
      return NavButton(
        label: label,
        icon: icon,
        onTap: () => _nav(context, screen),
      );
    }

    // ========== 🏫 الأكاديمي ==========
    addRow(
      btn('schedule', 'جدول الحصص', Icons.calendar_month,
          const ScheduleScreen()),
      btn('teachers', 'المعلمون', Icons.person, const TeachersScreen()),
    );

    addRow(
      btn('subjects', 'المواد', Icons.book, const SubjectsScreen()),
      btn('students', 'الطلاب', Icons.school, const StudentsScreen()),
    );

    addRow(
      btn('guardians', 'أولياء الأمور', Icons.family_restroom,
          const GuardiansScreen()),
      btn('grades', 'الدرجات', Icons.grade, const GradesScreen()),
    );

    addRow(
      btn('attendance', 'الغياب', Icons.event_busy,
          const AttendanceScreen()),
      btn('calendar', 'التقويم', Icons.calendar_today,
          const CalendarScreen()),
    );

    // ========== 💰 المالية ==========
    addRow(
      btn('fees', 'رسوم الطلاب', Icons.attach_money,
          const FeesScreen()),
      btn('employees', 'الموظفون', Icons.badge, const EmployeesScreen()),
    );

    addRow(
      btn('payroll', 'كشف الرواتب', Icons.payments,
          const PayrollScreen()),
      btn('teacherDaily', 'جدول المعلم', Icons.person_pin_circle,
          const TeacherDailyScreen()),
    );

    // ========== 📊 التقارير ==========
    addRow(
      btn('certificates', 'الشهادات', Icons.card_membership,
          const CertificatesScreen()),
      btn('reports', 'التقارير', Icons.assessment,
          const ReportsScreen()),
    );

    addRow(
      btn('stats', 'الإحصائيات', Icons.bar_chart, const StatsScreen()),
      null,
    );

    // ========== 🚪 الخروج ==========
    buttons.add(Row(children: [
      NavButton(
        label: "✕ تسجيل خروج",
        isExit: true,
        icon: Icons.exit_to_app,
        onTap: () => _confirmExit(context),
      ),
    ]));

    return buttons;
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
            style: TextStyle(
                color: AppColors.gold, fontFamily: 'Changa')),
        content: const Text("هل تريد الخروج من الحساب؟",
            style: TextStyle(color: Colors.white, fontFamily: 'Changa')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
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

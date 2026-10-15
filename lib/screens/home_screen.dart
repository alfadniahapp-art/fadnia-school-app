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
import 'finance_screen.dart';
import 'themes_screen.dart';
import 'about_screen.dart';
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
                _header(context, data, settings),
                const SizedBox(height: 20),

                // ============ الأزرار ============
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    children: _buildAllSections(context, settings),
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

  Widget _header(BuildContext context, SchoolDataProvider data,
      SettingsProvider settings) {
    final primary = settings.primaryColor;

    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.info_outline, color: primary),
          tooltip: "حول التطبيق",
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AboutScreen()),
          ),
        ),
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
          icon: Icon(Icons.settings, color: primary),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAllSections(
      BuildContext context, SettingsProvider settings) {
    final all = <Widget>[];

    // ============ 🏫 القسم الأكاديمي ============
    final academic = <Widget>[
      _btn(context, settings, 'schedule', 'جدول الحصص',
          Icons.calendar_month, const ScheduleScreen()),
      _btn(context, settings, 'teachers', 'المعلمون',
          Icons.person, const TeachersScreen()),
      _btn(context, settings, 'subjects', 'المواد',
          Icons.book, const SubjectsScreen()),
      _btn(context, settings, 'students', 'الطلاب',
          Icons.school, const StudentsScreen()),
      _btn(context, settings, 'guardians', 'أولياء الأمور',
          Icons.family_restroom, const GuardiansScreen()),
      _btn(context, settings, 'grades', 'الدرجات',
          Icons.grade, const GradesScreen()),
      _btn(context, settings, 'attendance', 'الغياب',
          Icons.event_busy, const AttendanceScreen()),
      _btn(context, settings, 'calendar', 'التقويم',
          Icons.calendar_today, const CalendarScreen()),
      _btn(context, settings, 'teacherDaily', 'جدول المعلم',
          Icons.person_pin_circle, const TeacherDailyScreen()),
    ].whereType<Widget>().toList();

    if (academic.isNotEmpty) {
      all.add(_sectionTitle('🏫 الأكاديمي', settings.primaryColor));
      all.addAll(_pairRows(academic));
      all.add(const SizedBox(height: 12));
    }

    // ============ 📊 قسم التقارير ============
    final reports = <Widget>[
      _btn(context, settings, 'certificates', 'الشهادات',
          Icons.card_membership, const CertificatesScreen()),
      _btn(context, settings, 'reports', 'التقارير',
          Icons.assessment, const ReportsScreen()),
      _btn(context, settings, 'stats', 'الإحصائيات',
          Icons.bar_chart, const StatsScreen()),
    ].whereType<Widget>().toList();

    if (reports.isNotEmpty) {
      all.add(_sectionTitle('📊 التقارير', settings.primaryColor));
      all.addAll(_pairRows(reports));
      all.add(const SizedBox(height: 12));
    }

    // ============ 💰 القسم المالي ============
    final finance = <Widget>[
      _btn(context, settings, 'fees', 'رسوم الطلاب',
          Icons.attach_money, const FeesScreen()),
      _btn(context, settings, 'employees', 'الموظفون',
          Icons.badge, const EmployeesScreen()),
      _btn(context, settings, 'payroll', 'كشف الرواتب',
          Icons.payments, const PayrollScreen()),
    ].whereType<Widget>().toList();

    if (finance.isNotEmpty) {
      all.add(_sectionTitle('💰 المالية', settings.primaryColor));
      all.addAll(_pairRows(finance));

      // 🏦 زر الخزينة العامة — عريض بارز
      if (settings.isEnabled('finance')) {
        all.add(_bigTreasuryButton(context, settings));
      }
      all.add(const SizedBox(height: 12));
    }

    // ============ 🎨 قسم التخصيص ============
    all.add(_sectionTitle('🎨 التخصيص', settings.primaryColor));
    all.add(Row(children: [
      _customButton(
        context,
        label: 'الثيمات والألوان',
        icon: Icons.palette,
        color: settings.primaryColor,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ThemesScreen()),
        ),
      ),
    ]));
    all.add(const SizedBox(height: 12));

    // ============ 🚪 تسجيل الخروج ============
    all.add(Row(children: [
      NavButton(
        label: "✕ تسجيل خروج",
        isExit: true,
        icon: Icons.exit_to_app,
        onTap: () => _confirmExit(context),
      ),
    ]));

    return all;
  }

  /// تحويل قائمة الأزرار إلى صفوف (2 لكل صف)
  List<Widget> _pairRows(List<Widget> buttons) {
    final rows = <Widget>[];
    for (int i = 0; i < buttons.length; i += 2) {
      if (i + 1 < buttons.length) {
        rows.add(Row(children: [
          Expanded(child: buttons[i]),
          const SizedBox(width: 12),
          Expanded(child: buttons[i + 1]),
        ]));
      } else {
        rows.add(Row(children: [
          Expanded(child: buttons[i]),
          const SizedBox(width: 12),
          const Spacer(),
        ]));
      }
      rows.add(const SizedBox(height: 12));
    }
    return rows;
  }

  Widget _sectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(title,
            style: TextStyle(
                color: color,
                fontFamily: 'Changa',
                fontSize: 15,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _btn(BuildContext context, SettingsProvider settings,
      String key, String label, IconData icon, Widget screen) {
    if (!settings.isEnabled(key)) return const SizedBox.shrink();
    return NavButton(
      label: label,
      icon: icon,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen),
      ),
    );
  }

  Widget _customButton(BuildContext context,
      {required String label,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Ink(
            height: 55,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.2),
                  AppColors.darkNavy,
                ],
              ),
              border: Border.all(color: color, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 8),
                Text(label,
                    style: TextStyle(
                        color: color,
                        fontFamily: 'Changa',
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bigTreasuryButton(
      BuildContext context, SettingsProvider settings) {
    final primary = settings.primaryColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FinanceScreen()),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(
              vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primary.withOpacity(0.3),
                primary.withOpacity(0.08),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            border: Border.all(color: primary, width: 2),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.25),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.account_balance,
                    color: primary, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("الخزينة العامة",
                        style: TextStyle(
                            color: primary,
                            fontFamily: 'Changa',
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    const Text("الحسابات • الحركات • التقارير",
                        style: TextStyle(
                            color: Colors.white54,
                            fontFamily: 'Changa',
                            fontSize: 11)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  color: primary, size: 18),
            ],
          ),
        ),
      ),
    );
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
            style: TextStyle(
                color: Colors.white, fontFamily: 'Changa')),
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
                MaterialPageRoute(
                    builder: (_) => const LoginScreen()),
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

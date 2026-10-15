import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/school_data.dart';
import '../models/settings.dart';
import '../services/backup_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'welcome_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _semCtrl = TextEditingController();
  final _currencyCtrl = TextEditingController();
  final _workDaysCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = context.read<SettingsProvider>();
      final d = context.read<SchoolDataProvider>();
      _nameCtrl.text = d.name;
      _yearCtrl.text = s.academicYear;
      _semCtrl.text = s.semester;
      _currencyCtrl.text = s.currencySymbol;
      _workDaysCtrl.text = s.workDaysPerMonth.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    final d = context.watch<SchoolDataProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: s.backgroundColor,
        title: Text("الإعدادات",
            style: TextStyle(color: s.primaryColor, fontFamily: 'Changa')),
        iconTheme: IconThemeData(color: s.primaryColor),
      ),
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              // ============ 🏫 بيانات المدرسة ============
              _section("🏫 بيانات المدرسة", s.primaryColor),
              const CustomLabel("اسم المدرسة:"),
              TextField(controller: _nameCtrl),
              const CustomLabel("العام الدراسي:"),
              TextField(controller: _yearCtrl),
              const CustomLabel("الفصل الدراسي:"),
              TextField(controller: _semCtrl),
              const CustomLabel("أيام العمل في الشهر (للرواتب):"),
              TextField(
                controller: _workDaysCtrl,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(hintText: "22 يوم افتراضياً"),
              ),
              const SizedBox(height: 10),
              SuccessButton(
                label: "حفظ بيانات المدرسة",
                icon: Icons.save,
                onTap: () {
                  d.name = _nameCtrl.text;
                  d.saveData();
                  s.setYear(_yearCtrl.text);
                  s.setSemester(_semCtrl.text);
                  final days = int.tryParse(_workDaysCtrl.text);
                  if (days != null && days > 0) {
                    s.setWorkDays(days);
                  }
                  _snack(context, "تم الحفظ");
                },
              ),

              // ============ 💰 العملة ============
              _section("💰 العملة", s.primaryColor),
              const CustomLabel("رمز العملة:"),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _currencyCtrl,
                      decoration:
                          const InputDecoration(hintText: "مثال: ج.س"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      s.setCurrency(_currencyCtrl.text.trim());
                      _snack(context, "تم تغيير العملة");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: s.primaryColor.withOpacity(0.15),
                      side: BorderSide(color: s.primaryColor, width: 2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                    ),
                    child: Text("حفظ",
                        style: TextStyle(
                            color: s.primaryColor,
                            fontFamily: 'Changa',
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: ['ج.س', 'ر.س', 'ج.م', '\$', 'د.إ', 'ر.ق']
                    .map((c) => ChoiceChip(
                          label: Text(c,
                              style: TextStyle(
                                  color: s.currencySymbol == c
                                      ? AppColors.darkest
                                      : s.primaryColor,
                                  fontFamily: 'Changa')),
                          selected: s.currencySymbol == c,
                          selectedColor: s.primaryColor,
                          backgroundColor: AppColors.navy,
                          onSelected: (_) {
                            _currencyCtrl.text = c;
                            s.setCurrency(c);
                          },
                        ))
                    .toList(),
              ),

              // ============ 🎨 الألوان ============
              _section("🎨 اللون الأساسي", s.primaryColor),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _colorOption(context, s, 0xFFF1C40F, "ذهبي"),
                  _colorOption(context, s, 0xFF3498DB, "أزرق"),
                  _colorOption(context, s, 0xFF27AE60, "أخضر"),
                  _colorOption(context, s, 0xFFE74C3C, "أحمر"),
                  _colorOption(context, s, 0xFF9B59B6, "بنفسجي"),
                  _colorOption(context, s, 0xFFF39C12, "برتقالي"),
                  _colorOption(context, s, 0xFF1ABC9C, "فيروزي"),
                ],
              ),

              const SizedBox(height: 20),
              _section("🌈 لون الخلفية", s.primaryColor),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _bgOption(context, s, 0xFF0B132B, "كحلي داكن"),
                  _bgOption(context, s, 0xFF030817, "أسود"),
                  _bgOption(context, s, 0xFF1C1C1C, "رمادي"),
                  _bgOption(context, s, 0xFF2C1810, "بني داكن"),
                ],
              ),

              // ============ 🏫 القالب ============
              _section("🏫 حجم المدرسة (القالب)", s.primaryColor),
              _templateOption(context, s, "صغيرة",
                  "جدول، معلمون، طلاب، درجات"),
              _templateOption(context, s, "متوسطة",
                  "+ رسوم، أولياء أمور، غياب، موظفون، رواتب"),
              _templateOption(context, s, "كبيرة",
                  "+ الإحصائيات، جدول المعلم، شهادات، خزينة"),

              // ============ 📦 الوحدات ============
              _section("📦 تفعيل/تعطيل الأقسام", s.primaryColor),
              _subSection("🏫 أكاديمي", s.primaryColor),
              _moduleSwitch(s, 'schedule', 'جدول الحصص'),
              _moduleSwitch(s, 'teachers', 'المعلمون'),
              _moduleSwitch(s, 'subjects', 'المواد'),
              _moduleSwitch(s, 'students', 'الطلاب'),
              _moduleSwitch(s, 'guardians', 'أولياء الأمور'),
              _moduleSwitch(s, 'grades', 'الدرجات'),
              _moduleSwitch(s, 'attendance', 'الغياب'),
              _moduleSwitch(s, 'calendar', 'التقويم'),
              _moduleSwitch(s, 'teacherDaily', 'جدول المعلم'),

              _subSection("💰 مالية", s.primaryColor),
              _moduleSwitch(s, 'fees', 'رسوم الطلاب'),
              _moduleSwitch(s, 'employees', 'الموظفون'),
              _moduleSwitch(s, 'payroll', 'كشف الرواتب'),
              _moduleSwitch(s, 'finance', 'الخزينة العامة'),

              _subSection("📊 تقارير", s.primaryColor),
              _moduleSwitch(s, 'certificates', 'الشهادات'),
              _moduleSwitch(s, 'reports', 'التقارير'),
              _moduleSwitch(s, 'stats', 'الإحصائيات'),

              // ============ 🔒 الأمان ============
              _section("🔒 الأمان", s.primaryColor),
              const CustomLabel("كلمة المرور الجديدة:"),
              TextField(
                controller: _passCtrl,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(hintText: "اترك الحالي: 1234"),
              ),
              const SizedBox(height: 10),
              SuccessButton(
                label: "تغيير كلمة المرور",
                icon: Icons.lock,
                color: AppColors.orange,
                onTap: () {
                  if (_passCtrl.text.isNotEmpty) {
                    s.setPassword(_passCtrl.text);
                    _passCtrl.clear();
                    _snack(context, "تم تغيير كلمة المرور");
                  }
                },
              ),

              // ============ 🔔 الإشعارات ============
              _section("🔔 الإشعارات", s.primaryColor),
              SwitchListTile(
                title: const Text("تفعيل الإشعارات",
                    style: TextStyle(
                        color: Colors.white, fontFamily: 'Changa')),
                value: s.notificationsEnabled,
                activeColor: s.primaryColor,
                onChanged: (v) {
                  s.toggleNotifications(v);
                  if (v) {
                    NotificationService.show(
                        "Mulla", "الإشعارات مفعلة الآن");
                  }
                },
              ),

              // ============ 💾 النسخ الاحتياطي ============
              _section("💾 النسخ الاحتياطي", s.primaryColor),
              SuccessButton(
                label: "📤 تصدير نسخة احتياطية",
                icon: Icons.upload,
                color: AppColors.blue,
                onTap: () => BackupService.exportBackup(),
              ),
              const SizedBox(height: 8),
              SuccessButton(
                label: "📥 استيراد نسخة احتياطية",
                icon: Icons.download,
                color: AppColors.green,
                onTap: () async {
                  final ok = await BackupService.importBackup();
                  if (ok) {
                    await d.loadData();
                    if (!context.mounted) return;
                    _snack(context, "تم الاستيراد بنجاح");
                  }
                },
              ),

              // ============ ⚠️ منطقة الخطر ============
              const SizedBox(height: 20),
              _section("⚠️ منطقة الخطر", Colors.red),
              SuccessButton(
                label: "🗑️ حذف جميع البيانات",
                icon: Icons.delete_forever,
                color: Colors.red,
                onTap: () => _confirmClear(context, d),
              ),
              const SizedBox(height: 8),
              SuccessButton(
                label: "إعادة إدخال بيانات المدرسة",
                icon: Icons.refresh,
                color: AppColors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const WelcomeScreen()),
                  );
                },
              ),

              const SizedBox(height: 30),
              const Text("الإصدار 5.0.0",
                  style: TextStyle(
                      color: Colors.white38,
                      fontFamily: 'Changa',
                      fontSize: 12)),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(title,
            style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Changa')),
      ),
    );
  }

  Widget _subSection(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(title,
            style: TextStyle(
                color: color.withOpacity(0.7),
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFamily: 'Changa')),
      ),
    );
  }

  Widget _colorOption(BuildContext context, SettingsProvider s,
      int colorValue, String name) {
    final color = Color(colorValue);
    final selected = s.primaryColorValue == colorValue;
    return GestureDetector(
      onTap: () {
        s.setPrimaryColor(colorValue);
        _snack(context, "تم تغيير اللون إلى $name");
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? Colors.white : Colors.transparent,
            width: selected ? 4 : 0,
          ),
          boxShadow: selected
              ? [BoxShadow(color: color.withOpacity(0.7), blurRadius: 12)]
              : null,
        ),
        child: selected
            ? const Icon(Icons.check, color: Colors.white, size: 30)
            : null,
      ),
    );
  }

  Widget _bgOption(BuildContext context, SettingsProvider s,
      int colorValue, String name) {
    final color = Color(colorValue);
    final selected = s.backgroundColorValue == colorValue;
    return GestureDetector(
      onTap: () {
        s.setBackgroundColor(colorValue);
        _snack(context, "تم تغيير الخلفية إلى $name");
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? s.primaryColor : Colors.white24,
            width: selected ? 3 : 1,
          ),
        ),
        child: selected
            ? Icon(Icons.check, color: s.primaryColor, size: 26)
            : null,
      ),
    );
  }

  Widget _templateOption(BuildContext context, SettingsProvider s,
      String template, String desc) {
    final selected = s.schoolTemplate == template;
    return GestureDetector(
      onTap: () {
        s.setTemplate(template);
        _snack(context, "تم تطبيق قالب: $template");
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? s.primaryColor.withOpacity(0.15)
              : AppColors.darkNavy,
          border: Border.all(
            color: selected ? s.primaryColor : AppColors.border,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? s.primaryColor : Colors.white54,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(template,
                      style: TextStyle(
                          color: selected ? s.primaryColor : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Changa')),
                  Text(desc,
                      style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          fontFamily: 'Changa')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _moduleSwitch(SettingsProvider s, String key, String label) {
    return SwitchListTile(
      dense: true,
      title: Text(label,
          style: const TextStyle(
              color: Colors.white, fontFamily: 'Changa', fontSize: 14)),
      value: s.isEnabled(key),
      activeColor: s.primaryColor,
      onChanged: (v) => s.toggleModule(key, v),
    );
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.green),
    );
  }

  void _confirmClear(BuildContext context, SchoolDataProvider d) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkNavy,
        title: const Text("تأكيد الحذف",
            style: TextStyle(
                color: Colors.redAccent, fontFamily: 'Changa')),
        content: const Text(
            "سيتم حذف جميع البيانات نهائياً. هل أنت متأكد؟",
            style: TextStyle(color: Colors.white, fontFamily: 'Changa')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () async {
              await StorageService.clearAll();
              if (!context.mounted) return;
              Navigator.pop(context);
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) => const WelcomeScreen()),
                (r) => false,
              );
            },
            child: const Text("حذف",
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

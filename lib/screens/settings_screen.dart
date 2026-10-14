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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = context.read<SettingsProvider>();
      final d = context.read<SchoolDataProvider>();
      _nameCtrl.text = d.name;
      _yearCtrl.text = s.academicYear;
      _semCtrl.text = s.semester;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    final d = context.watch<SchoolDataProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkNavy,
        title: const Text("الإعدادات",
            style: TextStyle(color: AppColors.gold, fontFamily: 'Changa')),
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              _section("بيانات المدرسة"),
              const CustomLabel("اسم المدرسة:"),
              TextField(controller: _nameCtrl),
              const CustomLabel("العام الدراسي:"),
              TextField(controller: _yearCtrl),
              const CustomLabel("الفصل الدراسي:"),
              TextField(controller: _semCtrl),
              const SizedBox(height: 10),
              SuccessButton(
                label: "حفظ بيانات المدرسة",
                icon: Icons.save,
                onTap: () {
                  d.name = _nameCtrl.text;
                  d.saveData();
                  s.setYear(_yearCtrl.text);
                  s.setSemester(_semCtrl.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("تم الحفظ"),
                        backgroundColor: AppColors.green),
                  );
                },
              ),
              const SizedBox(height: 20),
              _section("الأمان"),
              const CustomLabel("كلمة المرور الجديدة:"),
              TextField(
                controller: _passCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: "اترك الحالي: 1234"),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("تم تغيير كلمة المرور"),
                          backgroundColor: AppColors.green),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              _section("الإشعارات"),
              SwitchListTile(
                title: const Text("تفعيل الإشعارات",
                    style: TextStyle(
                        color: Colors.white, fontFamily: 'Changa')),
                value: s.notificationsEnabled,
                activeColor: AppColors.gold,
                onChanged: (v) {
                  s.toggleNotifications(v);
                  if (v) {
                    NotificationService.show(
                        "Mulla", "الإشعارات مفعلة الآن");
                  }
                },
              ),
              const SizedBox(height: 20),
              _section("النسخ الاحتياطي"),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("تم الاستيراد بنجاح"),
                          backgroundColor: AppColors.green),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              _section("خطير"),
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
              const Text("الإصدار 3.0.0",
                  style: TextStyle(
                      color: Colors.white38,
                      fontFamily: 'Changa',
                      fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(title,
            style: const TextStyle(
                color: AppColors.gold,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Changa')),
      ),
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
        content: const Text("سيتم حذف جميع البيانات نهائياً. هل أنت متأكد؟",
            style: TextStyle(color: Colors.white, fontFamily: 'Changa')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء")),
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

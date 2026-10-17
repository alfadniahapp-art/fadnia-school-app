import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/defaults.dart';
import '../models/settings.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class DefaultsScreen extends StatelessWidget {
  const DefaultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    final d = context.watch<DefaultsProvider>();
    final primary = s.primaryColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: s.backgroundColor,
        title: Text("البيانات الافتراضية",
            style: TextStyle(color: primary, fontFamily: 'Changa')),
        iconTheme: IconThemeData(color: primary),
      ),
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              // ============ معلومات ============
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  border: Border.all(color: primary),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: primary, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "هنا تتحكم في كل القوائم الافتراضية للتطبيق\nالتغييرات تُحفظ تلقائياً",
                        style: TextStyle(
                            color: Colors.white70,
                            fontFamily: 'Changa',
                            fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // ============ قوائم البيانات ============
              _listSection(context, "📚 المواد السريعة",
                  'quickSubjects', d.quickSubjects, primary, d),
              _listSection(context, "👥 أنواع الموظفين",
                  'employeeTypes', d.employeeTypes, primary, d),
              _listSection(context, "🎁 بنود الحوافز",
                  'incomes', d.incomes, primary, d),
              _listSection(context, "➖ بنود الخصومات",
                  'deductions', d.deductions, primary, d),
              _listSection(context, "💰 بنود القبض",
                  'receipts', d.receipts, primary, d),
              _listSection(context, "💸 بنود الصرف",
                  'payments', d.payments, primary, d),

              const SizedBox(height: 20),

              // ============ زر الحفظ ============
              SuccessButton(
                label: "💾 حفظ التغييرات",
                icon: Icons.save,
                color: AppColors.green,
                onTap: () async {
                  await d.save();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Text("تم حفظ البيانات بنجاح ✓",
                              style: TextStyle(fontFamily: 'Changa')),
                        ],
                      ),
                      backgroundColor: AppColors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),

              // ============ زر إعادة التعيين ============
              SuccessButton(
                label: "🔄 إعادة التعيين للافتراضي",
                icon: Icons.refresh,
                color: AppColors.orange,
                onTap: () => _confirmReset(context, d),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listSection(BuildContext context, String title, String key,
      List<String> items, Color primary, DefaultsProvider d) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkNavy,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text("$title (${items.length})",
                    style: TextStyle(
                        color: primary,
                        fontFamily: 'Changa',
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ),
              IconButton(
                icon: Icon(Icons.add_circle, color: AppColors.green),
                onPressed: () => _addDialog(context, d, key, title),
              ),
            ],
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: items.asMap().entries.map((e) {
              return Chip(
                label: Text(e.value,
                    style: const TextStyle(
                        color: AppColors.darkest,
                        fontFamily: 'Changa',
                        fontSize: 12)),
                backgroundColor: primary,
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => d.removeItem(key, e.value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _addDialog(BuildContext context, DefaultsProvider d,
      String key, String title) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkNavy,
        title: Text("إضافة إلى $title",
            style: const TextStyle(
                color: AppColors.gold, fontFamily: 'Changa')),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: "الاسم الجديد"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              d.addItem(key, ctrl.text);
              Navigator.pop(context);
            },
            child: const Text("إضافة",
                style: TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, DefaultsProvider d) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkNavy,
        title: const Text("إعادة التعيين",
            style: TextStyle(
                color: Colors.orange, fontFamily: 'Changa')),
        content: const Text(
            "سيتم إرجاع كل القوائم للوضع الافتراضي. هل أنت متأكد؟",
            style: TextStyle(color: Colors.white, fontFamily: 'Changa')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              d.resetAll();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("تمت إعادة التعيين للافتراضي ✓",
                      style: TextStyle(fontFamily: 'Changa')),
                  backgroundColor: AppColors.orange,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text("تعيين",
                style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }
}

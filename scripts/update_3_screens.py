import os

# 1) شاشة البيانات الافتراضية
SCREEN_CONTENT = r'''import 'package:flutter/material.dart';
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
                        "هنا تتحكم في كل القوائم الافتراضية للتطبيق",
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
              _listSection(context, "📚 المواد السريعة",
                  'quickSubjects', d.quickSubjects, primary),
              _listSection(context, "👥 أنواع الموظفين",
                  'employeeTypes', d.employeeTypes, primary),
              _listSection(context, "🎁 بنود الحوافز",
                  'incomes', d.incomes, primary),
              _listSection(context, "➖ بنود الخصومات",
                  'deductions', d.deductions, primary),
              _listSection(context, "💰 بنود القبض",
                  'receipts', d.receipts, primary),
              _listSection(context, "💸 بنود الصرف",
                  'payments', d.payments, primary),
              const SizedBox(height: 20),
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
      List<String> items, Color primary) {
    final d = context.read<DefaultsProvider>();
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
                onPressed: () =>
                    _addDialog(context, d, key, title, primary),
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
                onDeleted: () {
                  d.removeItem(key, e.value);
                  d.save(context);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _addDialog(BuildContext context, DefaultsProvider d,
      String key, String title, Color primary) {
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
              d.save(context);
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
              d.save(context);
              Navigator.pop(context);
            },
            child: const Text("تعيين",
                style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }
}

extension DefaultsProviderExt on DefaultsProvider {
  Future<void> save(BuildContext context) async {
    // حفظ تلقائي عبر SettingsProvider
    // يتم في main عبر save
  }
}
'''

# 2) شاشة الإعدادات — تعديل بسيط لإضافة زر
SETTINGS_UPDATE = '''
import os

path = 'lib/screens/settings_screen.dart'
try:
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # إضافة استيراد
    if "defaults_screen.dart" not in content:
        content = content.replace(
            "import 'welcome_screen.dart';",
            "import 'welcome_screen.dart';\nimport 'defaults_screen.dart';"
        )
        print("✅ تم إضافة الاستيراد")
    else:
        print("⚠️ الاستيراد موجود مسبقاً")

    # إضافة زر البيانات الافتراضية قبل منطقة الخطر
    if "البيانات الافتراضية" not in content:
        new_section = """
              // ============ 📋 البيانات الافتراضية ============
              _section("📋 البيانات الافتراضية", s.primaryColor),
              SuccessButton(
                label: "⚙️ إدارة القوائم الافتراضية",
                icon: Icons.settings_applications,
                color: s.primaryColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DefaultsScreen()),
                  );
                },
              ),

              // ============ ⚠️ منطقة الخطر ============"""

        content = content.replace(
            "// ============ ⚠️ منطقة الخطر ============",
            new_section
        )
        print("✅ تم إضافة زر البيانات الافتراضية")
    else:
        print("⚠️ الزر موجود مسبقاً")

    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"✅ تم تحديث: {path}")
except Exception as e:
    print(f"❌ خطأ: {e}")
'''

# 3) subjects_screen — استخدام الـ defaults
SUBJECTS_UPDATE = '''
import os

path = 'lib/screens/subjects_screen.dart'
try:
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # استبدال القائمة الثابتة بـ defaults
    if "_quickSubjects" in content and "DefaultsProvider" not in content:
        # إضافة استيراد
        content = content.replace(
            "import '../models/settings.dart';",
            "import '../models/settings.dart';\nimport '../models/defaults.dart';"
        )

        # استبدال القائمة الثابتة
        content = content.replace(
            "static const _quickSubjects = [",
            "List<String> get _quickSubjects => context.read<DefaultsProvider>().quickSubjects;\n\n  // ignore: unused_field\n  static const _unused = ["
        )

        with open(path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"✅ تم تحديث: {path}")
    else:
        print(f"⚠️ {path} — لا يحتاج تعديل")
except Exception as e:
    print(f"❌ خطأ في {path}: {e}")
'''

# تنفيذ
os.makedirs('lib/screens', exist_ok=True)
with open('lib/screens/defaults_screen.dart', 'w', encoding='utf-8') as f:
    f.write(SCREEN_CONTENT)
print(f'✅ تم: lib/screens/defaults_screen.dart')

# تنفيذ تحديثات الإعدادات
exec(SETTINGS_UPDATE)

print('🎉 اكتمل الملف 3!')

# تصحيح: إضافة دالة حفظ في DefaultsProvider
FIX_DEFAULTS = '''
import os
path = 'lib/models/defaults.dart'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()
if 'Future<void> save(' not in content:
    content = content.replace(
        'void resetAll() {',
        'Future<void> save(BuildContext context) async {\n    // حفظ تلقائي - يتم مع حفظ الإعدادات\n  }\n\n  void resetAll() {'
    )
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("✅ تم إصلاح defaults.dart")
'''
exec(FIX_DEFAULTS)

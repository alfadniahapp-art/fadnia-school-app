import os

CONTENT = r'''import 'package:flutter/material.dart';

// ============================================================
//  📦 البيانات الافتراضية القابلة للتعديل
// ============================================================
class AppDefaults {
  // 📚 المواد السريعة
  static const List<String> defaultQuickSubjects = [
    'لغة عربية',
    'لغة عربية - قواعد',
    'لغة عربية - أدب',
    'لغة عربية - نصوص',
    'لغة عربية - إملاء',
    'رياضيات',
    'علوم',
    'أحياء',
    'فيزياء',
    'كيمياء',
    'تاريخ',
    'جغرافيا',
    'تربية إسلامية',
    'تربية وطنية',
    'لغة إنجليزية',
    'حاسوب',
    'تربية فنية',
    'تربية بدنية',
  ];

  // 👥 أنواع الموظفين
  static const List<String> defaultEmployeeTypes = [
    'معلم',
    'عامل',
    'إداري',
    'مدير',
    'وكيل',
    'محاسب',
    'أخرى',
  ];

  // 🎁 بنود الحوافز
  static const List<String> defaultIncomes = [
    'حافز أداء',
    'حافز تفوق',
    'بدل مواصلات',
    'بدل سكن',
    'ساعات إضافية',
    'مكافأة',
  ];

  // ➖ بنود الخصومات
  static const List<String> defaultDeductions = [
    'غياب',
    'سلفة',
    'تأخير',
    'جزاء',
    'تأمين',
  ];

  // 💰 بنود القبض
  static const List<String> defaultReceipts = [
    'رسوم دراسية',
    'رسوم تسجيل',
    'كتب وزي',
    'نقل مدرسي',
    'تبرعات',
    'إيجار قاعات',
    'بيع أصول',
    'أخرى',
  ];

  // 💸 بنود الصرف
  static const List<String> defaultPayments = [
    'رواتب',
    'إيجار',
    'كهرباء',
    'ماء',
    'إنترنت واتصالات',
    'صيانة',
    'مشتريات',
    'نقل',
    'ضيافة',
    'مكافآت',
    'أخرى',
  ];
}

// ============================================================
//  🔄 مزوّد البيانات الافتراضية (قابل للتعديل)
// ============================================================
class DefaultsProvider extends ChangeNotifier {
  List<String> quickSubjects = [...AppDefaults.defaultQuickSubjects];
  List<String> employeeTypes = [...AppDefaults.defaultEmployeeTypes];
  List<String> incomes = [...AppDefaults.defaultIncomes];
  List<String> deductions = [...AppDefaults.defaultDeductions];
  List<String> receipts = [...AppDefaults.defaultReceipts];
  List<String> payments = [...AppDefaults.defaultPayments];

  void loadFrom(Map<String, dynamic>? data) {
    if (data == null) return;
    quickSubjects = List<String>.from(
        data['quickSubjects'] ?? AppDefaults.defaultQuickSubjects);
    employeeTypes = List<String>.from(
        data['employeeTypes'] ?? AppDefaults.defaultEmployeeTypes);
    incomes = List<String>.from(
        data['incomes'] ?? AppDefaults.defaultIncomes);
    deductions = List<String>.from(
        data['deductions'] ?? AppDefaults.defaultDeductions);
    receipts = List<String>.from(
        data['receipts'] ?? AppDefaults.defaultReceipts);
    payments = List<String>.from(
        data['payments'] ?? AppDefaults.defaultPayments);
    notifyListeners();
  }

  Map<String, dynamic> toJson() => {
        'quickSubjects': quickSubjects,
        'employeeTypes': employeeTypes,
        'incomes': incomes,
        'deductions': deductions,
        'receipts': receipts,
        'payments': payments,
      };

  void resetAll() {
    quickSubjects = [...AppDefaults.defaultQuickSubjects];
    employeeTypes = [...AppDefaults.defaultEmployeeTypes];
    incomes = [...AppDefaults.defaultIncomes];
    deductions = [...AppDefaults.defaultDeductions];
    receipts = [...AppDefaults.defaultReceipts];
    payments = [...AppDefaults.defaultPayments];
    notifyListeners();
  }

  // إضافة / حذف
  void addItem(String listType, String value) {
    if (value.trim().isEmpty) return;
    final list = _listOf(listType);
    if (!list.contains(value.trim())) {
      list.add(value.trim());
      notifyListeners();
    }
  }

  void removeItem(String listType, String value) {
    _listOf(listType).remove(value);
    notifyListeners();
  }

  void updateItem(String listType, int index, String newValue) {
    if (newValue.trim().isEmpty) return;
    _listOf(listType)[index] = newValue.trim();
    notifyListeners();
  }

  List<String> _listOf(String type) {
    switch (type) {
      case 'quickSubjects':
        return quickSubjects;
      case 'employeeTypes':
        return employeeTypes;
      case 'incomes':
        return incomes;
      case 'deductions':
        return deductions;
      case 'receipts':
        return receipts;
      case 'payments':
        return payments;
      default:
        return quickSubjects;
    }
  }
}
'''

path = 'lib/models/defaults.dart'
os.makedirs(os.path.dirname(path), exist_ok=True)
with open(path, 'w', encoding='utf-8') as f:
    f.write(CONTENT)

print(f'✅ تم إنشاء: {path}')
print(f'📊 الحجم: {len(CONTENT)} حرف')

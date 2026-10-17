// Update: 17 Oct 2026 - v2
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AppDefaults {
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

  static const List<String> defaultEmployeeTypes = [
    'معلم',
    'عامل',
    'إداري',
    'مدير',
    'وكيل',
    'محاسب',
    'أخرى',
  ];

  static const List<String> defaultIncomes = [
    'حافز أداء',
    'حافز تفوق',
    'بدل مواصلات',
    'بدل سكن',
    'ساعات إضافية',
    'مكافأة',
  ];

  static const List<String> defaultDeductions = [
    'غياب',
    'سلفة',
    'تأخير',
    'جزاء',
    'تأمين',
  ];

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

class DefaultsProvider extends ChangeNotifier {
  static const String _storageKey = 'mulla_defaults_v1';

  List<String> quickSubjects = [...AppDefaults.defaultQuickSubjects];
  List<String> employeeTypes = [...AppDefaults.defaultEmployeeTypes];
  List<String> incomes = [...AppDefaults.defaultIncomes];
  List<String> deductions = [...AppDefaults.defaultDeductions];
  List<String> receipts = [...AppDefaults.defaultReceipts];
  List<String> payments = [...AppDefaults.defaultPayments];

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final data = jsonDecode(raw) as Map<String, dynamic>;
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
    } catch (_) {}
  }

  Future<void> save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'quickSubjects': quickSubjects,
        'employeeTypes': employeeTypes,
        'incomes': incomes,
        'deductions': deductions,
        'receipts': receipts,
        'payments': payments,
      };
      await prefs.setString(_storageKey, jsonEncode(data));
    } catch (_) {}
  }

  void resetAll() {
    quickSubjects = [...AppDefaults.defaultQuickSubjects];
    employeeTypes = [...AppDefaults.defaultEmployeeTypes];
    incomes = [...AppDefaults.defaultIncomes];
    deductions = [...AppDefaults.defaultDeductions];
    receipts = [...AppDefaults.defaultReceipts];
    payments = [...AppDefaults.defaultPayments];
    save();
    notifyListeners();
  }

  void addItem(String listType, String value) {
    if (value.trim().isEmpty) return;
    final list = _listOf(listType);
    if (!list.contains(value.trim())) {
      list.add(value.trim());
      save();
      notifyListeners();
    }
  }

  void removeItem(String listType, String value) {
    _listOf(listType).remove(value);
    save();
    notifyListeners();
  }

  void updateItem(String listType, int index, String newValue) {
    if (newValue.trim().isEmpty) return;
    _listOf(listType)[index] = newValue.trim();
    save();
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

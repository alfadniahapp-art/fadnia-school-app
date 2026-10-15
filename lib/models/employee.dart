import 'package:flutter/material.dart';

/// أنواع الموظفين
enum EmployeeType {
  teacher,      // معلم
  worker,       // عامل
  admin,        // إداري
  manager,      // مدير
  deputy,       // وكيل
  accountant,   // محاسب
  other,        // أخرى
}

extension EmployeeTypeExt on EmployeeType {
  String get label {
    switch (this) {
      case EmployeeType.teacher:
        return 'معلم';
      case EmployeeType.worker:
        return 'عامل';
      case EmployeeType.admin:
        return 'إداري';
      case EmployeeType.manager:
        return 'مدير';
      case EmployeeType.deputy:
        return 'وكيل';
      case EmployeeType.accountant:
        return 'محاسب';
      case EmployeeType.other:
        return 'أخرى';
    }
  }

  IconData get icon {
    switch (this) {
      case EmployeeType.teacher:
        return Icons.person;
      case EmployeeType.worker:
        return Icons.construction;
      case EmployeeType.admin:
        return Icons.badge;
      case EmployeeType.manager:
        return Icons.workspace_premium;
      case EmployeeType.deputy:
        return Icons.supervisor_account;
      case EmployeeType.accountant:
        return Icons.calculate;
      case EmployeeType.other:
        return Icons.person_outline;
    }
  }
}

/// أنواع البنود (حوافز أو خصومات)
enum PayItemType {
  // 🎁 الحوافز
  incentive,     // حافز أداء
  excellence,    // حافز تفوق
  transport,     // بدل مواصلات
  housing,       // بدل سكن
  overtime,      // ساعات إضافية
  reward,        // مكافأة

  // ➖ الخصومات
  absence,       // غياب
  advance,       // سلفة
  delay,         // تأخير
  penalty,       // جزاء
  insurance,     // تأمين

  // 📝 عام
  custom,        // مخصص
}

extension PayItemTypeExt on PayItemType {
  String get label {
    switch (this) {
      case PayItemType.incentive:
        return 'حافز أداء';
      case PayItemType.excellence:
        return 'حافز تفوق';
      case PayItemType.transport:
        return 'بدل مواصلات';
      case PayItemType.housing:
        return 'بدل سكن';
      case PayItemType.overtime:
        return 'ساعات إضافية';
      case PayItemType.reward:
        return 'مكافأة';
      case PayItemType.absence:
        return 'غياب';
      case PayItemType.advance:
        return 'سلفة';
      case PayItemType.delay:
        return 'تأخير';
      case PayItemType.penalty:
        return 'جزاء';
      case PayItemType.insurance:
        return 'تأمين';
      case PayItemType.custom:
        return 'مخصص';
    }
  }

  bool get isIncome {
    return this == PayItemType.incentive ||
        this == PayItemType.excellence ||
        this == PayItemType.transport ||
        this == PayItemType.housing ||
        this == PayItemType.overtime ||
        this == PayItemType.reward;
  }

  bool get isDeduction => !isIncome;
}

/// بند مالي (حافز أو خصم)
class PayItem {
  final String id;
  final PayItemType type;
  final String customName;
  final double amount;
  final String note;
  final bool isRecurring; // متكرر كل شهر؟

  PayItem({
    required this.id,
    required this.type,
    this.customName = '',
    required this.amount,
    this.note = '',
    this.isRecurring = false,
  });

  String get displayName =>
      type == PayItemType.custom && customName.isNotEmpty
          ? customName
          : type.label;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.index,
        'customName': customName,
        'amount': amount,
        'note': note,
        'isRecurring': isRecurring,
      };

  factory PayItem.fromJson(Map<String, dynamic> j) => PayItem(
        id: j['id'] ?? '',
        type: PayItemType.values[j['type'] ?? 0],
        customName: j['customName'] ?? '',
        amount: (j['amount'] as num?)?.toDouble() ?? 0,
        note: j['note'] ?? '',
        isRecurring: j['isRecurring'] ?? false,
      );
}

/// سلفة
class Advance {
  final String id;
  final double totalAmount;   // المبلغ الكلي
  final double monthlyCut;    // القسط الشهري
  final int months;           // عدد الشهور
  final int paidMonths;       // الشهور المدفوعة
  final DateTime startDate;
  final String reason;

  Advance({
    required this.id,
    required this.totalAmount,
    required this.monthlyCut,
    required this.months,
    this.paidMonths = 0,
    required this.startDate,
    this.reason = '',
  });

  double get remainingAmount => totalAmount - (monthlyCut * paidMonths);
  double get progress => months == 0 ? 0 : paidMonths / months;
  bool get isCompleted => paidMonths >= months;

  Map<String, dynamic> toJson() => {
        'id': id,
        'totalAmount': totalAmount,
        'monthlyCut': monthlyCut,
        'months': months,
        'paidMonths': paidMonths,
        'startDate': startDate.toIso8601String(),
        'reason': reason,
      };

  factory Advance.fromJson(Map<String, dynamic> j) => Advance(
        id: j['id'] ?? '',
        totalAmount: (j['totalAmount'] as num?)?.toDouble() ?? 0,
        monthlyCut: (j['monthlyCut'] as num?)?.toDouble() ?? 0,
        months: j['months'] ?? 0,
        paidMonths: j['paidMonths'] ?? 0,
        startDate: j['startDate'] != null
            ? DateTime.parse(j['startDate'])
            : DateTime.now(),
        reason: j['reason'] ?? '',
      );
}

/// الموظف
class Employee {
  final String id;
  final String name;
  final EmployeeType type;
  final String position;      // الوظيفة
  final String phone;
  final double baseSalary;    // الراتب الأساسي
  final String? photoPath;
  final String notes;

  // الحوافز والخصومات الثابتة (تتكرر كل شهر)
  final List<PayItem> recurringIncome;
  final List<PayItem> recurringDeductions;

  // السلف النشطة
  final List<Advance> advances;

  Employee({
    required this.id,
    required this.name,
    required this.type,
    this.position = '',
    this.phone = '',
    this.baseSalary = 300000,
    this.photoPath,
    this.notes = '',
    this.recurringIncome = const [],
    this.recurringDeductions = const [],
    this.advances = const [],
  });

  /// إجمالي الحوافز الثابتة
  double get totalRecurringIncome =>
      recurringIncome.fold(0.0, (sum, item) => sum + item.amount);

  /// إجمالي الخصومات الثابتة
  double get totalRecurringDeductions =>
      recurringDeductions.fold(0.0, (sum, item) => sum + item.amount);

  /// مجموع أقساط السلف النشطة
  double get totalActiveAdvancesCut {
    return advances
        .where((a) => !a.isCompleted)
        .fold(0.0, (sum, a) => sum + a.monthlyCut);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.index,
        'position': position,
        'phone': phone,
        'baseSalary': baseSalary,
        'photoPath': photoPath,
        'notes': notes,
        'recurringIncome': recurringIncome.map((e) => e.toJson()).toList(),
        'recurringDeductions':
            recurringDeductions.map((e) => e.toJson()).toList(),
        'advances': advances.map((e) => e.toJson()).toList(),
      };

  factory Employee.fromJson(Map<String, dynamic> j) => Employee(
        id: j['id'] ?? '',
        name: j['name'] ?? '',
        type: EmployeeType.values[j['type'] ?? 0],
        position: j['position'] ?? '',
        phone: j['phone'] ?? '',
        baseSalary: (j['baseSalary'] as num?)?.toDouble() ?? 300000,
        photoPath: j['photoPath'],
        notes: j['notes'] ?? '',
        recurringIncome: (j['recurringIncome'] as List? ?? [])
            .map((e) => PayItem.fromJson(e))
            .toList(),
        recurringDeductions: (j['recurringDeductions'] as List? ?? [])
            .map((e) => PayItem.fromJson(e))
            .toList(),
        advances: (j['advances'] as List? ?? [])
            .map((e) => Advance.fromJson(e))
            .toList(),
      );

  Employee copyWith({
    String? name,
    EmployeeType? type,
    String? position,
    String? phone,
    double? baseSalary,
    String? photoPath,
    String? notes,
    List<PayItem>? recurringIncome,
    List<PayItem>? recurringDeductions,
    List<Advance>? advances,
  }) =>
      Employee(
        id: id,
        name: name ?? this.name,
        type: type ?? this.type,
        position: position ?? this.position,
        phone: phone ?? this.phone,
        baseSalary: baseSalary ?? this.baseSalary,
        photoPath: photoPath ?? this.photoPath,
        notes: notes ?? this.notes,
        recurringIncome: recurringIncome ?? this.recurringIncome,
        recurringDeductions: recurringDeductions ?? this.recurringDeductions,
        advances: advances ?? this.advances,
      );
}

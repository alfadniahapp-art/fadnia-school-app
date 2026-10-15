import 'package:flutter/material.dart';
import 'employee.dart';

/// حالة الدفع
enum PaymentStatus {
  paid,      // مدفوع
  pending,   // معلق
  partial,   // جزئي
}

extension PaymentStatusExt on PaymentStatus {
  String get label {
    switch (this) {
      case PaymentStatus.paid:
        return 'مدفوع';
      case PaymentStatus.pending:
        return 'معلق';
      case PaymentStatus.partial:
        return 'جزئي';
    }
  }

  Color get color {
    switch (this) {
      case PaymentStatus.paid:
        return const Color(0xFF27AE60);
      case PaymentStatus.pending:
        return const Color(0xFFF39C12);
      case PaymentStatus.partial:
        return const Color(0xFF3498DB);
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentStatus.paid:
        return Icons.check_circle;
      case PaymentStatus.pending:
        return Icons.pending;
      case PaymentStatus.partial:
        return Icons.timelapse;
    }
  }
}

/// أيام العمل في الشهر (افتراضياً 22 يوم)
const int kWorkDaysPerMonth = 22;

/// سجل راتب شهري
class PayrollRecord {
  final String id;
  final String employeeId;
  final String employeeName;
  final EmployeeType employeeType;
  final String position;

  // 📅 الشهر
  final int month;      // 1-12
  final int year;       // 1446, 1447...

  // 💰 الراتب الأساسي
  final double baseSalary;

  // 🎁 الحوافز الفعلية هذا الشهر
  final List<PayItem> incomes;

  // ➖ الخصومات الفعلية هذا الشهر
  final List<PayItem> deductions;

  // 🚫 عدد أيام الغياب
  final int absenceDays;

  // 💵 السلف المخصومة هذا الشهر
  final List<String> advanceIds; // معرّفات السلف

  // 💰 الدفع
  final double paidAmount;
  final DateTime? paymentDate;
  final PaymentStatus status;
  final String notes;

  PayrollRecord({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.employeeType,
    this.position = '',
    required this.month,
    required this.year,
    required this.baseSalary,
    this.incomes = const [],
    this.deductions = const [],
    this.absenceDays = 0,
    this.advanceIds = const [],
    this.paidAmount = 0,
    this.paymentDate,
    this.status = PaymentStatus.pending,
    this.notes = '',
  });

  /// اسم الشهر بالعربي
  String get monthName {
    const months = [
      '',
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return months[month];
  }

  /// التاريخ الكامل
  String get periodLabel => '$monthName $year';

  /// قيمة اليوم الواحد (للغياب)
  double get dayValue => baseSalary / kWorkDaysPerMonth;

  /// خصم الغياب
  double get absenceDeduction => absenceDays * dayValue;

  /// إجمالي الحوافز
  double get totalIncomes =>
      incomes.fold(0.0, (sum, item) => sum + item.amount);

  /// إجمالي الخصومات اليدوية
  double get totalManualDeductions =>
      deductions.fold(0.0, (sum, item) => sum + item.amount);

  /// إجمالي الخصومات (يدوي + غياب)
  double get totalDeductions => totalManualDeductions + absenceDeduction;

  /// الصافي النهائي
  double get netSalary {
    final net = baseSalary + totalIncomes - totalDeductions;
    return net < 0 ? 0 : net;
  }

  /// المتبقي (إذا دفع جزئياً)
  double get remainingAmount => netSalary - paidAmount;

  /// نسبة الدفع
  double get paidRatio {
    if (netSalary == 0) return 1;
    return (paidAmount / netSalary).clamp(0, 1);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'employeeId': employeeId,
        'employeeName': employeeName,
        'employeeType': employeeType.index,
        'position': position,
        'month': month,
        'year': year,
        'baseSalary': baseSalary,
        'incomes': incomes.map((e) => e.toJson()).toList(),
        'deductions': deductions.map((e) => e.toJson()).toList(),
        'absenceDays': absenceDays,
        'advanceIds': advanceIds,
        'paidAmount': paidAmount,
        'paymentDate': paymentDate?.toIso8601String(),
        'status': status.index,
        'notes': notes,
      };

  factory PayrollRecord.fromJson(Map<String, dynamic> j) => PayrollRecord(
        id: j['id'] ?? '',
        employeeId: j['employeeId'] ?? '',
        employeeName: j['employeeName'] ?? '',
        employeeType: EmployeeType.values[j['employeeType'] ?? 0],
        position: j['position'] ?? '',
        month: j['month'] ?? 1,
        year: j['year'] ?? 1446,
        baseSalary: (j['baseSalary'] as num?)?.toDouble() ?? 0,
        incomes: (j['incomes'] as List? ?? [])
            .map((e) => PayItem.fromJson(e))
            .toList(),
        deductions: (j['deductions'] as List? ?? [])
            .map((e) => PayItem.fromJson(e))
            .toList(),
        absenceDays: j['absenceDays'] ?? 0,
        advanceIds: List<String>.from(j['advanceIds'] ?? []),
        paidAmount: (j['paidAmount'] as num?)?.toDouble() ?? 0,
        paymentDate: j['paymentDate'] != null
            ? DateTime.parse(j['paymentDate'])
            : null,
        status: PaymentStatus.values[j['status'] ?? 0],
        notes: j['notes'] ?? '',
      );

  PayrollRecord copyWith({
    List<PayItem>? incomes,
    List<PayItem>? deductions,
    int? absenceDays,
    List<String>? advanceIds,
    double? paidAmount,
    DateTime? paymentDate,
    PaymentStatus? status,
    String? notes,
  }) =>
      PayrollRecord(
        id: id,
        employeeId: employeeId,
        employeeName: employeeName,
        employeeType: employeeType,
        position: position,
        month: month,
        year: year,
        baseSalary: baseSalary,
        incomes: incomes ?? this.incomes,
        deductions: deductions ?? this.deductions,
        absenceDays: absenceDays ?? this.absenceDays,
        advanceIds: advanceIds ?? this.advanceIds,
        paidAmount: paidAmount ?? this.paidAmount,
        paymentDate: paymentDate ?? this.paymentDate,
        status: status ?? this.status,
        notes: notes ?? this.notes,
      );
}

/// ملخص الشهر
class PayrollSummary {
  final int month;
  final int year;
  final List<PayrollRecord> records;

  PayrollSummary({
    required this.month,
    required this.year,
    required this.records,
  });

  int get totalEmployees => records.length;
  int get paidCount =>
      records.where((r) => r.status == PaymentStatus.paid).length;
  int get pendingCount =>
      records.where((r) => r.status == PaymentStatus.pending).length;

  double get totalBaseSalary =>
      records.fold(0.0, (sum, r) => sum + r.baseSalary);

  double get totalIncomes =>
      records.fold(0.0, (sum, r) => sum + r.totalIncomes);

  double get totalDeductions =>
      records.fold(0.0, (sum, r) => sum + r.totalDeductions);

  double get totalNetSalary =>
      records.fold(0.0, (sum, r) => sum + r.netSalary);

  double get totalPaid =>
      records.fold(0.0, (sum, r) => sum + r.paidAmount);

  double get totalRemaining => totalNetSalary - totalPaid;

  double get progressRatio {
    if (totalNetSalary == 0) return 0;
    return (totalPaid / totalNetSalary).clamp(0, 1);
  }
}

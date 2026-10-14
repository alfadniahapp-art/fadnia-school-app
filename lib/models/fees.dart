import 'package:flutter/material.dart';
import '../services/storage_service.dart';

enum PaymentStatus { paid, unpaid, partial }

enum ExemptionType {
  none,        // لا يوجد إعفاء
  full,        // إعفاء كامل
  partial,     // إعفاء جزئي (نسبة)
  sibling,     // خصم إخوة
  excellence,  // خصم تفوق
  custom,      // مخصص
}

class FeeRecord {
  final String id;
  final String studentName;
  final String classRoom;

  // 💰 الرسوم الأساسية
  final double registrationFee;   // رسوم التسجيل (مرة واحدة)
  final bool registrationPaid;    // هل دُفعت رسوم التسجيل؟
  final double studyFee;          // رسوم الدراسة
  final double otherFees;         // رسوم أخرى (كتب، زي...)

  // 🎁 الإعفاءات
  final ExemptionType exemptionType;
  final double exemptionPercent;  // نسبة الإعفاء (0-100)
  final double exemptionAmount;   // مبلغ الإعفاء الثابت
  final String exemptionReason;   // سبب الإعفاء

  // 💵 الدفع
  final double paidAmount;
  final DateTime? lastPaymentDate;
  final String notes;

  FeeRecord({
    required this.id,
    required this.studentName,
    required this.classRoom,
    this.registrationFee = 0,
    this.registrationPaid = false,
    this.studyFee = 0,
    this.otherFees = 0,
    this.exemptionType = ExemptionType.none,
    this.exemptionPercent = 0,
    this.exemptionAmount = 0,
    this.exemptionReason = '',
    this.paidAmount = 0,
    this.lastPaymentDate,
    this.notes = '',
  });

  /// المجموع قبل الإعفاء
  double get subtotal => registrationFee + studyFee + otherFees;

  /// قيمة الإعفاء الكلية
  double get totalExemption {
    double fromPercent = subtotal * (exemptionPercent / 100);
    return fromPercent + exemptionAmount;
  }

  /// المبلغ المطلوب بعد الإعفاء
  double get totalRequired {
    final t = subtotal - totalExemption;
    return t < 0 ? 0 : t;
  }

  /// المتبقي
  double get remaining => totalRequired - paidAmount;

  /// نسبة الدفع
  double get paidRatio {
    if (totalRequired == 0) return 1;
    return (paidAmount / totalRequired).clamp(0, 1);
  }

  /// حالة الدفع
  PaymentStatus get status {
    if (paidAmount >= totalRequired) return PaymentStatus.paid;
    if (paidAmount > 0) return PaymentStatus.partial;
    return PaymentStatus.unpaid;
  }

  String get statusLabel {
    switch (status) {
      case PaymentStatus.paid:
        return 'مدفوع';
      case PaymentStatus.partial:
        return 'جزئي';
      case PaymentStatus.unpaid:
        return 'غير مدفوع';
    }
  }

  Color get statusColor {
    switch (status) {
      case PaymentStatus.paid:
        return const Color(0xFF27AE60);
      case PaymentStatus.partial:
        return const Color(0xFFF39C12);
      case PaymentStatus.unpaid:
        return const Color(0xFFE74C3C);
    }
  }

  String get exemptionLabel {
    switch (exemptionType) {
      case ExemptionType.none:
        return 'لا يوجد';
      case ExemptionType.full:
        return 'إعفاء كامل';
      case ExemptionType.partial:
        return 'إعفاء جزئي';
      case ExemptionType.sibling:
        return 'خصم إخوة';
      case ExemptionType.excellence:
        return 'خصم تفوق';
      case ExemptionType.custom:
        return 'مخصص';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentName': studentName,
        'classRoom': classRoom,
        'registrationFee': registrationFee,
        'registrationPaid': registrationPaid,
        'studyFee': studyFee,
        'otherFees': otherFees,
        'exemptionType': exemptionType.index,
        'exemptionPercent': exemptionPercent,
        'exemptionAmount': exemptionAmount,
        'exemptionReason': exemptionReason,
        'paidAmount': paidAmount,
        'lastPaymentDate': lastPaymentDate?.toIso8601String(),
        'notes': notes,
      };

  factory FeeRecord.fromJson(Map<String, dynamic> j) => FeeRecord(
        id: j['id'] ?? '',
        studentName: j['studentName'] ?? '',
        classRoom: j['classRoom'] ?? '',
        registrationFee: (j['registrationFee'] as num?)?.toDouble() ?? 0,
        registrationPaid: j['registrationPaid'] ?? false,
        studyFee: (j['studyFee'] as num?)?.toDouble() ?? 0,
        otherFees: (j['otherFees'] as num?)?.toDouble() ?? 0,
        exemptionType: ExemptionType.values[j['exemptionType'] ?? 0],
        exemptionPercent: (j['exemptionPercent'] as num?)?.toDouble() ?? 0,
        exemptionAmount: (j['exemptionAmount'] as num?)?.toDouble() ?? 0,
        exemptionReason: j['exemptionReason'] ?? '',
        paidAmount: (j['paidAmount'] as num?)?.toDouble() ?? 0,
        lastPaymentDate: j['lastPaymentDate'] != null
            ? DateTime.parse(j['lastPaymentDate'])
            : null,
        notes: j['notes'] ?? '',
      );

  FeeRecord copyWith({
    double? paidAmount,
    DateTime? lastPaymentDate,
    String? notes,
    bool? registrationPaid,
  }) =>
      FeeRecord(
        id: id,
        studentName: studentName,
        classRoom: classRoom,
        registrationFee: registrationFee,
        registrationPaid: registrationPaid ?? this.registrationPaid,
        studyFee: studyFee,
        otherFees: otherFees,
        exemptionType: exemptionType,
        exemptionPercent: exemptionPercent,
        exemptionAmount: exemptionAmount,
        exemptionReason: exemptionReason,
        paidAmount: paidAmount ?? this.paidAmount,
        lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
        notes: notes ?? this.notes,
      );
}

class FeesProvider extends ChangeNotifier {
  List<FeeRecord> records = [];

  Future<void> load() async {
    final data = await StorageService.loadFees();
    if (data != null) {
      records = data.map((e) => FeeRecord.fromJson(e)).toList();
    }
    notifyListeners();
  }

  Future<void> save() async {
    await StorageService.saveFees(records.map((e) => e.toJson()).toList());
  }

  void add(FeeRecord r) {
    records.add(r);
    save();
    notifyListeners();
  }

  void update(FeeRecord r) {
    final i = records.indexWhere((x) => x.id == r.id);
    if (i != -1) {
      records[i] = r;
      save();
      notifyListeners();
    }
  }

  void remove(String id) {
    records.removeWhere((r) => r.id == id);
    save();
    notifyListeners();
  }

  List<FeeRecord> forClass(String cls) =>
      records.where((r) => r.classRoom == cls).toList();

  FeeRecord? forStudent(String studentName) {
    try {
      return records.firstWhere((r) => r.studentName == studentName);
    } catch (_) {
      return null;
    }
  }

  double totalCollected() =>
      records.fold(0.0, (sum, r) => sum + r.paidAmount);

  double totalRemaining() =>
      records.fold(0.0, (sum, r) => sum + r.remaining);

  double totalExpected() =>
      records.fold(0.0, (sum, r) => sum + r.totalRequired);

  double totalExemptions() =>
      records.fold(0.0, (sum, r) => sum + r.totalExemption);
}

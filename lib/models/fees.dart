import 'package:flutter/material.dart';
import '../services/storage_service.dart';

enum PaymentStatus { paid, unpaid, partial }

class FeeRecord {
  final String id;
  final String studentName;
  final String classRoom;
  final double totalAmount;
  final double paidAmount;
  final DateTime? lastPaymentDate;
  final String notes;

  FeeRecord({
    required this.id,
    required this.studentName,
    required this.classRoom,
    required this.totalAmount,
    this.paidAmount = 0,
    this.lastPaymentDate,
    this.notes = '',
  });

  double get remaining => totalAmount - paidAmount;

  PaymentStatus get status {
    if (paidAmount >= totalAmount) return PaymentStatus.paid;
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentName': studentName,
        'classRoom': classRoom,
        'totalAmount': totalAmount,
        'paidAmount': paidAmount,
        'lastPaymentDate': lastPaymentDate?.toIso8601String(),
        'notes': notes,
      };

  factory FeeRecord.fromJson(Map<String, dynamic> j) => FeeRecord(
        id: j['id'],
        studentName: j['studentName'],
        classRoom: j['classRoom'],
        totalAmount: (j['totalAmount'] as num).toDouble(),
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
  }) =>
      FeeRecord(
        id: id,
        studentName: studentName,
        classRoom: classRoom,
        totalAmount: totalAmount,
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
}

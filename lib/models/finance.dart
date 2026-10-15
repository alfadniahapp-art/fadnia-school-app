import 'package:flutter/material.dart';

// ============================================================
//  🏦 نوع الحساب
// ============================================================
enum AccountType {
  cash,    // صندوق نقدي
  bank,    // بنك
  custom,  // مخصص
}

extension AccountTypeExt on AccountType {
  String get label {
    switch (this) {
      case AccountType.cash:
        return 'الصندوق النقدي';
      case AccountType.bank:
        return 'البنك';
      case AccountType.custom:
        return 'حساب مخصص';
    }
  }

  IconData get icon {
    switch (this) {
      case AccountType.cash:
        return Icons.payments;
      case AccountType.bank:
        return Icons.account_balance;
      case AccountType.custom:
        return Icons.account_balance_wallet;
    }
  }

  Color get color {
    switch (this) {
      case AccountType.cash:
        return const Color(0xFF27AE60);
      case AccountType.bank:
        return const Color(0xFF3498DB);
      case AccountType.custom:
        return const Color(0xFF9B59B6);
    }
  }
}

// ============================================================
//  🏦 الحساب
// ============================================================
class FinanceAccount {
  final String id;
  final String name;
  final AccountType type;
  final double openingBalance;
  final String notes;
  final bool isDefault;

  FinanceAccount({
    required this.id,
    required this.name,
    this.type = AccountType.cash,
    this.openingBalance = 0,
    this.notes = '',
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.index,
        'openingBalance': openingBalance,
        'notes': notes,
        'isDefault': isDefault,
      };

  factory FinanceAccount.fromJson(Map<String, dynamic> j) => FinanceAccount(
        id: j['id'] ?? '',
        name: j['name'] ?? '',
        type: AccountType.values[j['type'] ?? 0],
        openingBalance: (j['openingBalance'] as num?)?.toDouble() ?? 0,
        notes: j['notes'] ?? '',
        isDefault: j['isDefault'] ?? false,
      );

  FinanceAccount copyWith({
    String? name,
    AccountType? type,
    double? openingBalance,
    String? notes,
    bool? isDefault,
  }) =>
      FinanceAccount(
        id: id,
        name: name ?? this.name,
        type: type ?? this.type,
        openingBalance: openingBalance ?? this.openingBalance,
        notes: notes ?? this.notes,
        isDefault: isDefault ?? this.isDefault,
      );
}

// ============================================================
//  📂 بنود القبض والصرف
// ============================================================
enum TransactionType {
  receipt,  // 📥 قبض
  payment,  // 📤 صرف
}

extension TransactionTypeExt on TransactionType {
  String get label {
    switch (this) {
      case TransactionType.receipt:
        return 'قبض';
      case TransactionType.payment:
        return 'صرف';
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionType.receipt:
        return Icons.arrow_downward;
      case TransactionType.payment:
        return Icons.arrow_upward;
    }
  }

  Color get color {
    switch (this) {
      case TransactionType.receipt:
        return const Color(0xFF27AE60);
      case TransactionType.payment:
        return const Color(0xFFE74C3C);
    }
  }
}

class FinanceCategory {
  final String id;
  final String name;
  final TransactionType type;
  final IconData icon;

  FinanceCategory({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
  });

  static const List<Map<String, dynamic>> defaultReceipts = [
    {'name': 'رسوم دراسية', 'icon': Icons.school},
    {'name': 'رسوم تسجيل', 'icon': Icons.app_registration},
    {'name': 'كتب وزي', 'icon': Icons.menu_book},
    {'name': 'نقل مدرسي', 'icon': Icons.directions_bus},
    {'name': 'تبرعات', 'icon': Icons.favorite},
    {'name': 'إيجار قاعات', 'icon': Icons.meeting_room},
    {'name': 'بيع أصول', 'icon': Icons.sell},
    {'name': 'أخرى', 'icon': Icons.category},
  ];

  static const List<Map<String, dynamic>> defaultPayments = [
    {'name': 'رواتب', 'icon': Icons.people},
    {'name': 'إيجار', 'icon': Icons.home_work},
    {'name': 'كهرباء', 'icon': Icons.electric_bolt},
    {'name': 'ماء', 'icon': Icons.water_drop},
    {'name': 'إنترنت واتصالات', 'icon': Icons.wifi},
    {'name': 'صيانة', 'icon': Icons.build},
    {'name': 'مشتريات', 'icon': Icons.shopping_cart},
    {'name': 'نقل', 'icon': Icons.local_shipping},
    {'name': 'ضيافة', 'icon': Icons.restaurant},
    {'name': 'مكافآت', 'icon': Icons.emoji_events},
    {'name': 'أخرى', 'icon': Icons.category},
  ];
}

// ============================================================
//  📊 الحركة المالية (موحّدة)
// ============================================================
enum TransactionSource {
  manual,      // يدوي
  studentFee,  // من رسوم طالب
  payroll,     // من الرواتب
  other,       // أخرى
}

extension TransactionSourceExt on TransactionSource {
  String get label {
    switch (this) {
      case TransactionSource.manual:
        return 'يدوي';
      case TransactionSource.studentFee:
        return 'رسوم طالب';
      case TransactionSource.payroll:
        return 'راتب موظف';
      case TransactionSource.other:
        return 'أخرى';
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionSource.manual:
        return Icons.edit;
      case TransactionSource.studentFee:
        return Icons.school;
      case TransactionSource.payroll:
        return Icons.badge;
      case TransactionSource.other:
        return Icons.more_horiz;
    }
  }
}

class FinanceTransaction {
  final String id;
  final String accountId;
  final TransactionType type;
  final double amount;
  final String categoryName;
  final DateTime date;
  final String description;
  final String reference;   // رقم السند
  final String party;        // المستلم أو الدافع
  final TransactionSource source;
  final String? linkedId;    // معرف الطالب/الموظف
  final String notes;

  FinanceTransaction({
    required this.id,
    required this.accountId,
    required this.type,
    required this.amount,
    required this.categoryName,
    required this.date,
    this.description = '',
    this.reference = '',
    this.party = '',
    this.source = TransactionSource.manual,
    this.linkedId,
    this.notes = '',
  });

  bool get isReceipt => type == TransactionType.receipt;
  bool get isPayment => type == TransactionType.payment;
  double get signedAmount => isReceipt ? amount : -amount;

  Map<String, dynamic> toJson() => {
        'id': id,
        'accountId': accountId,
        'type': type.index,
        'amount': amount,
        'categoryName': categoryName,
        'date': date.toIso8601String(),
        'description': description,
        'reference': reference,
        'party': party,
        'source': source.index,
        'linkedId': linkedId,
        'notes': notes,
      };

  factory FinanceTransaction.fromJson(Map<String, dynamic> j) =>
      FinanceTransaction(
        id: j['id'] ?? '',
        accountId: j['accountId'] ?? '',
        type: TransactionType.values[j['type'] ?? 0],
        amount: (j['amount'] as num?)?.toDouble() ?? 0,
        categoryName: j['categoryName'] ?? '',
        date: j['date'] != null
            ? DateTime.parse(j['date'])
            : DateTime.now(),
        description: j['description'] ?? '',
        reference: j['reference'] ?? '',
        party: j['party'] ?? '',
        source: TransactionSource.values[j['source'] ?? 0],
        linkedId: j['linkedId'],
        notes: j['notes'] ?? '',
      );
}

// ============================================================
//  💰 الملخص المالي
// ============================================================
class FinanceSummary {
  final List<FinanceAccount> accounts;
  final List<FinanceTransaction> transactions;

  FinanceSummary({
    required this.accounts,
    required this.transactions,
  });

  /// الرصيد الحالي لكل حساب
  double balanceOf(String accountId) {
    final acc = accounts.firstWhere(
      (a) => a.id == accountId,
      orElse: () => FinanceAccount(id: '', name: ''),
    );
    double balance = acc.openingBalance;
    for (final t in transactions) {
      if (t.accountId == accountId) {
        balance += t.signedAmount;
      }
    }
    return balance;
  }

  /// إجمالي الرصيد (كل الحسابات)
  double get totalBalance {
    double total = 0;
    for (final a in accounts) {
      total += balanceOf(a.id);
    }
    return total;
  }

  /// إجمالي الواردات
  double get totalReceipts => transactions
      .where((t) => t.isReceipt)
      .fold(0.0, (s, t) => s + t.amount);

  /// إجمالي المنصرفات
  double get totalPayments => transactions
      .where((t) => t.isPayment)
      .fold(0.0, (s, t) => s + t.amount);

  /// الصافي (واردات - منصرفات)
  double get netFlow => totalReceipts - totalPayments;

  /// ملخص بند معين
  double totalByCategory(String categoryName, TransactionType type) {
    return transactions
        .where((t) => t.categoryName == categoryName && t.type == type)
        .fold(0.0, (s, t) => s + t.amount);
  }

  /// حركات فترة معينة
  List<FinanceTransaction> inRange(DateTime from, DateTime to) {
    return transactions.where((t) {
      return t.date.isAfter(from.subtract(const Duration(days: 1))) &&
          t.date.isBefore(to.add(const Duration(days: 1)));
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// الواردات في فترة
  double receiptsInRange(DateTime from, DateTime to) {
    return inRange(from, to)
        .where((t) => t.isReceipt)
        .fold(0.0, (s, t) => s + t.amount);
  }

  /// المنصرفات في فترة
  double paymentsInRange(DateTime from, DateTime to) {
    return inRange(from, to)
        .where((t) => t.isPayment)
        .fold(0.0, (s, t) => s + t.amount);
  }
}

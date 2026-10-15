import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/school_data.dart';
import '../models/settings.dart';
import '../models/finance.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'transaction_form_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});
  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

enum _DateFilter { all, today, week, month, year }

extension _DateFilterExt on _DateFilter {
  String get label {
    switch (this) {
      case _DateFilter.all:
        return 'الكل';
      case _DateFilter.today:
        return 'اليوم';
      case _DateFilter.week:
        return 'الأسبوع';
      case _DateFilter.month:
        return 'الشهر';
      case _DateFilter.year:
        return 'السنة';
    }
  }
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  TransactionType? _typeFilter;
  String? _accountFilter;
  _DateFilter _dateFilter = _DateFilter.all;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final data = context.watch<SchoolDataProvider>();
    final settings = context.watch<SettingsProvider>();
    final primary = settings.primaryColor;
    final currency = settings.currencySymbol;

    // فلترة
    var list = data.allTransactions.where((t) {
      if (_typeFilter != null && t.type != _typeFilter) return false;
      if (_accountFilter != null && t.accountId != _accountFilter) {
        return false;
      }
      if (!_matchesDate(t.date)) return false;
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        if (!t.party.toLowerCase().contains(q) &&
            !t.categoryName.toLowerCase().contains(q) &&
            !t.description.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();

    final receipts = list
        .where((t) => t.isReceipt)
        .fold(0.0, (s, t) => s + t.amount);
    final payments = list
        .where((t) => t.isPayment)
        .fold(0.0, (s, t) => s + t.amount);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: settings.backgroundColor,
        title: Text("سجل الحركات",
            style: TextStyle(color: primary, fontFamily: 'Changa')),
        iconTheme: IconThemeData(color: primary),
      ),
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: Column(
          children: [
            // ============ الفلاتر ============
            Container(
              padding: const EdgeInsets.all(10),
              color: AppColors.darkNavy.withOpacity(0.5),
              child: Column(
                children: [
                  // فلتر النوع
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _chip("الكل", null, primary),
                        const SizedBox(width: 6),
                        _chip("📥 قبض",
                            TransactionType.receipt, primary),
                        const SizedBox(width: 6),
                        _chip("📤 صرف",
                            TransactionType.payment, primary),
                        const SizedBox(width: 6),
                        ...data.financeAccounts.map((a) => Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: ChoiceChip(
                                label: Text(a.name,
                                    style: TextStyle(
                                        color: _accountFilter == a.id
                                            ? AppColors.darkest
                                            : primary,
                                        fontFamily: 'Changa',
                                        fontSize: 11)),
                                selected: _accountFilter == a.id,
                                selectedColor: primary,
                                backgroundColor: AppColors.navy,
                                onSelected: (_) => setState(() =>
                                    _accountFilter = _accountFilter == a.id
                                        ? null
                                        : a.id),
                              ),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  // فلتر التاريخ
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _DateFilter.values
                          .map((f) => Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: ChoiceChip(
                                  label: Text(f.label,
                                      style: TextStyle(
                                          color: _dateFilter == f
                                              ? AppColors.darkest
                                              : primary,
                                          fontFamily: 'Changa',
                                          fontSize: 11)),
                                  selected: _dateFilter == f,
                                  selectedColor: primary,
                                  backgroundColor: AppColors.navy,
                                  onSelected: (_) =>
                                      setState(() => _dateFilter = f),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // البحث
                  TextField(
                    onChanged: (v) => setState(() => _search = v),
                    decoration: InputDecoration(
                      hintText: "🔍 بحث...",
                      isDense: true,
                      prefixIcon:
                          Icon(Icons.search, color: primary, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // ============ الملخص ============
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.darkNavy,
                border: Border.all(color: primary, width: 1.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _sumItem("📥", "واردات",
                      "${receipts.toStringAsFixed(0)} $currency",
                      AppColors.green),
                  Container(
                      width: 1,
                      height: 30,
                      color: AppColors.border),
                  _sumItem("📤", "منصرفات",
                      "${payments.toStringAsFixed(0)} $currency",
                      AppColors.red),
                  Container(
                      width: 1,
                      height: 30,
                      color: AppColors.border),
                  _sumItem(
                      "📊",
                      "صافي",
                      "${(receipts - payments).toStringAsFixed(0)} $currency",
                      receipts - payments >= 0
                          ? AppColors.blue
                          : AppColors.orange),
                ],
              ),
            ),

            // ============ القائمة ============
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long,
                              size: 80, color: Colors.white24),
                          const SizedBox(height: 12),
                          const Text("لا توجد حركات",
                              style: TextStyle(
                                  color: Colors.white54,
                                  fontFamily: 'Changa')),
                          const SizedBox(height: 6),
                          Text("جرّب تغيير الفلاتر",
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.3),
                                  fontFamily: 'Changa',
                                  fontSize: 11)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      itemCount: list.length,
                      itemBuilder: (_, i) =>
                          _txCard(context, data, list[i], currency),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  bool _matchesDate(DateTime date) {
    if (_dateFilter == _DateFilter.all) return true;
    final now = DateTime.now();
    switch (_dateFilter) {
      case _DateFilter.today:
        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
      case _DateFilter.week:
        return date.isAfter(now.subtract(const Duration(days: 7)));
      case _DateFilter.month:
        return date.year == now.year && date.month == now.month;
      case _DateFilter.year:
        return date.year == now.year;
      default:
        return true;
    }
  }

  Widget _chip(String label, TransactionType? type, Color primary) {
    final selected = _typeFilter == type;
    return ChoiceChip(
      label: Text(label,
          style: TextStyle(
              color: selected ? AppColors.darkest : primary,
              fontFamily: 'Changa',
              fontSize: 11)),
      selected: selected,
      selectedColor: primary,
      backgroundColor: AppColors.navy,
      onSelected: (_) => setState(() => _typeFilter = type),
    );
  }

  Widget _sumItem(
      String emoji, String label, String value, Color color) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        Text(value,
            style: TextStyle(
                color: color,
                fontFamily: 'Changa',
                fontWeight: FontWeight.bold,
                fontSize: 12)),
        Text(label,
            style: const TextStyle(
                color: Colors.white54,
                fontFamily: 'Changa',
                fontSize: 10)),
      ],
    );
  }

  Widget _txCard(BuildContext context, SchoolDataProvider data,
      FinanceTransaction t, String currency) {
    final date = DateFormat('yyyy/MM/dd HH:mm').format(t.date);
    final account = data.accountById(t.accountId);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.darkNavy,
        border: Border(
          right: BorderSide(color: t.type.color, width: 4),
          top: BorderSide(color: AppColors.border, width: 0.5),
          bottom: BorderSide(color: AppColors.border, width: 0.5),
          left: BorderSide(color: AppColors.border, width: 0.5),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        onTap: () => _details(context, data, t, currency),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: t.type.color.withOpacity(0.2),
          child: Icon(t.type.icon, color: t.type.color, size: 20),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                  t.party.isNotEmpty ? t.party : t.categoryName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Changa',
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ),
            if (t.source != TransactionSource.manual)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(t.source.label,
                    style: const TextStyle(
                        color: Colors.white54,
                        fontFamily: 'Changa',
                        fontSize: 9)),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.categoryName,
                style: const TextStyle(
                    color: Colors.white70,
                    fontFamily: 'Changa',
                    fontSize: 11)),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 9, color: Colors.white38),
                const SizedBox(width: 3),
                Text(date,
                    style: const TextStyle(
                        color: Colors.white38,
                        fontFamily: 'Changa',
                        fontSize: 10)),
                if (account != null) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.account_balance_wallet,
                      size: 9, color: Colors.white38),
                  const SizedBox(width: 3),
                  Text(account.name,
                      style: const TextStyle(
                          color: Colors.white38,
                          fontFamily: 'Changa',
                          fontSize: 10)),
                ],
              ],
            ),
          ],
        ),
        trailing: Text(
          "${t.isReceipt ? '+' : '-'}${t.amount.toStringAsFixed(0)}",
          style: TextStyle(
              color: t.type.color,
              fontFamily: 'Changa',
              fontWeight: FontWeight.bold,
              fontSize: 14),
        ),
      ),
    );
  }

  void _details(BuildContext context, SchoolDataProvider data,
      FinanceTransaction t, String currency) {
    final date = DateFormat('yyyy/MM/dd - HH:mm').format(t.date);
    final account = data.accountById(t.accountId);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkNavy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 30,
                backgroundColor: t.type.color.withOpacity(0.2),
                child: Icon(t.type.icon,
                    color: t.type.color, size: 30),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                "${t.isReceipt ? '+' : '-'}${t.amount.toStringAsFixed(0)} $currency",
                style: TextStyle(
                    color: t.type.color,
                    fontFamily: 'Changa',
                    fontWeight: FontWeight.bold,
                    fontSize: 26),
              ),
            ),
            const SizedBox(height: 15),
            const Divider(color: AppColors.border),
            _row(Icons.receipt, "رقم السند",
                t.reference.isEmpty ? '-' : t.reference),
            _row(Icons.category, "البند", t.categoryName),
            _row(Icons.person, "المستلم/الدافع",
                t.party.isEmpty ? '-' : t.party),
            _row(Icons.calendar_today, "التاريخ", date),
            _row(Icons.account_balance_wallet, "الحساب",
                account?.name ?? '-'),
            _row(Icons.info_outline, "المصدر", t.source.label),
            if (t.description.isNotEmpty)
              _row(Icons.description, "البيان", t.description),
            if (t.notes.isNotEmpty)
              _row(Icons.note, "ملاحظات", t.notes),
            const SizedBox(height: 15),
            if (t.source == TransactionSource.manual)
              Row(
                children: [
                  Expanded(
                    child: SuccessButton(
                      label: "✏️ تعديل",
                      icon: Icons.edit,
                      color: AppColors.blue,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TransactionFormScreen(
                                editing: t),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SuccessButton(
                      label: "🗑️ حذف",
                      icon: Icons.delete,
                      color: Colors.red,
                      onTap: () {
                        data.removeTransaction(t.id);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                          "هذه الحركة مربوطة تلقائياً بمصدر آخر (لا يمكن تعديلها يدوياً)",
                          style: TextStyle(
                              color: Colors.orange,
                              fontFamily: 'Changa',
                              fontSize: 11)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.gold, size: 18),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text("$label:",
                style: const TextStyle(
                    color: Colors.white54,
                    fontFamily: 'Changa',
                    fontSize: 12)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Changa',
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

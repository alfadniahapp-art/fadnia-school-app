import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/school_data.dart';
import '../models/settings.dart';
import '../models/finance.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<SchoolDataProvider>();
    final settings = context.watch<SettingsProvider>();
    final primary = settings.primaryColor;
    final currency = settings.currencySymbol;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: settings.backgroundColor,
        title: Text("الحسابات",
            style: TextStyle(color: primary, fontFamily: 'Changa')),
        iconTheme: IconThemeData(color: primary),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        onPressed: () => _dialog(context, data, settings),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              // ============ الرصيد الإجمالي ============
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primary.withOpacity(0.25),
                      primary.withOpacity(0.05),
                    ],
                  ),
                  border: Border.all(color: primary, width: 2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_balance,
                            color: primary, size: 24),
                        const SizedBox(width: 8),
                        Text("إجمالي الرصيد",
                            style: TextStyle(
                                color: primary,
                                fontFamily: 'Changa',
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      child: Text(
                        "${data.totalBalance.toStringAsFixed(0)} $currency",
                        style: TextStyle(
                          color: primary,
                          fontFamily: 'Changa',
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                        "الرصيد = رصيد افتتاحي + واردات - منصرفات",
                        style: const TextStyle(
                            color: Colors.white54,
                            fontFamily: 'Changa',
                            fontSize: 10)),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // ============ قائمة الحسابات ============
              Expanded(
                child: data.financeAccounts.isEmpty
                    ? const Center(
                        child: Text("لا توجد حسابات",
                            style: TextStyle(
                                color: Colors.white54,
                                fontFamily: 'Changa')),
                      )
                    : ListView.builder(
                        itemCount: data.financeAccounts.length,
                        itemBuilder: (_, i) {
                          final acc = data.financeAccounts[i];
                          return _accountCard(
                              context, data, settings, acc, currency);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _accountCard(BuildContext context, SchoolDataProvider data,
      SettingsProvider settings, FinanceAccount acc, String currency) {
    final balance = data.balanceOf(acc.id);
    final primary = settings.primaryColor;
    final transactions =
        data.transactionsOf(acc.id).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkNavy,
        border: Border.all(color: acc.type.color, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: acc.type.color.withOpacity(0.2),
                child: Icon(acc.type.icon,
                    color: acc.type.color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(acc.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Changa',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                        ),
                        if (acc.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text("افتراضي",
                                style: TextStyle(
                                    color: AppColors.darkest,
                                    fontFamily: 'Changa',
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    Text(acc.type.label,
                        style: const TextStyle(
                            color: Colors.white54,
                            fontFamily: 'Changa',
                            fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.darkest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _miniItem(
                      "افتتاحي",
                      acc.openingBalance.toStringAsFixed(0),
                      Colors.white70),
                ),
                Container(
                    width: 1, height: 25, color: AppColors.border),
                Expanded(
                  child: _miniItem(
                      "حركات",
                      "$transactions",
                      Colors.white70),
                ),
                Container(
                    width: 1, height: 25, color: AppColors.border),
                Expanded(
                  child: _miniItem(
                      "الرصيد",
                      balance.toStringAsFixed(0),
                      acc.type.color),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _dialog(context, data, settings,
                      editing: acc),
                  icon: Icon(Icons.edit,
                      size: 16, color: settings.primaryColor),
                  label: Text("تعديل",
                      style: TextStyle(
                          color: settings.primaryColor,
                          fontFamily: 'Changa',
                          fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: settings.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              if (!acc.isDefault) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _confirmDelete(context, data, acc),
                    icon: const Icon(Icons.delete,
                        size: 16, color: Colors.redAccent),
                    label: const Text("حذف",
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontFamily: 'Changa',
                            fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: valueColor,
                fontFamily: 'Changa',
                fontWeight: FontWeight.bold,
                fontSize: 12)),
        Text(label,
            style: const TextStyle(
                color: Colors.white54,
                fontFamily: 'Changa',
                fontSize: 9)),
      ],
    );
  }

  // ============ نافذة إضافة/تعديل ============
  void _dialog(BuildContext context, SchoolDataProvider data,
      SettingsProvider settings,
      {FinanceAccount? editing}) {
    final nameCtrl =
        TextEditingController(text: editing?.name ?? '');
    final balanceCtrl = TextEditingController(
        text: editing?.openingBalance.toStringAsFixed(0) ?? '0');
    final notesCtrl =
        TextEditingController(text: editing?.notes ?? '');
    AccountType type = editing?.type ?? AccountType.cash;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          backgroundColor: AppColors.darkNavy,
          title: Text(editing == null ? "إضافة حساب" : "تعديل الحساب",
              style: const TextStyle(
                  color: AppColors.gold, fontFamily: 'Changa')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                      hintText: "اسم الحساب",
                      prefixIcon:
                          Icon(Icons.account_balance_wallet)),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<AccountType>(
                  value: type,
                  isExpanded: true,
                  dropdownColor: AppColors.darkNavy,
                  items: AccountType.values
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Row(
                              children: [
                                Icon(t.icon,
                                    color: t.color, size: 18),
                                const SizedBox(width: 8),
                                Text(t.label),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (v) => setD(() => type = v!),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: balanceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      hintText: "الرصيد الافتتاحي",
                      suffixText: settings.currencySymbol),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(
                      hintText: "ملاحظات (اختياري)"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("إلغاء"),
            ),
            TextButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                final balance =
                    double.tryParse(balanceCtrl.text) ?? 0;
                if (editing == null) {
                  data.addAccount(FinanceAccount(
                    id: DateTime.now()
                        .millisecondsSinceEpoch
                        .toString(),
                    name: nameCtrl.text.trim(),
                    type: type,
                    openingBalance: balance,
                    notes: notesCtrl.text.trim(),
                  ));
                } else {
                  data.updateAccount(editing.copyWith(
                    name: nameCtrl.text.trim(),
                    type: type,
                    openingBalance: balance,
                    notes: notesCtrl.text.trim(),
                  ));
                }
                Navigator.pop(ctx);
              },
              child: const Text("حفظ",
                  style: TextStyle(color: AppColors.gold)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, SchoolDataProvider data, FinanceAccount acc) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkNavy,
        title: const Text("تأكيد الحذف",
            style: TextStyle(
                color: Colors.redAccent, fontFamily: 'Changa')),
        content: Text(
            "سيتم حذف الحساب \"${acc.name}\" وكل الحركات المرتبطة به.\n\nهل أنت متأكد؟",
            style: const TextStyle(
                color: Colors.white, fontFamily: 'Changa')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              data.removeAccount(acc.id);
              Navigator.pop(context);
            },
            child: const Text("حذف",
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

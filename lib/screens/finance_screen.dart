import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/school_data.dart';
import '../models/settings.dart';
import '../models/finance.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'transactions_screen.dart';
import 'accounts_screen.dart';
import 'transaction_form_screen.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});
  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  @override
  Widget build(BuildContext context) {
    final data = context.watch<SchoolDataProvider>();
    final settings = context.watch<SettingsProvider>();
    final primary = settings.primaryColor;
    final currency = settings.currencySymbol;

    final summary = data.financeSummary;
    final recent = data.allTransactions.take(10).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: settings.backgroundColor,
        title: Text("الخزينة العامة",
            style: TextStyle(color: primary, fontFamily: 'Changa')),
        iconTheme: IconThemeData(color: primary),
        actions: [
          IconButton(
            icon: Icon(Icons.account_balance, color: primary),
            tooltip: "الحسابات",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AccountsScreen()),
            ),
          ),
          IconButton(
            icon: Icon(Icons.receipt_long, color: primary),
            tooltip: "كل الحركات",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const TransactionsScreen()),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                // ============ الرصيد الرئيسي ============
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primary.withOpacity(0.3),
                        primary.withOpacity(0.05),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    border: Border.all(color: primary, width: 2),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.account_balance_wallet,
                              color: primary, size: 30),
                          const SizedBox(width: 10),
                          Text("إجمالي الرصيد",
                              style: TextStyle(
                                  color: primary,
                                  fontFamily: 'Changa',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FittedBox(
                        child: Text(
                          "${summary.totalBalance.toStringAsFixed(0)} $currency",
                          style: TextStyle(
                            color: primary,
                            fontFamily: 'Changa',
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text("موزّع على ${data.financeAccounts.length} حساب",
                          style: const TextStyle(
                              color: Colors.white54,
                              fontFamily: 'Changa',
                              fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                // ============ الإحصائيات ============
                Row(
                  children: [
                    _statCard("📥", "واردات",
                        "${summary.totalReceipts.toStringAsFixed(0)} $currency",
                        AppColors.green),
                    const SizedBox(width: 8),
                    _statCard("📤", "منصرفات",
                        "${summary.totalPayments.toStringAsFixed(0)} $currency",
                        AppColors.red),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _statCard(
                        "📊",
                        "الصافي",
                        "${summary.netFlow.toStringAsFixed(0)} $currency",
                        summary.netFlow >= 0
                            ? AppColors.blue
                            : AppColors.orange),
                    const SizedBox(width: 8),
                    _statCard("📝", "الحركات",
                        "${data.financeTransactions.length}", primary),
                  ],
                ),
                const SizedBox(height: 20),

                // ============ الحسابات ============
                _sectionHeader("🏦 الحسابات", primary, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AccountsScreen()),
                  );
                }),
                const SizedBox(height: 8),
                ...data.financeAccounts.map((acc) {
                  final balance = data.balanceOf(acc.id);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.darkNavy,
                      border: Border.all(
                          color: acc.type.color.withOpacity(0.6),
                          width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              acc.type.color.withOpacity(0.2),
                          child: Icon(acc.type.icon,
                              color: acc.type.color, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(acc.name,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Changa',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              Text(acc.type.label,
                                  style: const TextStyle(
                                      color: Colors.white54,
                                      fontFamily: 'Changa',
                                      fontSize: 11)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                                "${balance.toStringAsFixed(0)}",
                                style: TextStyle(
                                    color: acc.type.color,
                                    fontFamily: 'Changa',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            Text(currency,
                                style: const TextStyle(
                                    color: Colors.white54,
                                    fontFamily: 'Changa',
                                    fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 15),

                // ============ آخر الحركات ============
                _sectionHeader("📋 آخر الحركات", primary, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const TransactionsScreen()),
                  );
                }),
                const SizedBox(height: 8),

                if (recent.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: AppColors.darkNavy,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long,
                            size: 60, color: Colors.white24),
                        const SizedBox(height: 12),
                        const Text("لا توجد حركات بعد",
                            style: TextStyle(
                                color: Colors.white54,
                                fontFamily: 'Changa'),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 6),
                        Text(
                            "اضغط + لإضافة أول حركة (قبض أو صرف)",
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontFamily: 'Changa',
                                fontSize: 11),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  )
                else
                  ...recent.map((t) => _transactionCard(t, currency)),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFAB(context, primary),
    );
  }

  Widget _buildFAB(BuildContext context, Color primary) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton.extended(
          heroTag: 'payment',
          backgroundColor: AppColors.red,
          icon: const Icon(Icons.arrow_upward, color: Colors.white),
          label: const Text("صرف",
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Changa',
                  fontWeight: FontWeight.bold)),
          onPressed: () => _openForm(context, TransactionType.payment),
        ),
        const SizedBox(height: 10),
        FloatingActionButton.extended(
          heroTag: 'receipt',
          backgroundColor: AppColors.green,
          icon: const Icon(Icons.arrow_downward, color: Colors.white),
          label: const Text("قبض",
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Changa',
                  fontWeight: FontWeight.bold)),
          onPressed: () => _openForm(context, TransactionType.receipt),
        ),
      ],
    );
  }

  void _openForm(BuildContext context, TransactionType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionFormScreen(initialType: type),
      ),
    );
  }

  Widget _sectionHeader(
      String title, Color primary, VoidCallback onMore) {
    return Row(
      children: [
        Expanded(
          child: Text(title,
              style: TextStyle(
                  color: primary,
                  fontFamily: 'Changa',
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
        ),
        TextButton.icon(
          onPressed: onMore,
          icon: Icon(Icons.arrow_forward_ios,
              color: primary, size: 12),
          label: Text("عرض الكل",
              style: TextStyle(
                  color: primary,
                  fontFamily: 'Changa',
                  fontSize: 12)),
        ),
      ],
    );
  }

  Widget _statCard(
      String emoji, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.darkNavy,
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            FittedBox(
              child: Text(value,
                  style: TextStyle(
                      color: color,
                      fontFamily: 'Changa',
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            ),
            Text(label,
                style: const TextStyle(
                    color: Colors.white54,
                    fontFamily: 'Changa',
                    fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _transactionCard(FinanceTransaction t, String currency) {
    final date = DateFormat('yyyy/MM/dd HH:mm').format(t.date);
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
        dense: true,
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: t.type.color.withOpacity(0.2),
          child: Icon(t.type.icon, color: t.type.color, size: 20),
        ),
        title: Text(
            t.party.isNotEmpty ? t.party : t.categoryName,
            style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Changa',
                fontWeight: FontWeight.bold,
                fontSize: 13)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.categoryName,
                style: const TextStyle(
                    color: Colors.white70,
                    fontFamily: 'Changa',
                    fontSize: 11)),
            Text(date,
                style: const TextStyle(
                    color: Colors.white38,
                    fontFamily: 'Changa',
                    fontSize: 10)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${t.isReceipt ? '+' : '-'}${t.amount.toStringAsFixed(0)}",
              style: TextStyle(
                  color: t.type.color,
                  fontFamily: 'Changa',
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
            Text(currency,
                style: const TextStyle(
                    color: Colors.white54,
                    fontFamily: 'Changa',
                    fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

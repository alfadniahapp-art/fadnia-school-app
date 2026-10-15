import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/school_data.dart';
import '../models/settings.dart';
import '../models/fees.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key});
  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {
  String? _cls;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<SchoolDataProvider>();
    final settings = context.watch<SettingsProvider>();
    final fees = context.watch<FeesProvider>();
    _cls ??= data.classes.first;
    final records = fees.forClass(_cls!);
    final currency = settings.currencySymbol;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: settings.backgroundColor,
        title: Text("رسوم الطلاب",
            style: TextStyle(
                color: settings.primaryColor, fontFamily: 'Changa')),
        iconTheme: IconThemeData(color: settings.primaryColor),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: settings.primaryColor,
        onPressed: () => _addFeeDialog(context, data, fees, currency),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              const CustomLabel("الفصل:"),
              DropdownButtonFormField<String>(
                value: _cls,
                isExpanded: true,
                dropdownColor: AppColors.darkNavy,
                items: data.classes
                    .map((c) =>
                        DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _cls = v),
              ),
              const SizedBox(height: 12),
              // ملخصات
              Row(children: [
                _summary("المطلوب",
                    _fmt(fees.forClass(_cls!).fold(0.0, (s, r) => s + r.totalRequired), currency),
                    Icons.receipt, AppColors.blue),
                const SizedBox(width: 6),
                _summary("المحصّل",
                    _fmt(fees.forClass(_cls!).fold(0.0, (s, r) => s + r.paidAmount), currency),
                    Icons.attach_money, AppColors.green),
                const SizedBox(width: 6),
                _summary("المتبقي",
                    _fmt(fees.forClass(_cls!).fold(0.0, (s, r) => s + r.remaining), currency),
                    Icons.money_off, AppColors.red),
              ]),
              const SizedBox(height: 12),
              Expanded(
                child: records.isEmpty
                    ? const Center(
                        child: Text("لا توجد رسوم مسجلة. اضغط + للإضافة",
                            style: TextStyle(
                                color: Colors.white54,
                                fontFamily: 'Changa'),
                            textAlign: TextAlign.center),
                      )
                    : ListView.builder(
                        itemCount: records.length,
                        itemBuilder: (_, i) {
                          final r = records[i];
                          return Card(
                            color: AppColors.darkNavy,
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                  color: r.statusColor, width: 2),
                            ),
                            child: ListTile(
                              onTap: () => _showDetails(
                                  context, fees, r, currency),
                              leading: CircleAvatar(
                                backgroundColor:
                                    r.statusColor.withOpacity(0.2),
                                child: Icon(
                                  r.status == PaymentStatus.paid
                                      ? Icons.check
                                      : Icons.attach_money,
                                  color: r.statusColor,
                                ),
                              ),
                              title: Text(r.studentName,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Changa',
                                      fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "مدفوع: ${_fmt(r.paidAmount, currency)} / ${_fmt(r.totalRequired, currency)}",
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontFamily: 'Changa',
                                        fontSize: 11),
                                  ),
                                  if (r.totalExemption > 0)
                                    Text(
                                      "🎁 إعفاء: ${_fmt(r.totalExemption, currency)} (${r.exemptionLabel})",
                                      style: const TextStyle(
                                          color: AppColors.orange,
                                          fontFamily: 'Changa',
                                          fontSize: 11),
                                    ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: r.statusColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(r.statusLabel,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Changa',
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(double v, String cur) {
    return '${v.toStringAsFixed(0)} $cur';
  }

  Widget _summary(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.darkNavy,
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontFamily: 'Changa',
                    fontWeight: FontWeight.bold)),
          ),
          Text(label,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontFamily: 'Changa')),
        ]),
      ),
    );
  }

  // ============ نافذة إضافة رسوم ============
  void _addFeeDialog(BuildContext context, SchoolDataProvider data,
      FeesProvider fees, String currency) {
    final students = data.studentsOf(_cls!);
    if (students.isEmpty) {
      _snack(context, "أضف طلاباً أولاً", Colors.redAccent);
      return;
    }
    String? student = students.first.name;
    final regCtrl = TextEditingController(text: "0");
    final studyCtrl = TextEditingController(text: "0");
    final otherCtrl = TextEditingController(text: "0");

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          backgroundColor: AppColors.darkNavy,
          title: const Text("إضافة رسوم",
              style: TextStyle(
                  color: AppColors.gold, fontFamily: 'Changa')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: student,
                  isExpanded: true,
                  dropdownColor: AppColors.darkNavy,
                  items: students
                      .map((s) => DropdownMenuItem(
                          value: s.name, child: Text(s.name)))
                      .toList(),
                  onChanged: (v) => setD(() => student = v),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: regCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: "رسوم التسجيل ($currency)"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: studyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: "رسوم الدراسة ($currency)"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: otherCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: "رسوم أخرى ($currency)"),
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
                if (student == null) return;
                fees.add(FeeRecord(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  studentName: student!,
                  classRoom: _cls!,
                  registrationFee: double.tryParse(regCtrl.text) ?? 0,
                  studyFee: double.tryParse(studyCtrl.text) ?? 0,
                  otherFees: double.tryParse(otherCtrl.text) ?? 0,
                ));
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

  // ============ عرض التفاصيل ============
  void _showDetails(BuildContext context, FeesProvider fees,
      FeeRecord r, String currency) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkNavy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(r.studentName,
                    style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Changa')),
              ),
              Center(
                child: Text(r.classRoom,
                    style: const TextStyle(
                        color: Colors.white70, fontFamily: 'Changa')),
              ),
              const Divider(color: AppColors.gold),
              _detailRow("📝 رسوم التسجيل",
                  _fmt(r.registrationFee, currency),
                  r.registrationPaid),
              _detailRow("📚 رسوم الدراسة",
                  _fmt(r.studyFee, currency), false),
              _detailRow("📖 رسوم أخرى",
                  _fmt(r.otherFees, currency), false),
              const Divider(color: AppColors.gold),
              _detailRow("💰 المجموع",
                  _fmt(r.subtotal, currency), false),
              if (r.totalExemption > 0) ...[
                _detailRow("🎁 الإعفاء (${r.exemptionLabel})",
                    "-${_fmt(r.totalExemption, currency)}", false,
                    color: AppColors.orange),
                if (r.exemptionReason.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 30, bottom: 6),
                    child: Text("السبب: ${r.exemptionReason}",
                        style: const TextStyle(
                            color: Colors.white54,
                            fontFamily: 'Changa',
                            fontSize: 12)),
                  ),
              ],
              _detailRow("✅ المطلوب",
                  _fmt(r.totalRequired, currency), false,
                  color: AppColors.green),
              _detailRow("💵 المدفوع",
                  _fmt(r.paidAmount, currency), false,
                  color: AppColors.blue),
              _detailRow("⏳ المتبقي",
                  _fmt(r.remaining, currency), false,
                  color: r.remaining > 0 ? AppColors.red : AppColors.green),
              const SizedBox(height: 15),
              Row(children: [
                Expanded(
                  child: SuccessButton(
                    label: "💵 دفع",
                    icon: Icons.payments,
                    color: AppColors.green,
                    onTap: () {
                      Navigator.pop(context);
                      _paymentDialog(context, fees, r, currency);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SuccessButton(
                    label: "🎁 إعفاء",
                    icon: Icons.redeem,
                    color: AppColors.orange,
                    onTap: () {
                      Navigator.pop(context);
                      _exemptionDialog(context, fees, r, currency);
                    },
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              SuccessButton(
                label: "🗑️ حذف",
                icon: Icons.delete,
                color: Colors.red,
                onTap: () {
                  fees.remove(r.id);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, bool paid,
      {Color color = Colors.white}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white70,
                    fontFamily: 'Changa',
                    fontSize: 14)),
          ),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontFamily: 'Changa',
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ],
      ),
    );
  }

  // ============ نافذة الدفع ============
  void _paymentDialog(BuildContext context, FeesProvider fees,
      FeeRecord r, String currency) {
    final amountCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkNavy,
        title: Text("دفعة جديدة - ${r.studentName}",
            style: const TextStyle(
                color: AppColors.gold, fontFamily: 'Changa', fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("المتبقي: ${_fmt(r.remaining, currency)}",
                style: const TextStyle(
                    color: Colors.orangeAccent, fontFamily: 'Changa')),
            const SizedBox(height: 8),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  hintText: "المبلغ المدفوع",
                  suffixText: currency),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(amountCtrl.text) ?? 0;
              if (amount > 0) {
                fees.update(r.copyWith(
                  paidAmount: r.paidAmount + amount,
                  lastPaymentDate: DateTime.now(),
                ));
                _snack(context, "تم تسجيل الدفعة ✓", AppColors.green);
              }
              Navigator.pop(context);
            },
            child: const Text("دفع",
                style: TextStyle(color: AppColors.green)),
          ),
        ],
      ),
    );
  }

  // ============ نافذة الإعفاء ============
  void _exemptionDialog(BuildContext context, FeesProvider fees,
      FeeRecord r, String currency) {
    final amountCtrl =
        TextEditingController(text: r.exemptionAmount.toStringAsFixed(0));
    final percentCtrl =
        TextEditingController(text: r.exemptionPercent.toStringAsFixed(0));
    final reasonCtrl = TextEditingController(text: r.exemptionReason);
    ExemptionType type = r.exemptionType;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          backgroundColor: AppColors.darkNavy,
          title: const Text("الإعفاء / الخصم",
              style: TextStyle(
                  color: AppColors.gold, fontFamily: 'Changa')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<ExemptionType>(
                  value: type,
                  isExpanded: true,
                  dropdownColor: AppColors.darkNavy,
                  items: ExemptionType.values
                      .map((e) => DropdownMenuItem(
                          value: e, child: Text(_exName(e))))
                      .toList(),
                  onChanged: (v) => setD(() => type = v!),
                ),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: percentCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: "نسبة %",
                          suffixText: '%'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: "مبلغ ثابت",
                          suffixText: currency),
                    ),
                  ),
                ]),
                const SizedBox(height: 8),
                TextField(
                  controller: reasonCtrl,
                  decoration:
                      const InputDecoration(labelText: "السبب"),
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
                final newRec = FeeRecord(
                  id: r.id,
                  studentName: r.studentName,
                  classRoom: r.classRoom,
                  registrationFee: r.registrationFee,
                  registrationPaid: r.registrationPaid,
                  studyFee: r.studyFee,
                  otherFees: r.otherFees,
                  exemptionType: type,
                  exemptionPercent:
                      double.tryParse(percentCtrl.text) ?? 0,
                  exemptionAmount:
                      double.tryParse(amountCtrl.text) ?? 0,
                  exemptionReason: reasonCtrl.text,
                  paidAmount: r.paidAmount,
                  lastPaymentDate: r.lastPaymentDate,
                );
                fees.update(newRec);
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

  String _exName(ExemptionType t) {
    switch (t) {
      case ExemptionType.none:
        return 'لا يوجد إعفاء';
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

  void _snack(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }
}

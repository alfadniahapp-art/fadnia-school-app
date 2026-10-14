import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/school_data.dart';
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
    final fees = context.watch<FeesProvider>();
    _cls ??= data.classes.first;
    final records = fees.forClass(_cls!);
    final currency = NumberFormat.currency(
        locale: 'ar', symbol: 'ر.س', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkNavy,
        title: const Text("رسوم الطلاب",
            style: TextStyle(color: AppColors.gold, fontFamily: 'Changa')),
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.gold,
        icon: const Icon(Icons.add, color: AppColors.darkNavy),
        label: const Text("إضافة رسم",
            style: TextStyle(
                color: AppColors.darkNavy, fontFamily: 'Changa')),
        onPressed: () => _addFeeDialog(context, data, fees),
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
              const SizedBox(height: 15),
              Row(children: [
                _summaryCard("المحصّل",
                    currency.format(fees.forClass(_cls!).fold(
                        0.0, (s, r) => s + r.paidAmount)),
                    Icons.attach_money, AppColors.green),
                const SizedBox(width: 8),
                _summaryCard("المتبقي",
                    currency.format(fees.forClass(_cls!).fold(
                        0.0, (s, r) => s + r.remaining)),
                    Icons.money_off, AppColors.red),
              ]),
              const SizedBox(height: 15),
              Expanded(
                child: records.isEmpty
                    ? const Center(
                        child: Text(
                            "لا توجد رسوم مسجلة. اضغط + للإضافة",
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
                              onTap: () =>
                                  _editFeeDialog(context, fees, r),
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
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "مدفوع: ${currency.format(r.paidAmount)} / ${currency.format(r.totalAmount)}",
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontFamily: 'Changa',
                                        fontSize: 12),
                                  ),
                                  Text(
                                    "متبقٍ: ${currency.format(r.remaining)}",
                                    style: const TextStyle(
                                        color: Colors.orangeAccent,
                                        fontFamily: 'Changa',
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: r.statusColor,
                                      borderRadius:
                                          BorderRadius.circular(6),
                                    ),
                                    child: Text(r.statusLabel,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Changa',
                                            fontSize: 11,
                                            fontWeight:
                                                FontWeight.bold)),
                                  ),
                                  const SizedBox(height: 4),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.redAccent,
                                        size: 18),
                                    padding: EdgeInsets.zero,
                                    constraints:
                                        const BoxConstraints(),
                                    onPressed: () => fees.remove(r.id),
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

  Widget _summaryCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.darkNavy,
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontFamily: 'Changa',
                  fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontFamily: 'Changa')),
        ]),
      ),
    );
  }

  void _addFeeDialog(
      BuildContext context, SchoolDataProvider data, FeesProvider fees) {
    final students = data.studentsOf(_cls!);
    if (students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("أضف طلاباً أولاً من شاشة قائمة الطلاب"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    String? student = students.first.name;
    final totalCtrl = TextEditingController(text: "0");
    final paidCtrl = TextEditingController(text: "0");

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          backgroundColor: AppColors.darkNavy,
          title: const Text("إضافة رسم",
              style: TextStyle(
                  color: AppColors.gold, fontFamily: 'Changa')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                    alignment: Alignment.centerRight,
                    child: Text("الطالب:",
                        style: TextStyle(
                            color: AppColors.gold,
                            fontFamily: 'Changa'))),
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
                const SizedBox(height: 10),
                TextField(
                  controller: totalCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: "المبلغ الإجمالي"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: paidCtrl,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: "المبلغ المدفوع"),
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
                final total = double.tryParse(totalCtrl.text) ?? 0;
                final paid = double.tryParse(paidCtrl.text) ?? 0;
                if (student == null) return;
                fees.add(FeeRecord(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  studentName: student!,
                  classRoom: _cls!,
                  totalAmount: total,
                  paidAmount: paid,
                  lastPaymentDate: paid > 0 ? DateTime.now() : null,
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

  void _editFeeDialog(
      BuildContext context, FeesProvider fees, FeeRecord r) {
    final amountCtrl = TextEditingController();
    final currency = NumberFormat.currency(
        locale: 'ar', symbol: 'ر.س', decimalDigits: 0);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkNavy,
        title: Text(r.studentName,
            style: const TextStyle(
                color: AppColors.gold, fontFamily: 'Changa')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("الإجمالي: ${currency.format(r.totalAmount)}",
                  style: const TextStyle(
                      color: Colors.white70, fontFamily: 'Changa')),
              Text("المدفوع: ${currency.format(r.paidAmount)}",
                  style: const TextStyle(
                      color: AppColors.green, fontFamily: 'Changa')),
              Text("المتبقي: ${currency.format(r.remaining)}",
                  style: const TextStyle(
                      color: Colors.orangeAccent, fontFamily: 'Changa')),
              const Divider(color: AppColors.gold),
              const Text("أضف دفعة جديدة:",
                  style: TextStyle(
                      color: AppColors.gold, fontFamily: 'Changa')),
              const SizedBox(height: 8),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(hintText: "المبلغ الإضافي"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              final add = double.tryParse(amountCtrl.text) ?? 0;
              if (add > 0) {
                fees.update(r.copyWith(
                  paidAmount: r.paidAmount + add,
                  lastPaymentDate: DateTime.now(),
                ));
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
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/school_data.dart';
import '../models/settings.dart';
import '../models/employee.dart';
import '../models/payroll.dart';
import '../models/defaults.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';
import '../widgets/common_widgets.dart';
import '../services/pdf_service.dart';

class PayrollScreen extends StatefulWidget {
  const PayrollScreen({super.key});
  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  int _month = DateFormatter.currentHijriMonth();
  int _year = DateFormatter.currentHijriYear();

  @override
  Widget build(BuildContext context) {
    final data = context.watch<SchoolDataProvider>();
    final settings = context.watch<SettingsProvider>();
    final primary = settings.primaryColor;
    final currency = settings.currencySymbol;

    final records = data.payrollForMonth(_month, _year);
    final summary = data.payrollSummary(_month, _year);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: settings.backgroundColor,
        title: Text("كشف الرواتب",
            style: TextStyle(color: primary, fontFamily: 'Changa')),
        iconTheme: IconThemeData(color: primary),
        actions: [
          IconButton(
            icon: Icon(Icons.print, color: primary),
            tooltip: "طباعة PDF",
            onPressed: () {
              if (records.isEmpty) {
                _snack(context, "لا يوجد سجلات للطباعة", Colors.orange);
                return;
              }
              PdfService.printPayroll(
                  data, _month, _year, DateFormatter.hijriMonths);
            },
          ),
        ],
      ),
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              _monthYearSelector(settings, primary),
              const SizedBox(height: 12),
              _summaryBox(summary, primary, currency),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SuccessButton(
                      label: "🔄 توليد الرواتب",
                      icon: Icons.auto_awesome,
                      color: primary,
                      onTap: () => _generateAll(context, data, currency),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SuccessButton(
                      label: "✅ دفع الكل",
                      icon: Icons.done_all,
                      color: AppColors.green,
                      onTap: () {
                        if (records.isEmpty) {
                          _snack(context, "لا يوجد رواتب", Colors.orange);
                          return;
                        }
                        _payAll(context, data, records);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: records.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.payments_outlined,
                                size: 80, color: Colors.white24),
                            const SizedBox(height: 12),
                            Text(
                                "لا توجد سجلات لـ ${DateFormatter.hijriMonths[_month - 1]} $_year",
                                style: const TextStyle(
                                    color: Colors.white54,
                                    fontFamily: 'Changa'),
                                textAlign: TextAlign.center),
                            const SizedBox(height: 8),
                            const Text(
                                "اضغط 'توليد الرواتب' لإنشاء كشف الشهر",
                                style: TextStyle(
                                    color: Colors.white38,
                                    fontFamily: 'Changa',
                                    fontSize: 12),
                                textAlign: TextAlign.center),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: records.length,
                        itemBuilder: (_, i) => _payrollCard(
                            context, data, settings, records[i], currency),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  //  📅 اختيار الشهر والسنة
  // ============================================================
  Widget _monthYearSelector(SettingsProvider s, Color primary) {
    final calType = s.calendarType;
    final hijriMonth = DateFormatter.hijriMonths[_month - 1];
    final gregYear = _year - 579;
    final gregMonth = DateFormatter.gregorianMonthName(_month);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.darkNavy,
        border: Border.all(color: primary, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _month,
                  isExpanded: true,
                  dropdownColor: AppColors.darkNavy,
                  decoration: const InputDecoration(
                      labelText: 'الشهر', isDense: true),
                  items: List.generate(12, (i) {
                    final m = i + 1;
                    final label = calType == CalendarType.gregorian
                        ? DateFormatter.gregorianMonthName(m)
                        : DateFormatter.hijriMonths[i];
                    return DropdownMenuItem(
                        value: m, child: Text(label));
                  }),
                  onChanged: (v) => setState(() => _month = v!),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 110,
                child: DropdownButtonFormField<int>(
                  value: _year,
                  isExpanded: true,
                  dropdownColor: AppColors.darkNavy,
                  decoration: const InputDecoration(
                      labelText: 'السنة', isDense: true),
                  items: [
                    for (int y = 1440; y <= 1460; y++)
                      DropdownMenuItem(
                        value: y,
                        child: Text(calType == CalendarType.gregorian
                            ? '${y - 579} م'
                            : '$y هـ'),
                      ),
                  ],
                  onChanged: (v) => setState(() => _year = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: [
                Icon(Icons.calendar_today,
                    color: primary, size: 14),
                const SizedBox(height: 4),
                if (calType == CalendarType.hijri)
                  Text("$hijriMonth $_year هـ",
                      style: TextStyle(
                          color: primary,
                          fontFamily: 'Changa',
                          fontSize: 13,
                          fontWeight: FontWeight.bold))
                else if (calType == CalendarType.gregorian)
                  Text("$gregMonth $gregYear م",
                      style: TextStyle(
                          color: primary,
                          fontFamily: 'Changa',
                          fontSize: 13,
                          fontWeight: FontWeight.bold))
                else
                  Column(
                    children: [
                      Text("$hijriMonth $_year هـ",
                          style: TextStyle(
                              color: primary,
                              fontFamily: 'Changa',
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                      Text("$gregMonth $gregYear م",
                          style: const TextStyle(
                              color: Colors.white54,
                              fontFamily: 'Changa',
                              fontSize: 11)),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryBox(
      PayrollSummary s, Color primary, String currency) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkNavy,
        border: Border.all(color: primary, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _sItem("👥", "الموظفون", "${s.totalEmployees}", primary),
              _sItem("💰", "الإجمالي",
                  "${s.totalNetSalary.toStringAsFixed(0)}",
                  AppColors.blue),
              _sItem("✅", "مدفوع",
                  "${s.totalPaid.toStringAsFixed(0)}", AppColors.green),
              _sItem("⏳", "متبقي",
                  "${s.totalRemaining.toStringAsFixed(0)}",
                  AppColors.orange),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: s.progressRatio,
              minHeight: 10,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(primary),
            ),
          ),
          const SizedBox(height: 4),
          Text(
              "نسبة الدفع: ${(s.progressRatio * 100).toStringAsFixed(1)}%",
              style: TextStyle(
                  color: primary,
                  fontFamily: 'Changa',
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _sItem(String emoji, String label, String value, Color color) {
    return Column(children: [
      Text(emoji, style: const TextStyle(fontSize: 18)),
      Text(value,
          style: TextStyle(
              color: color,
              fontFamily: 'Changa',
              fontWeight: FontWeight.bold,
              fontSize: 13)),
      Text(label,
          style: const TextStyle(
              color: Colors.white54, fontFamily: 'Changa', fontSize: 10)),
    ]);
  }

  Widget _payrollCard(BuildContext context, SchoolDataProvider data,
      SettingsProvider settings, PayrollRecord r, String currency) {
    final primary = settings.primaryColor;
    return Card(
      color: AppColors.darkNavy,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: r.status.color, width: 2),
      ),
      child: ListTile(
        onTap: () => _details(context, data, settings, r, currency),
        leading: CircleAvatar(
          backgroundColor: r.status.color.withOpacity(0.2),
          child: Icon(r.status.icon, color: r.status.color, size: 22),
        ),
        title: Text(r.employeeName,
            style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Changa',
                fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "${r.employeeType.label}${r.position.isNotEmpty ? ' • ${r.position}' : ''}",
                style: const TextStyle(
                    color: Colors.white70,
                    fontFamily: 'Changa',
                    fontSize: 11)),
            Text("💰 ${r.netSalary.toStringAsFixed(0)} $currency",
                style: TextStyle(
                    color: primary,
                    fontFamily: 'Changa',
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
            if (r.absenceDays > 0 ||
                r.incomes.isNotEmpty ||
                r.deductions.isNotEmpty)
              Text(
                [
                  if (r.incomes.isNotEmpty) "🎁 ${r.incomes.length}",
                  if (r.absenceDays > 0) "🚫 ${r.absenceDays}",
                  if (r.deductions.isNotEmpty)
                    "➖ ${r.deductions.length}",
                ].join(" • "),
                style: const TextStyle(
                    color: Colors.white38,
                    fontFamily: 'Changa',
                    fontSize: 10),
              ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: r.status.color,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(r.status.label,
              style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Changa',
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  // ============================================================
  //  🔄 توليد كل الرواتب
  // ============================================================
  void _generateAll(
      BuildContext context, SchoolDataProvider data, String currency) {
    if (data.employees.isEmpty) {
      _snack(context, "أضف موظفين أولاً", Colors.orange);
      return;
    }

    int created = 0;
    int skipped = 0;

    for (final e in data.employees) {
      final existing = data.payrollForEmployee(e.id, _month, _year);
      if (existing != null) {
        skipped++;
        continue;
      }

      final incomes = <PayItem>[...e.recurringIncome];
      final deductions = <PayItem>[...e.recurringDeductions];

      final activeAdvances =
          e.advances.where((a) => !a.isCompleted).toList();
      for (final a in activeAdvances) {
        deductions.add(PayItem(
          id: DateTime.now().microsecondsSinceEpoch.toString() + a.id,
          type: PayItemType.advance,
          amount: a.monthlyCut,
          note: 'قسط سلفة',
        ));
      }

      final record = PayrollRecord(
        id: '${e.id}_$_year$_month',
        employeeId: e.id,
        employeeName: e.name,
        employeeType: e.type,
        position: e.position,
        month: _month,
        year: _year,
        baseSalary: e.baseSalary,
        incomes: incomes,
        deductions: deductions,
        absenceDays: 0,
        advanceIds: activeAdvances.map((a) => a.id).toList(),
      );
      data.addPayroll(record);
      created++;
    }

    _snack(
      context,
      "تم توليد $created راتب${skipped > 0 ? ' • تم تجاهل $skipped موجود' : ''}",
      AppColors.green,
    );
  }

  // ============================================================
  //  📋 التفاصيل/تعديل
  // ============================================================
  void _details(BuildContext context, SchoolDataProvider data,
      SettingsProvider settings, PayrollRecord r, String currency) {
    final primary = settings.primaryColor;
    final incomes = <PayItem>[...r.incomes];
    final deductions = <PayItem>[...r.deductions];
    int absence = r.absenceDays;
    double paid = r.paidAmount;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkNavy,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setD) {
          final dayValue = r.baseSalary / 22;
          final absenceDed = absence * dayValue;
          final totalInc = incomes.fold(0.0, (s, i) => s + i.amount);
          final totalManualDed =
              deductions.fold(0.0, (s, i) => s + i.amount);
          final totalDed = totalManualDed + absenceDed;
          final net = (r.baseSalary + totalInc - totalDed);
          final netSafe = net < 0 ? 0.0 : net;

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(r.employeeName,
                          style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Changa')),
                    ),
                    Center(
                      child: Text(
                          "${r.employeeType.label} • ${r.periodLabel}",
                          style: const TextStyle(
                              color: Colors.white70,
                              fontFamily: 'Changa',
                              fontSize: 13)),
                    ),
                    const Divider(color: AppColors.gold),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Expanded(
                          child: Text("💰 الراتب الأساسي",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Changa',
                                  fontSize: 14)),
                        ),
                        Text(
                            "${r.baseSalary.toStringAsFixed(0)} $currency",
                            style: TextStyle(
                                color: primary,
                                fontFamily: 'Changa',
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 🎁 الحوافز
                    Row(
                      children: [
                        const Expanded(
                          child: Text("🎁 الحوافز",
                              style: TextStyle(
                                  color: AppColors.green,
                                  fontFamily: 'Changa',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                        ),
                        TextButton.icon(
                          onPressed: () => _addPayItemDialog(
                              ctx, true, currency, (item) {
                            setD(() => incomes.add(item));
                          }),
                          icon: const Icon(Icons.add,
                              color: AppColors.green, size: 18),
                          label: const Text("إضافة",
                              style: TextStyle(
                                  color: AppColors.green,
                                  fontFamily: 'Changa',
                                  fontSize: 12)),
                        ),
                      ],
                    ),
                    if (incomes.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(right: 16, bottom: 6),
                        child: Text("لا توجد حوافز",
                            style: TextStyle(
                                color: Colors.white38,
                                fontFamily: 'Changa',
                                fontSize: 11)),
                      )
                    else
                      ...incomes.asMap().entries.map((entry) {
                        final item = entry.value;
                        return Padding(
                          padding:
                              const EdgeInsets.only(right: 16, top: 2),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(item.displayName,
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontFamily: 'Changa',
                                        fontSize: 13)),
                              ),
                              Text(
                                  "+${item.amount.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                      color: AppColors.green,
                                      fontFamily: 'Changa',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints:
                                    const BoxConstraints(),
                                icon: const Icon(Icons.close,
                                    color: Colors.redAccent, size: 18),
                                onPressed: () => setD(
                                    () => incomes.removeAt(entry.key)),
                              ),
                            ],
                          ),
                        );
                      }),

                    const SizedBox(height: 8),

                    // ➖ الخصومات
                    Row(
                      children: [
                        const Expanded(
                          child: Text("➖ الخصومات",
                              style: TextStyle(
                                  color: Colors.redAccent,
                                  fontFamily: 'Changa',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                        ),
                        TextButton.icon(
                          onPressed: () => _addPayItemDialog(
                              ctx, false, currency, (item) {
                            setD(() => deductions.add(item));
                          }),
                          icon: const Icon(Icons.add,
                              color: Colors.redAccent, size: 18),
                          label: const Text("إضافة",
                              style: TextStyle(
                                  color: Colors.redAccent,
                                  fontFamily: 'Changa',
                                  fontSize: 12)),
                        ),
                      ],
                    ),
                    if (deductions.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(right: 16, bottom: 6),
                        child: Text("لا توجد خصومات",
                            style: TextStyle(
                                color: Colors.white38,
                                fontFamily: 'Changa',
                                fontSize: 11)),
                      )
                    else
                      ...deductions.asMap().entries.map((entry) {
                        final item = entry.value;
                        return Padding(
                          padding:
                              const EdgeInsets.only(right: 16, top: 2),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(item.displayName,
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontFamily: 'Changa',
                                        fontSize: 13)),
                              ),
                              Text(
                                  "-${item.amount.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontFamily: 'Changa',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints:
                                    const BoxConstraints(),
                                icon: const Icon(Icons.close,
                                    color: Colors.redAccent, size: 18),
                                onPressed: () => setD(() =>
                                    deductions.removeAt(entry.key)),
                              ),
                            ],
                          ),
                        );
                      }),

                    const SizedBox(height: 8),

                    // 🚫 الغياب
                    Row(
                      children: [
                        const Expanded(
                          child: Text("🚫 أيام الغياب",
                              style: TextStyle(
                                  color: Colors.orange,
                                  fontFamily: 'Changa',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline,
                              color: Colors.orange),
                          onPressed: absence > 0
                              ? () => setD(() => absence--)
                              : null,
                        ),
                        Text("$absence",
                            style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Changa',
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline,
                              color: Colors.orange),
                          onPressed: () => setD(() => absence++),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                          "قيمة اليوم: ${dayValue.toStringAsFixed(0)} $currency • خصم الغياب: ${absenceDed.toStringAsFixed(0)} $currency",
                          style: const TextStyle(
                              color: Colors.white38,
                              fontFamily: 'Changa',
                              fontSize: 11)),
                    ),

                    const Divider(color: AppColors.gold),

                    _calcRow("💰 الراتب الأساسي",
                        "+${r.baseSalary.toStringAsFixed(0)}", primary),
                    if (totalInc > 0)
                      _calcRow("🎁 إجمالي الحوافز",
                          "+${totalInc.toStringAsFixed(0)}",
                          AppColors.green),
                    if (totalDed > 0)
                      _calcRow("➖ إجمالي الخصومات",
                          "-${totalDed.toStringAsFixed(0)}",
                          Colors.redAccent),
                    const Divider(color: AppColors.gold),
                    Row(
                      children: [
                        const Expanded(
                          child: Text("💵 الصافي",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Changa',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ),
                        Text("${netSafe.toStringAsFixed(0)} $currency",
                            style: TextStyle(
                                color: primary,
                                fontFamily: 'Changa',
                                fontWeight: FontWeight.bold,
                                fontSize: 20)),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        const Expanded(
                          child: Text("✅ المدفوع",
                              style: TextStyle(
                                  color: AppColors.green,
                                  fontFamily: 'Changa',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                        ),
                        SizedBox(
                          width: 130,
                          child: TextField(
                            controller: TextEditingController(
                                text: paid.toStringAsFixed(0)),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            onChanged: (v) =>
                                paid = double.tryParse(v) ?? paid,
                            decoration: InputDecoration(
                              isDense: true,
                              suffixText: currency,
                              contentPadding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          tooltip: "دفع الكل",
                          icon: Icon(Icons.done_all, color: primary),
                          onPressed: () =>
                              setD(() => paid = netSafe),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              final newStatus =
                                  _calcStatus(paid, netSafe);
                              final updated = r.copyWith(
                                incomes: incomes,
                                deductions: deductions,
                                absenceDays: absence,
                                paidAmount: paid,
                                paymentDate:
                                    paid > 0 ? DateTime.now() : null,
                                status: newStatus,
                              );
                              data.updatePayroll(updated);
                              Navigator.pop(ctx);
                              _snack(context, "تم الحفظ",
                                  AppColors.green);
                            },
                            icon: const Icon(Icons.save),
                            label: const Text("حفظ",
                                style: TextStyle(
                                    fontFamily: 'Changa')),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primary,
                              side: BorderSide(color: primary, width: 2),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SuccessButton(
                            label: "✅ تأكيد الدفع",
                            icon: Icons.check_circle,
                            color: AppColors.green,
                            onTap: () {
                              final updated = r.copyWith(
                                incomes: incomes,
                                deductions: deductions,
                                absenceDays: absence,
                                paidAmount: netSafe,
                                paymentDate: DateTime.now(),
                                status: PaymentStatus.paid,
                              );
                              data.updatePayroll(updated);
                              Navigator.pop(ctx);
                              _snack(context, "تم تأكيد الدفع",
                                  AppColors.green);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          data.removePayroll(r.id);
                          Navigator.pop(ctx);
                        },
                        icon: const Icon(Icons.delete,
                            color: Colors.redAccent),
                        label: const Text("حذف السجل",
                            style: TextStyle(
                                color: Colors.redAccent,
                                fontFamily: 'Changa')),
                        style: OutlinedButton.styleFrom(
                          side:
                              const BorderSide(color: Colors.redAccent),
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  PaymentStatus _calcStatus(double paid, double net) {
    if (net == 0) return PaymentStatus.paid;
    if (paid >= net) return PaymentStatus.paid;
    if (paid > 0) return PaymentStatus.partial;
    return PaymentStatus.pending;
  }

  Widget _calcRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white70,
                    fontFamily: 'Changa',
                    fontSize: 13)),
          ),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontFamily: 'Changa',
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        ],
      ),
    );
  }

  // ============================================================
  //  ➕ نافذة إضافة بند مالي (يقرأ من DefaultsProvider)
  // ============================================================
  void _addPayItemDialog(BuildContext context, bool isIncome,
      String currency, Function(PayItem) onAdd) {
    final defaults = context.read<DefaultsProvider>();
    final names = isIncome ? defaults.incomes : defaults.deductions;

    String? selectedName =
        names.isNotEmpty ? names.first : null;
    PayItemType type =
        isIncome ? PayItemType.incentive : PayItemType.absence;
    final customCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          backgroundColor: AppColors.darkNavy,
          title: Text(isIncome ? "🎁 إضافة حافز" : "➖ إضافة خصم",
              style: const TextStyle(
                  color: AppColors.gold, fontFamily: 'Changa')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // البند — من القائمة الديناميكية
                DropdownButtonFormField<String>(
                  value: selectedName,
                  isExpanded: true,
                  dropdownColor: AppColors.darkNavy,
                  decoration: const InputDecoration(
                      labelText: "البند", isDense: true),
                  items: [
                    ...names.map((n) => DropdownMenuItem(
                        value: n,
                        child: Text(n,
                            style: TextStyle(
                                color: isIncome
                                    ? AppColors.green
                                    : Colors.redAccent)))),
                    const DropdownMenuItem(
                      value: '__custom__',
                      child: Text("📝 مخصص...",
                          style: TextStyle(
                              color: Colors.white70,
                              fontStyle: FontStyle.italic)),
                    ),
                  ],
                  onChanged: (v) => setD(() => selectedName = v),
                ),
                if (selectedName == '__custom__') ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: customCtrl,
                    decoration: const InputDecoration(
                        hintText: "اسم بند مخصص"),
                  ),
                ],
                const SizedBox(height: 8),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      hintText: "المبلغ", suffixText: currency),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(
                      hintText: "ملاحظة (اختياري)"),
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
                final amount = double.tryParse(amountCtrl.text) ?? 0;
                if (amount <= 0) return;

                String finalName;
                if (selectedName == '__custom__') {
                  if (customCtrl.text.trim().isEmpty) return;
                  finalName = customCtrl.text.trim();
                } else {
                  if (selectedName == null) return;
                  finalName = selectedName!;
                }

                onAdd(PayItem(
                  id: DateTime.now()
                      .millisecondsSinceEpoch
                      .toString(),
                  type: type,
                  customName: finalName,
                  amount: amount,
                  note: noteCtrl.text.trim(),
                ));
                Navigator.pop(ctx);
              },
              child: const Text("إضافة",
                  style: TextStyle(color: AppColors.gold)),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  //  ✅ دفع الكل
  // ============================================================
  void _payAll(BuildContext context, SchoolDataProvider data,
      List<PayrollRecord> records) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkNavy,
        title: const Text("✅ تأكيد دفع الكل",
            style: TextStyle(
                color: AppColors.green, fontFamily: 'Changa')),
        content: Text(
            "سيتم تأكيد دفع ${records.length} راتب بمبلغ إجمالي ${records.fold(0.0, (s, r) => s + r.netSalary).toStringAsFixed(0)}\n\nهل أنت متأكد؟",
            style: const TextStyle(
                color: Colors.white, fontFamily: 'Changa')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              for (final r in records) {
                final updated = r.copyWith(
                  paidAmount: r.netSalary,
                  paymentDate: DateTime.now(),
                  status: PaymentStatus.paid,
                );
                data.updatePayroll(updated);
              }
              Navigator.pop(context);
              _snack(context, "تم دفع الكل", AppColors.green);
            },
            child: const Text("تأكيد",
                style: TextStyle(color: AppColors.green)),
          ),
        ],
      ),
    );
  }

  void _snack(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }
}

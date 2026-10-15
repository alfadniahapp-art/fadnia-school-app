import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/school_data.dart';
import '../models/settings.dart';
import '../models/employee.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});
  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  EmployeeType? _filter;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final data = context.watch<SchoolDataProvider>();
    final settings = context.watch<SettingsProvider>();
    final primary = settings.primaryColor;
    final currency = settings.currencySymbol;

    var list = data.employees.where((e) {
      if (_filter != null && e.type != _filter) return false;
      if (_search.isNotEmpty && !e.name.contains(_search)) return false;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: settings.backgroundColor,
        title: Text("الموظفون",
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
              // ============ ملخص ============
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.darkNavy,
                  border: Border.all(color: primary, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _stat("👥", "العدد",
                        "${data.employees.length}", primary),
                    _stat("💰", "الرواتب الشهرية",
                        "${data.totalMonthlySalaries.toStringAsFixed(0)} $currency",
                        AppColors.blue),
                    _stat("🎁", "الحوافز الشهرية",
                        "${_totalRecurringIncome(data).toStringAsFixed(0)} $currency",
                        AppColors.green),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ============ الفلترة ============
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip("الكل", null, primary),
                    ...EmployeeType.values.map(
                        (t) => _filterChip(t.label, t, primary)),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // ============ البحث ============
              TextField(
                onChanged: (v) => setState(() => _search = v),
                decoration: InputDecoration(
                  hintText: "🔍 ابحث عن موظف",
                  prefixIcon: Icon(Icons.search, color: primary),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),

              // ============ القائمة ============
              Expanded(
                child: list.isEmpty
                    ? Center(
                        child: Text(
                          _search.isEmpty
                              ? "لا يوجد موظفون. اضغط + للإضافة"
                              : "لا توجد نتائج",
                          style: const TextStyle(
                              color: Colors.white54,
                              fontFamily: 'Changa'),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (_, i) {
                          final e = list[i];
                          final idx = data.employees.indexOf(e);
                          return _employeeCard(
                              context, data, settings, e, idx, currency);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _totalRecurringIncome(SchoolDataProvider data) {
    return data.employees.fold(
        0.0, (sum, e) => sum + e.totalRecurringIncome);
  }

  Widget _stat(String emoji, String label, String value, Color color) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        Text(value,
            style: TextStyle(
                color: color,
                fontFamily: 'Changa',
                fontWeight: FontWeight.bold,
                fontSize: 13)),
        Text(label,
            style: const TextStyle(
                color: Colors.white54,
                fontFamily: 'Changa',
                fontSize: 10)),
      ],
    );
  }

  Widget _filterChip(String label, EmployeeType? type, Color primary) {
    final selected = _filter == type;
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: ChoiceChip(
        label: Text(label,
            style: TextStyle(
                color: selected ? AppColors.darkest : primary,
                fontFamily: 'Changa',
                fontSize: 12)),
        selected: selected,
        selectedColor: primary,
        backgroundColor: AppColors.navy,
        onSelected: (_) => setState(() => _filter = type),
      ),
    );
  }

  Widget _employeeCard(BuildContext context, SchoolDataProvider data,
      SettingsProvider settings, Employee e, int idx, String currency) {
    return Card(
      color: AppColors.darkNavy,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        onTap: () => _details(context, data, settings, e, currency),
        leading: _photoAvatar(e.photoPath, e.type.icon),
        title: Text(e.name,
            style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Changa',
                fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${e.type.label}${e.position.isNotEmpty ? ' • ${e.position}' : ''}",
                style: const TextStyle(
                    color: Colors.white70,
                    fontFamily: 'Changa',
                    fontSize: 12)),
            Text("💰 ${e.baseSalary.toStringAsFixed(0)} $currency",
                style: TextStyle(
                    color: settings.primaryColor,
                    fontFamily: 'Changa',
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
            if (e.advances.where((a) => !a.isCompleted).isNotEmpty)
              Text(
                  "⚠️ سلف نشطة: ${e.advances.where((a) => !a.isCompleted).length}",
                  style: const TextStyle(
                      color: Colors.orange,
                      fontFamily: 'Changa',
                      fontSize: 10)),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: settings.primaryColor),
          color: AppColors.darkNavy,
          onSelected: (v) {
            if (v == 'edit') {
              _dialog(context, data, settings, editing: e, index: idx);
            } else if (v == 'delete') {
              _confirmDelete(context, data, e, idx);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
                value: 'edit',
                child: Text("تعديل",
                    style: TextStyle(
                        color: Colors.white, fontFamily: 'Changa'))),
            PopupMenuItem(
                value: 'delete',
                child: Text("حذف",
                    style: TextStyle(
                        color: Colors.redAccent, fontFamily: 'Changa'))),
          ],
        ),
      ),
    );
  }

  Widget _photoAvatar(String? path, IconData fallback) {
    if (path != null && File(path).existsSync()) {
      return CircleAvatar(
          radius: 24, backgroundImage: FileImage(File(path)));
    }
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.navy,
      child: Icon(fallback, color: AppColors.gold, size: 20),
    );
  }

  // ============ نافذة إضافة/تعديل ============
  void _dialog(BuildContext context, SchoolDataProvider data,
      SettingsProvider settings,
      {Employee? editing, int? index}) {
    final nameCtrl = TextEditingController(text: editing?.name ?? '');
    final posCtrl = TextEditingController(text: editing?.position ?? '');
    final phoneCtrl = TextEditingController(text: editing?.phone ?? '');
    final salaryCtrl = TextEditingController(
        text: editing?.baseSalary.toStringAsFixed(0) ?? '300000');
    final notesCtrl = TextEditingController(text: editing?.notes ?? '');

    EmployeeType type = editing?.type ?? EmployeeType.teacher;
    String? photo = editing?.photoPath;

    final incomes = <PayItem>[...(editing?.recurringIncome ?? [])];
    final deductions =
        <PayItem>[...(editing?.recurringDeductions ?? [])];
    final advances = <Advance>[...(editing?.advances ?? [])];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          backgroundColor: AppColors.darkNavy,
          title: Text(editing == null ? "إضافة موظف" : "تعديل الموظف",
              style: const TextStyle(
                  color: AppColors.gold, fontFamily: 'Changa')),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // الصورة
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final img = await picker.pickImage(
                            source: ImageSource.gallery);
                        if (img != null) setD(() => photo = img.path);
                      },
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.navy,
                        backgroundImage:
                            photo != null && File(photo!).existsSync()
                                ? FileImage(File(photo!))
                                : null,
                        child: photo == null
                            ? const Icon(Icons.camera_alt,
                                color: AppColors.gold, size: 28)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: nameCtrl,
                    decoration:
                        const InputDecoration(hintText: "اسم الموظف"),
                  ),
                  const SizedBox(height: 8),

                  DropdownButtonFormField<EmployeeType>(
                    value: type,
                    isExpanded: true,
                    dropdownColor: AppColors.darkNavy,
                    items: EmployeeType.values
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Row(
                                children: [
                                  Icon(t.icon,
                                      color: AppColors.gold, size: 18),
                                  const SizedBox(width: 8),
                                  Text(t.label),
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: (v) => setD(() => type = v!),
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    controller: posCtrl,
                    decoration:
                        const InputDecoration(hintText: "الوظيفة"),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration:
                        const InputDecoration(hintText: "رقم الهاتف"),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: salaryCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        hintText:
                            "الراتب الشهري (${settings.currencySymbol})"),
                  ),
                  const SizedBox(height: 12),

                  // ============ الحوافز الثابتة ============
                  _sectionLabel(
                      "🎁 الحوافز الثابتة (${incomes.length})"),
                  if (incomes.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: incomes
                          .map((item) => Chip(
                                label: Text(
                                    "${item.displayName}: ${item.amount.toStringAsFixed(0)}",
                                    style: const TextStyle(
                                        color: AppColors.darkest,
                                        fontFamily: 'Changa',
                                        fontSize: 11)),
                                backgroundColor: AppColors.green,
                                deleteIcon:
                                    const Icon(Icons.close, size: 16),
                                onDeleted: () =>
                                    setD(() => incomes.remove(item)),
                              ))
                          .toList(),
                    ),
                  TextButton.icon(
                    onPressed: () => _addItemDialog(
                        ctx,
                        true,
                        settings.currencySymbol,
                        (item) => setD(() => incomes.add(item))),
                    icon: const Icon(Icons.add, color: AppColors.green),
                    label: const Text("إضافة حافز",
                        style: TextStyle(
                            color: AppColors.green,
                            fontFamily: 'Changa')),
                  ),

                  // ============ الخصومات الثابتة ============
                  _sectionLabel(
                      "➖ الخصومات الثابتة (${deductions.length})"),
                  if (deductions.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: deductions
                          .map((item) => Chip(
                                label: Text(
                                    "${item.displayName}: ${item.amount.toStringAsFixed(0)}",
                                    style: const TextStyle(
                                        color: AppColors.darkest,
                                        fontFamily: 'Changa',
                                        fontSize: 11)),
                                backgroundColor: AppColors.red,
                                deleteIcon:
                                    const Icon(Icons.close, size: 16),
                                onDeleted: () =>
                                    setD(() => deductions.remove(item)),
                              ))
                          .toList(),
                    ),
                  TextButton.icon(
                    onPressed: () => _addItemDialog(
                        ctx,
                        false,
                        settings.currencySymbol,
                        (item) => setD(() => deductions.add(item))),
                    icon: const Icon(Icons.add, color: Colors.redAccent),
                    label: const Text("إضافة خصم",
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontFamily: 'Changa')),
                  ),

                  // ============ السلف ============
                  _sectionLabel("💵 السلف (${advances.length})"),
                  if (advances.isNotEmpty)
                    ...advances.asMap().entries.map((entry) {
                      final a = entry.value;
                      return Card(
                        color: AppColors.navy,
                        margin: const EdgeInsets.only(bottom: 4),
                        child: ListTile(
                          dense: true,
                          title: Text(
                              "سلفة: ${a.totalAmount.toStringAsFixed(0)}",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Changa',
                                  fontSize: 13)),
                          subtitle: Text(
                              "قسط شهري: ${a.monthlyCut.toStringAsFixed(0)} × ${a.months} شهر (${a.paidMonths}/${a.months})",
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontFamily: 'Changa',
                                  fontSize: 11)),
                          trailing: IconButton(
                            icon: const Icon(Icons.close,
                                color: Colors.redAccent, size: 18),
                            onPressed: () => setD(
                                () => advances.removeAt(entry.key)),
                          ),
                        ),
                      );
                    }),
                  TextButton.icon(
                    onPressed: () => _addAdvanceDialog(
                        ctx,
                        settings.currencySymbol,
                        (adv) => setD(() => advances.add(adv))),
                    icon: const Icon(Icons.add, color: Colors.orange),
                    label: const Text("إضافة سلفة",
                        style: TextStyle(
                            color: Colors.orange,
                            fontFamily: 'Changa')),
                  ),

                  const SizedBox(height: 8),
                  TextField(
                    controller: notesCtrl,
                    maxLines: 2,
                    decoration:
                        const InputDecoration(hintText: "📝 ملاحظات"),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("إلغاء"),
            ),
            TextButton(
              onPressed: () {
                if (nameCtrl.text.isEmpty) return;
                final salary =
                    double.tryParse(salaryCtrl.text) ?? 300000;
                final emp = Employee(
                  id: editing?.id ??
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameCtrl.text.trim(),
                  type: type,
                  position: posCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  baseSalary: salary,
                  photoPath: photo,
                  notes: notesCtrl.text.trim(),
                  recurringIncome: incomes,
                  recurringDeductions: deductions,
                  advances: advances,
                );
                if (editing == null) {
                  data.addEmployee(emp);
                } else {
                  data.updateEmployee(index!, emp);
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

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(text,
          style: const TextStyle(
              color: AppColors.gold,
              fontFamily: 'Changa',
              fontWeight: FontWeight.bold,
              fontSize: 13)),
    );
  }

  // ============ إضافة بند (حافز/خصم) ============
  void _addItemDialog(BuildContext context, bool isIncome,
      String currency, Function(PayItem) onAdd) {
    PayItemType type = isIncome
        ? PayItemType.incentive
        : PayItemType.absence;
    final customCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    final incomeTypes = PayItemType.values.where((t) => t.isIncome).toList();
    final deductionTypes =
        PayItemType.values.where((t) => t.isDeduction).toList();

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
                DropdownButtonFormField<PayItemType>(
                  value: type,
                  isExpanded: true,
                  dropdownColor: AppColors.darkNavy,
                  items: (isIncome ? incomeTypes : deductionTypes)
                      .map((t) => DropdownMenuItem(
                          value: t, child: Text(t.label)))
                      .toList(),
                  onChanged: (v) => setD(() => type = v!),
                ),
                if (type == PayItemType.custom) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: customCtrl,
                    decoration:
                        const InputDecoration(hintText: "اسم البند"),
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
                  decoration:
                      const InputDecoration(hintText: "ملاحظة (اختياري)"),
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
                onAdd(PayItem(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  type: type,
                  customName: customCtrl.text.trim(),
                  amount: amount,
                  note: noteCtrl.text.trim(),
                  isRecurring: true,
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

  // ============ إضافة سلفة ============
  void _addAdvanceDialog(BuildContext context, String currency,
      Function(Advance) onAdd) {
    final totalCtrl = TextEditingController();
    final monthlyCtrl = TextEditingController();
    final monthsCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          backgroundColor: AppColors.darkNavy,
          title: const Text("💵 إضافة سلفة",
              style: TextStyle(
                  color: AppColors.gold, fontFamily: 'Changa')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: totalCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: "المبلغ الإجمالي",
                      suffixText: currency),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: monthsCtrl,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: "عدد الشهور"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: monthlyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: "القسط الشهري",
                      suffixText: currency),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: reasonCtrl,
                  decoration: const InputDecoration(
                      labelText: "سبب السلفة (اختياري)"),
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () {
                    final total = double.tryParse(totalCtrl.text) ?? 0;
                    final months = int.tryParse(monthsCtrl.text) ?? 0;
                    if (total > 0 && months > 0) {
                      setD(() => monthlyCtrl.text =
                          (total / months).toStringAsFixed(0));
                    }
                  },
                  child: const Text("حساب القسط تلقائياً",
                      style: TextStyle(color: AppColors.gold)),
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
                final monthly = double.tryParse(monthlyCtrl.text) ?? 0;
                final months = int.tryParse(monthsCtrl.text) ?? 0;
                if (total <= 0 || monthly <= 0 || months <= 0) return;
                onAdd(Advance(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  totalAmount: total,
                  monthlyCut: monthly,
                  months: months,
                  startDate: DateTime.now(),
                  reason: reasonCtrl.text.trim(),
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

  // ============ التفاصيل ============
  void _details(BuildContext context, SchoolDataProvider data,
      SettingsProvider settings, Employee e, String currency) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkNavy,
      isScrollControlled: true,
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
                child: _photoAvatar(e.photoPath, e.type.icon),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(e.name,
                    style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Changa')),
              ),
              Center(
                child: Text(
                    "${e.type.label}${e.position.isNotEmpty ? ' • ${e.position}' : ''}",
                    style: const TextStyle(
                        color: Colors.white70, fontFamily: 'Changa')),
              ),
              const Divider(color: AppColors.gold),

              _row(Icons.phone, "الهاتف",
                  e.phone.isEmpty ? '-' : e.phone),
              _row(Icons.attach_money, "الراتب الأساسي",
                  "${e.baseSalary.toStringAsFixed(0)} $currency"),

              if (e.recurringIncome.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Text("🎁 الحوافز الثابتة:",
                    style: TextStyle(
                        color: AppColors.green,
                        fontFamily: 'Changa',
                        fontWeight: FontWeight.bold)),
                ...e.recurringIncome.map((item) => Padding(
                      padding: const EdgeInsets.only(right: 16, top: 4),
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
                              "+${item.amount.toStringAsFixed(0)} $currency",
                              style: const TextStyle(
                                  color: AppColors.green,
                                  fontFamily: 'Changa',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                        ],
                      ),
                    )),
              ],

              if (e.recurringDeductions.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Text("➖ الخصومات الثابتة:",
                    style: TextStyle(
                        color: Colors.redAccent,
                        fontFamily: 'Changa',
                        fontWeight: FontWeight.bold)),
                ...e.recurringDeductions.map((item) => Padding(
                      padding: const EdgeInsets.only(right: 16, top: 4),
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
                              "-${item.amount.toStringAsFixed(0)} $currency",
                              style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontFamily: 'Changa',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                        ],
                      ),
                    )),
              ],

              if (e.advances.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Text("💵 السلف:",
                    style: TextStyle(
                        color: Colors.orange,
                        fontFamily: 'Changa',
                        fontWeight: FontWeight.bold)),
                ...e.advances.map((a) => Padding(
                      padding: const EdgeInsets.only(right: 16, top: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                                "قسط: ${a.monthlyCut.toStringAsFixed(0)} $currency (${a.paidMonths}/${a.months})",
                                style: const TextStyle(
                                    color: Colors.white70,
                                    fontFamily: 'Changa',
                                    fontSize: 13)),
                          ),
                          if (a.isCompleted)
                            const Icon(Icons.check_circle,
                                color: Colors.green, size: 18)
                          else
                            Text(
                                "متبقي: ${a.remainingAmount.toStringAsFixed(0)}",
                                style: const TextStyle(
                                    color: Colors.orange,
                                    fontFamily: 'Changa',
                                    fontSize: 12)),
                        ],
                      ),
                    )),
              ],

              const Divider(color: AppColors.gold),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  border: Border.all(
                      color: settings.primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text("💵 صافي الراتب المتوقع",
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Changa',
                              fontWeight: FontWeight.bold)),
                    ),
                    Text(
                      "${_netSalary(e).toStringAsFixed(0)} $currency",
                      style: TextStyle(
                          color: settings.primaryColor,
                          fontFamily: 'Changa',
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _netSalary(Employee e) {
    final net = e.baseSalary +
        e.totalRecurringIncome -
        e.totalRecurringDeductions -
        e.totalActiveAdvancesCut;
    return net < 0 ? 0 : net;
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold, size: 18),
          const SizedBox(width: 8),
          Text("$label: ",
              style: const TextStyle(
                  color: Colors.white54, fontFamily: 'Changa')),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Changa',
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, SchoolDataProvider data,
      Employee e, int idx) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkNavy,
        title: const Text("تأكيد الحذف",
            style: TextStyle(
                color: Colors.redAccent, fontFamily: 'Changa')),
        content: Text("حذف الموظف: ${e.name}؟",
            style: const TextStyle(
                color: Colors.white, fontFamily: 'Changa')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              data.removeEmployee(idx);
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

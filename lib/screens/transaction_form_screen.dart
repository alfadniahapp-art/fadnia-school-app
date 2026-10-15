import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/school_data.dart';
import '../models/settings.dart';
import '../models/finance.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class TransactionFormScreen extends StatefulWidget {
  final TransactionType initialType;
  final FinanceTransaction? editing;

  const TransactionFormScreen({
    super.key,
    this.initialType = TransactionType.receipt,
    this.editing,
  });

  @override
  State<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  late TransactionType _type;
  late TextEditingController _amountCtrl;
  late TextEditingController _partyCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _notesCtrl;
  late TextEditingController _refCtrl;

  String? _accountId;
  String? _categoryName;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _type = e?.type ?? widget.initialType;
    _amountCtrl = TextEditingController(
        text: e?.amount.toStringAsFixed(0) ?? '');
    _partyCtrl = TextEditingController(text: e?.party ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _notesCtrl = TextEditingController(text: e?.notes ?? '');
    _refCtrl = TextEditingController(text: e?.reference ?? '');
    _accountId = e?.accountId;
    _categoryName = e?.categoryName;
    _date = e?.date ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<SchoolDataProvider>();
    final settings = context.watch<SettingsProvider>();
    final primary = settings.primaryColor;
    final currency = settings.currencySymbol;

    // تعيين الحساب الافتراضي إن لم يُحدد
    _accountId ??= data.defaultAccount.id;

    final isEditing = widget.editing != null;
    final categories = _type == TransactionType.receipt
        ? FinanceCategory.defaultReceipts
        : FinanceCategory.defaultPayments;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: settings.backgroundColor,
        title: Text(
            isEditing
                ? "تعديل حركة"
                : (_type == TransactionType.receipt
                    ? "سند قبض"
                    : "سند صرف"),
            style: TextStyle(color: primary, fontFamily: 'Changa')),
        iconTheme: IconThemeData(color: primary),
      ),
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============ نوع الحركة ============
              if (!isEditing) ...[
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.darkNavy,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _typeTab(
                            "📥 قبض",
                            TransactionType.receipt,
                            AppColors.green,
                            primary),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _typeTab(
                            "📤 صرف",
                            TransactionType.payment,
                            AppColors.red,
                            primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
              ] else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _type.color.withOpacity(0.15),
                    border: Border.all(color: _type.color, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_type.icon, color: _type.color, size: 24),
                      const SizedBox(width: 8),
                      Text(
                          _type == TransactionType.receipt
                              ? "سند قبض"
                              : "سند صرف",
                          style: TextStyle(
                              color: _type.color,
                              fontFamily: 'Changa',
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ],
                  ),
                ),

              const SizedBox(height: 15),

              // ============ المبلغ ============
              _label("💰 المبلغ *", primary),
              TextField(
                controller: _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Changa',
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "0",
                  suffixText: currency,
                  suffixStyle: TextStyle(
                      color: primary,
                      fontFamily: 'Changa',
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 18, horizontal: 12),
                ),
              ),

              const SizedBox(height: 15),

              // ============ الحساب ============
              _label("🏦 الحساب *", primary),
              DropdownButtonFormField<String>(
                value: _accountId,
                isExpanded: true,
                dropdownColor: AppColors.darkNavy,
                items: data.financeAccounts
                    .map((a) => DropdownMenuItem(
                          value: a.id,
                          child: Row(
                            children: [
                              Icon(a.type.icon,
                                  color: a.type.color, size: 18),
                              const SizedBox(width: 8),
                              Text(a.name),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _accountId = v),
              ),

              const SizedBox(height: 15),

              // ============ البند ============
              _label("📂 البند *", primary),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.darkNavy,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: categories.map((c) {
                    final name = c['name'] as String;
                    final icon = c['icon'] as IconData;
                    final selected = _categoryName == name;
                    return ChoiceChip(
                      avatar: Icon(icon,
                          size: 16,
                          color: selected
                              ? AppColors.darkest
                              : primary),
                      label: Text(name,
                          style: TextStyle(
                              color: selected
                                  ? AppColors.darkest
                                  : primary,
                              fontFamily: 'Changa',
                              fontSize: 12)),
                      selected: selected,
                      selectedColor: primary,
                      backgroundColor: AppColors.navy,
                      onSelected: (_) =>
                          setState(() => _categoryName = name),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 15),

              // ============ المستلم/الدافع ============
              _label(
                  _type == TransactionType.receipt
                      ? "👤 الدافع"
                      : "👤 المستلم",
                  primary),
              TextField(
                controller: _partyCtrl,
                decoration: InputDecoration(
                    hintText: _type == TransactionType.receipt
                        ? "اسم الدافع"
                        : "اسم المستلم"),
              ),

              const SizedBox(height: 15),

              // ============ التاريخ ============
              _label("📅 التاريخ", primary),
              GestureDetector(
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (d != null) setState(() => _date = d);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.darkNavy,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today,
                          color: primary, size: 20),
                      const SizedBox(width: 10),
                      Text(
                          DateFormat('yyyy/MM/dd').format(_date),
                          style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Changa',
                              fontSize: 14)),
                      const Spacer(),
                      Icon(Icons.edit, color: primary, size: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // ============ رقم السند ============
              _label("🔢 رقم السند (اختياري)", primary),
              TextField(
                controller: _refCtrl,
                decoration: InputDecoration(
                  hintText: isEditing
                      ? ""
                      : data.nextReference(_type),
                  prefixIcon:
                      Icon(Icons.numbers, color: primary, size: 18),
                ),
              ),

              const SizedBox(height: 15),

              // ============ البيان ============
              _label("📝 البيان", primary),
              TextField(
                controller: _descCtrl,
                maxLines: 2,
                decoration:
                    const InputDecoration(hintText: "وصف مختصر"),
              ),

              const SizedBox(height: 15),

              // ============ ملاحظات ============
              _label("📋 ملاحظات", primary),
              TextField(
                controller: _notesCtrl,
                maxLines: 2,
                decoration:
                    const InputDecoration(hintText: "ملاحظات إضافية"),
              ),

              const SizedBox(height: 25),

              // ============ أزرار ============
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text("إلغاء",
                          style: TextStyle(fontFamily: 'Changa')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white30),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: SuccessButton(
                      label: isEditing
                          ? "💾 حفظ التعديلات"
                          : "💾 حفظ السند",
                      icon: Icons.save,
                      color: _type.color,
                      onTap: () => _save(context, data),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeTab(String label, TransactionType type, Color color,
      Color primary) {
    final selected = _type == type;
    return GestureDetector(
      onTap: () => setState(() {
        _type = type;
        _categoryName = null;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(
                  color: selected ? Colors.white : primary,
                  fontFamily: 'Changa',
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ),
      ),
    );
  }

  Widget _label(String text, Color primary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: TextStyle(
              color: primary,
              fontFamily: 'Changa',
              fontSize: 13,
              fontWeight: FontWeight.bold)),
    );
  }

  void _save(BuildContext context, SchoolDataProvider data) {
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      _snack(context, "أدخل مبلغاً صحيحاً", Colors.redAccent);
      return;
    }
    if (_accountId == null) {
      _snack(context, "اختر الحساب", Colors.redAccent);
      return;
    }
    if (_categoryName == null) {
      _snack(context, "اختر البند", Colors.redAccent);
      return;
    }

    final reference = _refCtrl.text.trim().isEmpty
        ? (widget.editing?.reference ?? data.nextReference(_type))
        : _refCtrl.text.trim();

    if (widget.editing == null) {
      // إضافة جديدة
      data.addTransaction(FinanceTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        accountId: _accountId!,
        type: _type,
        amount: amount,
        categoryName: _categoryName!,
        date: _date,
        description: _descCtrl.text.trim(),
        reference: reference,
        party: _partyCtrl.text.trim(),
        source: TransactionSource.manual,
        notes: _notesCtrl.text.trim(),
      ));
      _snack(context, "تم حفظ السند بنجاح", AppColors.green);
    } else {
      // تعديل
      data.updateTransaction(FinanceTransaction(
        id: widget.editing!.id,
        accountId: _accountId!,
        type: _type,
        amount: amount,
        categoryName: _categoryName!,
        date: _date,
        description: _descCtrl.text.trim(),
        reference: reference,
        party: _partyCtrl.text.trim(),
        source: widget.editing!.source,
        linkedId: widget.editing!.linkedId,
        notes: _notesCtrl.text.trim(),
      ));
      _snack(context, "تم تحديث السند", AppColors.green);
    }

    Navigator.pop(context);
  }

  void _snack(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }
}

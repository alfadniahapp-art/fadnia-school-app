import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/school_data.dart';
import '../models/settings.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});
  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  String? _cls;
  final _subjCtrl = TextEditingController();

  static const _quickSubjects = [
    'لغة عربية',
    'لغة عربية - قواعد',
    'لغة عربية - أدب',
    'لغة عربية - نصوص',
    'لغة عربية - إملاء',
    'رياضيات',
    'علوم',
    'أحياء',
    'فيزياء',
    'كيمياء',
    'تاريخ',
    'جغرافيا',
    'تربية إسلامية',
    'تربية وطنية',
    'لغة إنجليزية',
    'حاسوب',
    'تربية فنية',
    'تربية بدنية',
  ];

  @override
  Widget build(BuildContext context) {
    final data = context.watch<SchoolDataProvider>();
    final settings = context.watch<SettingsProvider>();
    _cls ??= data.classes.first;
    final subjects = data.subjectsOf(_cls!);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: settings.backgroundColor,
        title: Text("تقسيم المواد",
            style: TextStyle(
                color: settings.primaryColor, fontFamily: 'Changa')),
        iconTheme: IconThemeData(color: settings.primaryColor),
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

              // ============ إضافة مادة ============
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _subjCtrl,
                    decoration: const InputDecoration(
                      hintText: "اسم المادة الجديدة",
                      prefixIcon: Icon(Icons.book, color: AppColors.gold),
                    ),
                    onSubmitted: (v) => _addSubject(data),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _addSubject(data),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        settings.primaryColor.withOpacity(0.15),
                    side: BorderSide(
                        color: settings.primaryColor, width: 2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                  child: Icon(Icons.add,
                      color: settings.primaryColor, size: 28),
                ),
              ]),

              const SizedBox(height: 15),

              // ============ المواد السريعة ============
              if (subjects.isEmpty)
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("⚡ إضافة سريعة:",
                          style: TextStyle(
                              color: Colors.white70,
                              fontFamily: 'Changa',
                              fontSize: 13)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _quickSubjects
                            .map((s) => ActionChip(
                                  label: Text(s,
                                      style: TextStyle(
                                          color: settings.primaryColor,
                                          fontFamily: 'Changa',
                                          fontSize: 12)),
                                  backgroundColor: AppColors.navy,
                                  side: BorderSide(
                                      color: settings.primaryColor
                                          .withOpacity(0.4)),
                                  onPressed: () {
                                    data.addSubject(_cls!, s);
                                  },
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 15),

              // ============ عدد المواد ============
              if (subjects.isNotEmpty)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text("📚 عدد المواد: ${subjects.length}",
                        style: TextStyle(
                            color: settings.primaryColor,
                            fontFamily: 'Changa',
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                  ),
                ),

              // ============ قائمة المواد ============
              Expanded(
                child: subjects.isEmpty
                    ? const Center(
                        child: Text("لا توجد مواد بعد",
                            style: TextStyle(
                                color: Colors.white54,
                                fontFamily: 'Changa')),
                      )
                    : ListView.builder(
                        itemCount: subjects.length,
                        itemBuilder: (_, i) {
                          final s = subjects[i];
                          final teachers =
                              data.teachersForSubject(s);
                          return Card(
                            color: AppColors.darkNavy,
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                  color: AppColors.border),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.navy,
                                child: Icon(Icons.book,
                                    color: settings.primaryColor,
                                    size: 20),
                              ),
                              title: Text(s,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Changa',
                                      fontWeight: FontWeight.bold)),
                              subtitle: teachers.isEmpty
                                  ? const Text(
                                      "⚠️ لا يوجد معلم لهذه المادة",
                                      style: TextStyle(
                                          color: Colors.orange,
                                          fontFamily: 'Changa',
                                          fontSize: 11))
                                  : Text(
                                      "👨‍🏫 ${teachers.map((t) => t.name).join(' • ')}",
                                      style: const TextStyle(
                                          color: Colors.white54,
                                          fontFamily: 'Changa',
                                          fontSize: 11)),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.redAccent),
                                onPressed: () =>
                                    _confirmDelete(context, data, s),
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

  void _addSubject(SchoolDataProvider data) {
    final v = _subjCtrl.text.trim();
    if (v.isEmpty) return;
    data.addSubject(_cls!, v);
    _subjCtrl.clear();
    FocusScope.of(context).unfocus();
  }

  void _confirmDelete(
      BuildContext context, SchoolDataProvider data, String subject) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkNavy,
        title: const Text("تأكيد الحذف",
            style: TextStyle(
                color: Colors.redAccent, fontFamily: 'Changa')),
        content: Text("حذف المادة: $subject؟",
            style: const TextStyle(
                color: Colors.white, fontFamily: 'Changa')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              data.removeSubject(_cls!, subject);
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

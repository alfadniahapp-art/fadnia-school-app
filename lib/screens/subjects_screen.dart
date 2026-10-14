import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/school_data.dart';
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

  @override
  Widget build(BuildContext context) {
    final data = context.watch<SchoolDataProvider>();
    _cls ??= data.classes.first;
    final subjects = data.subjectsOf(_cls!);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkNavy,
        title: const Text("تقسيم المواد",
            style: TextStyle(color: AppColors.gold, fontFamily: 'Changa')),
        iconTheme: const IconThemeData(color: AppColors.gold),
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
              const CustomLabel("إضافة مادة:"),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _subjCtrl,
                    decoration:
                        const InputDecoration(hintText: "مثال: رياضيات"),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_subjCtrl.text.isNotEmpty) {
                      data.addSubject(_cls!, _subjCtrl.text.trim());
                      _subjCtrl.clear();
                      FocusScope.of(context).unfocus();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green.withOpacity(0.2),
                    side: const BorderSide(color: AppColors.green, width: 2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                  ),
                  child: const Text("إضافة",
                      style: TextStyle(
                          color: AppColors.gold, fontFamily: 'Changa')),
                ),
              ]),
              const SizedBox(height: 15),
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
                        itemBuilder: (_, i) => Card(
                          color: AppColors.darkNavy,
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side:
                                const BorderSide(color: AppColors.border),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.book,
                                color: AppColors.gold),
                            title: Text(subjects[i],
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Changa')),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.redAccent),
                              onPressed: () =>
                                  data.removeSubject(_cls!, subjects[i]),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

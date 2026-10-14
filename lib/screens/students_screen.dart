import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/school_data.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});
  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  String? _cls;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<SchoolDataProvider>();
    _cls ??= data.classes.first;
    final students = data.studentsOf(_cls!);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkNavy,
        title: const Text("قائمة الطلاب",
            style: TextStyle(color: AppColors.gold, fontFamily: 'Changa')),
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.gold,
        onPressed: () => _addStudentDialog(context, data),
        child: const Icon(Icons.add, color: AppColors.darkNavy),
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
              Expanded(
                child: students.isEmpty
                    ? const Center(
                        child: Text("لا يوجد طلاب في هذا الفصل",
                            style: TextStyle(
                                color: Colors.white54,
                                fontFamily: 'Changa')),
                      )
                    : ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (_, i) {
                          final s = students[i];
                          final idx = data.students.indexOf(s);
                          return Card(
                            color: AppColors.darkNavy,
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                  color: AppColors.border),
                            ),
                            child: ListTile(
                              onTap: () => _showStudentDetails(
                                  context, data, s, idx),
                              leading: _photoAvatar(s.photoPath, '${i + 1}'),
                              title: Text(s.name,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Changa',
                                      fontSize: 15)),
                              subtitle: Text(s.classRoom,
                                  style: const TextStyle(
                                      color: Colors.white54,
                                      fontFamily: 'Changa',
                                      fontSize: 12)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                        Icons.camera_alt,
                                        color: AppColors.blue),
                                    onPressed: () async {
                                      final picker = ImagePicker();
                                      final img = await picker.pickImage(
                                          source: ImageSource.gallery);
                                      if (img != null) {
                                        data.updateStudentPhoto(
                                            idx, img.path);
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.redAccent),
                                    onPressed: () =>
                                        data.removeStudent(idx),
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

  Widget _photoAvatar(String? path, String fallback) {
    if (path != null && File(path).existsSync()) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: FileImage(File(path)),
      );
    }
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.navy,
      child: Text(fallback,
          style: const TextStyle(
              color: AppColors.gold, fontFamily: 'Changa')),
    );
  }

  void _addStudentDialog(BuildContext context, SchoolDataProvider data) {
    final nameCtrl = TextEditingController();
    String? photo;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          backgroundColor: AppColors.darkNavy,
          title: const Text("إضافة طالب",
              style: TextStyle(
                  color: AppColors.gold, fontFamily: 'Changa')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
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
                            color: AppColors.gold, size: 30)
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                const Text("اضغط لاختيار صورة (اختياري)",
                    style: TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        fontFamily: 'Changa')),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration:
                      const InputDecoration(hintText: "اسم الطالب"),
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
                if (nameCtrl.text.isNotEmpty) {
                  data.addStudent(nameCtrl.text.trim(), _cls!,
                      photoPath: photo);
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

  void _showStudentDetails(BuildContext context, SchoolDataProvider data,
      Student s, int idx) {
    final grades = data.grades[s.classRoom]?[s.name] ?? {};
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
          children: [
            _photoAvatar(s.photoPath, s.name.substring(0, 1)),
            const SizedBox(height: 10),
            Text(s.name,
                style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Changa')),
            Text(s.classRoom,
                style: const TextStyle(
                    color: Colors.white70, fontFamily: 'Changa')),
            const Divider(color: AppColors.gold),
            if (grades.isEmpty)
              const Text("لا توجد درجات مسجلة",
                  style: TextStyle(
                      color: Colors.white54, fontFamily: 'Changa'))
            else
              ...grades.entries.map((e) => ListTile(
                    dense: true,
                    title: Text(e.key,
                        style: const TextStyle(
                            color: Colors.white, fontFamily: 'Changa')),
                    trailing: Text(e.value.toStringAsFixed(0),
                        style: const TextStyle(
                            color: AppColors.gold,
                            fontFamily: 'Changa',
                            fontWeight: FontWeight.bold)),
                  )),
          ],
        ),
      ),
    );
  }
}

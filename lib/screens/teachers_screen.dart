import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/school_data.dart';
import '../models/settings.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class TeachersScreen extends StatefulWidget {
  const TeachersScreen({super.key});
  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  @override
  Widget build(BuildContext context) {
    final data = context.watch<SchoolDataProvider>();
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: settings.backgroundColor,
        title: Text("أسماء المعلمين",
            style: TextStyle(
                color: settings.primaryColor, fontFamily: 'Changa')),
        iconTheme: IconThemeData(color: settings.primaryColor),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: settings.primaryColor,
        onPressed: () => _teacherDialog(context, data),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: data.teachers.isEmpty
              ? const Center(
                  child: Text("لا يوجد معلمون. اضغط + للإضافة",
                      style: TextStyle(
                          color: Colors.white54, fontFamily: 'Changa')))
              : ListView.builder(
                  itemCount: data.teachers.length,
                  itemBuilder: (_, i) {
                    final t = data.teachers[i];
                    return Card(
                      color: AppColors.darkNavy,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: ListTile(
                        onTap: () => _showDetails(context, data, t, i),
                        leading: _photoAvatar(t.photoPath),
                        title: Text(t.name,
                            style: const TextStyle(
                                color: AppColors.gold,
                                fontFamily: 'Changa',
                                fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (t.subjects.isNotEmpty)
                              Text("📚 ${t.subjects.join(' • ')}",
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontFamily: 'Changa',
                                      fontSize: 12)),
                            if (t.phone.isNotEmpty)
                              Text("📞 ${t.phone}",
                                  style: const TextStyle(
                                      color: Colors.white38,
                                      fontFamily: 'Changa',
                                      fontSize: 11)),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert,
                              color: settings.primaryColor),
                          color: AppColors.darkNavy,
                          onSelected: (v) async {
                            if (v == 'photo') {
                              final picker = ImagePicker();
                              final img = await picker.pickImage(
                                  source: ImageSource.gallery);
                              if (img != null) {
                                data.updateTeacher(
                                    i,
                                    Teacher(
                                      name: t.name,
                                      degree: t.degree,
                                      certificate: t.certificate,
                                      phone: t.phone,
                                      subjects: t.subjects,
                                      photoPath: img.path,
                                    ));
                              }
                            } else if (v == 'edit') {
                              _teacherDialog(context, data,
                                  editing: t, index: i);
                            } else if (v == 'delete') {
                              data.removeTeacher(i);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                                value: 'photo',
                                child: Text("تغيير الصورة",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Changa'))),
                            PopupMenuItem(
                                value: 'edit',
                                child: Text("تعديل",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Changa'))),
                            PopupMenuItem(
                                value: 'delete',
                                child: Text("حذف",
                                    style: TextStyle(
                                        color: Colors.redAccent,
                                        fontFamily: 'Changa'))),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _photoAvatar(String? path) {
    if (path != null && File(path).existsSync()) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: FileImage(File(path)),
      );
    }
    return const CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.navy,
      child: Icon(Icons.person, color: AppColors.gold),
    );
  }

  void _teacherDialog(BuildContext context, SchoolDataProvider data,
      {Teacher? editing, int? index}) {
    final nameCtrl = TextEditingController(text: editing?.name ?? '');
    final degreeCtrl = TextEditingController(text: editing?.degree ?? '');
    final certCtrl = TextEditingController(text: editing?.certificate ?? '');
    final phoneCtrl = TextEditingController(text: editing?.phone ?? '');
    final subjects = <String>[...(editing?.subjects ?? [])];
    final newSubjCtrl = TextEditingController();
    String? photo = editing?.photoPath;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          backgroundColor: AppColors.darkNavy,
          title: Text(editing == null ? "إضافة معلم" : "تعديل المعلم",
              style: const TextStyle(
                  color: AppColors.gold, fontFamily: 'Changa')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final img = await picker.pickImage(
                        source: ImageSource.gallery);
                    if (img != null) setD(() => photo = img.path);
                  },
                  child: Center(
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
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(hintText: "اسم المعلم"),
                ),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: degreeCtrl,
                      decoration:
                          const InputDecoration(hintText: "الدرجة"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: certCtrl,
                      decoration:
                          const InputDecoration(hintText: "الشهادة"),
                    ),
                  ),
                ]),
                const SizedBox(height: 8),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(hintText: "رقم الهاتف"),
                ),
                const SizedBox(height: 12),
                const Text("📚 المواد التي يدرّسها:",
                    style: TextStyle(
                        color: AppColors.gold,
                        fontFamily: 'Changa',
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: subjects
                      .map((s) => Chip(
                            label: Text(s,
                                style: const TextStyle(
                                    color: AppColors.darkest,
                                    fontFamily: 'Changa',
                                    fontSize: 12)),
                            backgroundColor: AppColors.gold,
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () =>
                                setD(() => subjects.remove(s)),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 6),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: newSubjCtrl,
                      decoration: const InputDecoration(
                          hintText: "أضف مادة..."),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.add_circle,
                        color: AppColors.green, size: 30),
                    onPressed: () {
                      final v = newSubjCtrl.text.trim();
                      if (v.isNotEmpty && !subjects.contains(v)) {
                        setD(() => subjects.add(v));
                        newSubjCtrl.clear();
                      }
                    },
                  ),
                ]),
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
                if (nameCtrl.text.isEmpty) return;
                final teacher = Teacher(
                  name: nameCtrl.text.trim(),
                  degree: degreeCtrl.text.trim(),
                  certificate: certCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  subjects: subjects,
                  photoPath: photo,
                );
                if (editing == null) {
                  data.addTeacher(teacher);
                } else {
                  data.updateTeacher(index!, teacher);
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

  void _showDetails(BuildContext context, SchoolDataProvider data,
      Teacher t, int idx) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: _photoAvatar(t.photoPath)),
            const SizedBox(height: 12),
            Center(
              child: Text(t.name,
                  style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Changa')),
            ),
            const SizedBox(height: 20),
            if (t.degree.isNotEmpty)
              _row(Icons.military_tech, "الدرجة", t.degree),
            if (t.certificate.isNotEmpty)
              _row(Icons.school, "الشهادة", t.certificate),
            if (t.phone.isNotEmpty)
              _row(Icons.phone, "الهاتف", t.phone),
            if (t.subjects.isNotEmpty)
              _row(Icons.book, "المواد", t.subjects.join(' • ')),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _teacherDialog(context, data, editing: t, index: idx);
                },
                icon: const Icon(Icons.edit),
                label: const Text("تعديل",
                    style: TextStyle(fontFamily: 'Changa')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.darkest,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold, size: 20),
          const SizedBox(width: 10),
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
}

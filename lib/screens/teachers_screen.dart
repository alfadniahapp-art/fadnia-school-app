import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/school_data.dart';
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkNavy,
        title: const Text("أسماء المعلمين",
            style: TextStyle(color: AppColors.gold, fontFamily: 'Changa')),
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.gold,
        onPressed: () => _addTeacherDialog(context, data),
        child: const Icon(Icons.add, color: AppColors.darkNavy),
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
                        leading: _photoAvatar(t.photoPath),
                        title: Text(t.name,
                            style: const TextStyle(
                                color: AppColors.gold,
                                fontFamily: 'Changa',
                                fontWeight: FontWeight.bold)),
                        subtitle: Text(t.subject,
                            style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Changa')),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.camera_alt,
                                  color: AppColors.blue),
                              onPressed: () async {
                                final picker = ImagePicker();
                                final img = await picker.pickImage(
                                    source: ImageSource.gallery);
                                if (img != null) {
                                  data.updateTeacherPhoto(i, img.path);
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.redAccent),
                              onPressed: () => data.removeTeacher(i),
                            ),
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

  void _addTeacherDialog(BuildContext context, SchoolDataProvider data) {
    final nameCtrl = TextEditingController();
    final subjCtrl = TextEditingController();
    String? photo;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          backgroundColor: AppColors.darkNavy,
          title: const Text("إضافة معلم",
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
                  decoration: const InputDecoration(hintText: "اسم المعلم"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: subjCtrl,
                  decoration: const InputDecoration(hintText: "المادة"),
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
                if (nameCtrl.text.isNotEmpty &&
                    subjCtrl.text.isNotEmpty) {
                  data.addTeacher(nameCtrl.text.trim(),
                      subjCtrl.text.trim(),
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
}

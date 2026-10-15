import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/school_data.dart';
import '../models/settings.dart';
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
    final settings = context.watch<SettingsProvider>();
    _cls ??= data.classes.first;
    final students = data.studentsOf(_cls!);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: settings.backgroundColor,
        title: Text("قائمة الطلاب",
            style: TextStyle(
                color: settings.primaryColor, fontFamily: 'Changa')),
        iconTheme: IconThemeData(color: settings.primaryColor),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: settings.primaryColor,
        onPressed: () => _addStudentDialog(context, data),
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
                          final guardian = data.guardianById(s.guardianId);
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
                                  context, data, s, i),
                              leading: _photoAvatar(s.photoPath, '${i + 1}'),
                              title: Text(s.name,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Changa',
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s.classRoom,
                                      style: const TextStyle(
                                          color: Colors.white54,
                                          fontFamily: 'Changa',
                                          fontSize: 12)),
                                  if (guardian != null)
                                    Text("👨‍👦 ${guardian.name}",
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
                                      data.updateStudent(
                                          i,
                                          Student(
                                            name: s.name,
                                            classRoom: s.classRoom,
                                            age: s.age,
                                            gender: s.gender,
                                            seatNumber: s.seatNumber,
                                            guardianId: s.guardianId,
                                            photoPath: img.path,
                                          ));
                                    }
                                  } else if (v == 'edit') {
                                    _addStudentDialog(context, data,
                                        editing: s, index: i);
                                  } else if (v == 'delete') {
                                    data.removeStudent(i);
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

  void _addStudentDialog(BuildContext context, SchoolDataProvider data,
      {Student? editing, int? index}) {
    final nameCtrl = TextEditingController(text: editing?.name ?? '');
    final ageCtrl = TextEditingController(text: editing?.age ?? '');
    final seatCtrl = TextEditingController(text: editing?.seatNumber ?? '');
    String gender = editing?.gender ?? 'ذكر';
    String? guardianId = editing?.guardianId;
    String? photo = editing?.photoPath;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          backgroundColor: AppColors.darkNavy,
          title: Text(editing == null ? "إضافة طالب" : "تعديل الطالب",
              style: const TextStyle(
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
                TextField(
                  controller: nameCtrl,
                  decoration:
                      const InputDecoration(hintText: "اسم الطالب"),
                ),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: ageCtrl,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(hintText: "العمر"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: seatCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          hintText: "رقم الجلوس"),
                    ),
                  ),
                ]),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: gender,
                  dropdownColor: AppColors.darkNavy,
                  items: const [
                    DropdownMenuItem(value: 'ذكر', child: Text("ذكر")),
                    DropdownMenuItem(value: 'أنثى', child: Text("أنثى")),
                  ],
                  onChanged: (v) => setD(() => gender = v!),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: guardianId,
                  isExpanded: true,
                  dropdownColor: AppColors.darkNavy,
                  hint: const Text("ولي الأمر (اختياري)"),
                  items: data.guardians
                      .map((g) => DropdownMenuItem(
                          value: g.id, child: Text(g.name)))
                      .toList(),
                  onChanged: (v) => setD(() => guardianId = v),
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
                if (nameCtrl.text.isEmpty) return;
                final student = Student(
                  name: nameCtrl.text.trim(),
                  classRoom: _cls!,
                  age: ageCtrl.text.trim(),
                  gender: gender,
                  seatNumber: seatCtrl.text.trim(),
                  guardianId: guardianId,
                  photoPath: photo,
                );
                if (editing == null) {
                  data.addStudent(student);
                } else {
                  data.updateStudent(index!, student);
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
    final guardian = data.guardianById(s.guardianId);

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
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (s.age.isNotEmpty)
                    _chip("العمر: ${s.age}", AppColors.blue),
                  const SizedBox(width: 6),
                  _chip(s.gender, AppColors.green),
                  const SizedBox(width: 6),
                  if (s.seatNumber.isNotEmpty)
                    _chip("#${s.seatNumber}", AppColors.orange),
                ],
              ),
              if (guardian != null) ...[
                const Divider(color: AppColors.gold),
                ListTile(
                  leading: const Icon(Icons.family_restroom,
                      color: AppColors.gold),
                  title: Text(guardian.name,
                      style: const TextStyle(
                          color: Colors.white, fontFamily: 'Changa')),
                  subtitle: Text(
                      "${guardian.relation} • ${guardian.phonePrimary}",
                      style: const TextStyle(
                          color: Colors.white54, fontFamily: 'Changa')),
                ),
              ],
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
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontFamily: 'Changa', fontSize: 12)),
    );
  }
}

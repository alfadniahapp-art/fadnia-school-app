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
  String _search = '';
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<SchoolDataProvider>();
    final settings = context.watch<SettingsProvider>();
    final primary = settings.primaryColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: settings.backgroundColor,
        title: Text("قائمة الطلاب",
            style: TextStyle(color: primary, fontFamily: 'Changa')),
        iconTheme: IconThemeData(color: primary),
        actions: [
          IconButton(
            icon: Icon(
              _showAll ? Icons.view_agenda : Icons.view_list,
              color: primary,
            ),
            tooltip: _showAll ? "عرض حسب الفصل" : "عرض الكل",
            onPressed: () => setState(() => _showAll = !_showAll),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        onPressed: () => _dialog(context, data),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              _statsBar(data, primary),
              const SizedBox(height: 10),
              TextField(
                onChanged: (v) => setState(() => _search = v),
                decoration: InputDecoration(
                  hintText: "🔍 ابحث عن طالب",
                  prefixIcon: Icon(Icons.search, color: primary),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _showAll
                    ? _buildFlatList(context, data, settings)
                    : _buildGroupedList(context, data, settings),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statsBar(SchoolDataProvider data, Color primary) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkNavy,
        border: Border.all(color: primary, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _statItem(
              icon: Icons.people,
              label: "إجمالي الطلاب",
              value: "${data.totalStudents}",
              color: primary,
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.border),
          Expanded(
            child: _statItem(
              icon: Icons.class_,
              label: "فصول فيها طلاب",
              value:
                  "${data.classesWithStudents.length}/${data.classes.length}",
              color: AppColors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: color,
                fontFamily: 'Changa',
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        Text(label,
            style: const TextStyle(
                color: Colors.white54,
                fontFamily: 'Changa',
                fontSize: 10),
            textAlign: TextAlign.center),
      ],
    );
  }

  // ============================================================
  //  📋 عرض مُجمَّع حسب الفصل
  // ============================================================
  Widget _buildGroupedList(
      BuildContext context, SchoolDataProvider data, SettingsProvider s) {
    final grouped = data.studentsPerClass;

    if (grouped.isEmpty) {
      return const Center(
        child: Text("لا يوجد طلاب مسجلون بعد",
            style: TextStyle(
                color: Colors.white54, fontFamily: 'Changa')),
      );
    }

    return ListView.builder(
      itemCount: grouped.length,
      itemBuilder: (_, i) {
        final cls = grouped.keys.elementAt(i);
        var list = grouped[cls]!;

        if (_search.isNotEmpty) {
          list = list
              .where((st) => st.name.contains(_search))
              .toList();
        }

        if (list.isEmpty && _search.isNotEmpty) {
          return const SizedBox.shrink();
        }

        return _classGroup(context, data, s, cls, list);
      },
    );
  }

  Widget _classGroup(BuildContext context, SchoolDataProvider data,
      SettingsProvider s, String cls, List<Student> students) {
    final primary = s.primaryColor;
    final allClassStudents = data.studentsOf(cls);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.darkNavy,
        border: Border.all(color: primary.withOpacity(0.5), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: EdgeInsets.zero,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.class_, color: primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cls,
                        style: TextStyle(
                            color: primary,
                            fontFamily: 'Changa',
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    Text("${allClassStudents.length} طالب",
                        style: const TextStyle(
                            color: Colors.white54,
                            fontFamily: 'Changa',
                            fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          iconColor: primary,
          collapsedIconColor: primary,
          children: students.isEmpty
              ? [
                  const Padding(
                    padding: EdgeInsets.all(15),
                    child: Text("لا يوجد طلاب في هذا الفصل",
                        style: TextStyle(
                            color: Colors.white38,
                            fontFamily: 'Changa',
                            fontSize: 12)),
                  )
                ]
              : students.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final st = entry.value;
                  final realIndex = data.students.indexOf(st);
                  return _studentCard(
                      context, data, s, st, realIndex, idx + 1);
                }).toList(),
        ),
      ),
    );
  }

  Widget _buildFlatList(
      BuildContext context, SchoolDataProvider data, SettingsProvider s) {
    var list = data.students;
    if (_search.isNotEmpty) {
      list = list.where((st) => st.name.contains(_search)).toList();
    }

    if (list.isEmpty) {
      return const Center(
        child: Text("لا يوجد طلاب",
            style: TextStyle(
                color: Colors.white54, fontFamily: 'Changa')),
      );
    }

    list = [...list]
      ..sort((a, b) {
        final cmp = a.classRoom.compareTo(b.classRoom);
        if (cmp != 0) return cmp;
        return a.name.compareTo(b.name);
      });

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (_, i) {
        final st = list[i];
        final realIndex = data.students.indexOf(st);
        return _studentCard(context, data, s, st, realIndex, i + 1);
      },
    );
  }

  Widget _studentCard(BuildContext context, SchoolDataProvider data,
      SettingsProvider s, Student st, int index, int displayNum) {
    final guardian = data.guardianById(st.guardianId);

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 6),
      decoration: BoxDecoration(
        color: AppColors.darkest.withOpacity(0.5),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        onTap: () => _details(context, data, st, index),
        leading: _photoAvatar(st.photoPath, '$displayNum'),
        title: Text(st.name,
            style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Changa',
                fontWeight: FontWeight.bold,
                fontSize: 14)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.school,
                    size: 11, color: s.primaryColor.withOpacity(0.7)),
                const SizedBox(width: 4),
                Text(st.classRoom,
                    style: TextStyle(
                        color: s.primaryColor.withOpacity(0.8),
                        fontFamily: 'Changa',
                        fontSize: 11)),
                if (st.age.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.cake,
                      size: 11, color: Colors.white54),
                  const SizedBox(width: 3),
                  Text("${st.age} سنة",
                      style: const TextStyle(
                          color: Colors.white54,
                          fontFamily: 'Changa',
                          fontSize: 11)),
                ],
              ],
            ),
            if (guardian != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.family_restroom,
                      size: 11, color: Colors.white38),
                  const SizedBox(width: 4),
                  Text(guardian.name,
                      style: const TextStyle(
                          color: Colors.white38,
                          fontFamily: 'Changa',
                          fontSize: 10)),
                ],
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert,
              color: s.primaryColor, size: 20),
          color: AppColors.darkNavy,
          onSelected: (v) async {
            if (v == 'photo') {
              final picker = ImagePicker();
              final img = await picker.pickImage(
                  source: ImageSource.gallery);
              if (img != null) {
                data.updateStudent(
                    index,
                    Student(
                      name: st.name,
                      classRoom: st.classRoom,
                      age: st.age,
                      guardianId: st.guardianId,
                      photoPath: img.path,
                    ));
              }
            } else if (v == 'edit') {
              _dialog(context, data, editing: st, index: index);
            } else if (v == 'delete') {
              _confirmDelete(context, data, st, index);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
                value: 'photo',
                child: Text("تغيير الصورة",
                    style: TextStyle(
                        color: Colors.white, fontFamily: 'Changa'))),
            PopupMenuItem(
                value: 'edit',
                child: Text("تعديل",
                    style: TextStyle(
                        color: Colors.white, fontFamily: 'Changa'))),
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
  }

  Widget _photoAvatar(String? path, String fallback) {
    if (path != null && File(path).existsSync()) {
      return CircleAvatar(
        radius: 22,
        backgroundImage: FileImage(File(path)),
      );
    }
    return CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.navy,
      child: Text(fallback,
          style: const TextStyle(
              color: AppColors.gold,
              fontFamily: 'Changa',
              fontWeight: FontWeight.bold,
              fontSize: 13)),
    );
  }

  // ============================================================
  //  ➕ إضافة / تعديل — مع حقل ولي الأمر المُحسّن
  // ============================================================
  void _dialog(BuildContext context, SchoolDataProvider data,
      {Student? editing, int? index}) {
    final nameCtrl = TextEditingController(text: editing?.name ?? '');
    final ageCtrl = TextEditingController(text: editing?.age ?? '');
    String cls = editing?.classRoom ?? data.classes.first;
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
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                      hintText: "اسم الطالب",
                      prefixIcon: Icon(Icons.person)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: ageCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      hintText: "العمر (اختياري)",
                      prefixIcon: Icon(Icons.cake)),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: cls,
                  isExpanded: true,
                  dropdownColor: AppColors.darkNavy,
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.class_)),
                  items: data.classes
                      .map((c) => DropdownMenuItem(
                          value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setD(() => cls = v!),
                ),

                const SizedBox(height: 12),
                const Divider(color: AppColors.border),
                const SizedBox(height: 6),

                // ============ ولي الأمر ============
                Row(
                  children: [
                    const Expanded(
                      child: Text("👨‍👦 ولي الأمر",
                          style: TextStyle(
                              color: AppColors.gold,
                              fontFamily: 'Changa',
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        // ➕ إضافة ولي أمر جديد ثم ربطه
                        await _quickAddGuardian(
                            context, data, (newId) {
                          setD(() => guardianId = newId);
                        });
                      },
                      icon: const Icon(Icons.add,
                          color: AppColors.green, size: 18),
                      label: const Text("جديد",
                          style: TextStyle(
                              color: AppColors.green,
                              fontFamily: 'Changa',
                              fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                if (data.guardians.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
                      border: Border.all(color: Colors.orange),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: Colors.orange, size: 18),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                              "لا يوجد أولياء أمور. اضغط «جديد» للإضافة.",
                              style: TextStyle(
                                  color: Colors.orange,
                                  fontFamily: 'Changa',
                                  fontSize: 11)),
                        ),
                      ],
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    value: guardianId,
                    isExpanded: true,
                    dropdownColor: AppColors.darkNavy,
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.family_restroom)),
                    hint: const Text("اختر ولي الأمر (اختياري)"),
                    items: [
                      // خيار "لا يوجد"
                      const DropdownMenuItem<String>(
                        value: '__none__',
                        child: Text("— لا يوجد —",
                            style: TextStyle(
                                color: Colors.white54,
                                fontFamily: 'Changa',
                                fontStyle: FontStyle.italic)),
                      ),
                      // قائمة أولياء الأمور
                      ...data.guardians.map((g) {
                        final phone = g.phonePrimary.isNotEmpty
                            ? ' • ${g.phonePrimary}'
                            : '';
                        return DropdownMenuItem(
                          value: g.id,
                          child: Text(
                            "${g.name} (${g.relation})$phone",
                            style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Changa',
                                fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }),
                    ],
                    onChanged: (v) {
                      setD(() {
                        guardianId = v == '__none__' ? null : v;
                      });
                    },
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
                if (nameCtrl.text.trim().isEmpty) return;
                final student = Student(
                  name: nameCtrl.text.trim(),
                  classRoom: cls,
                  age: ageCtrl.text.trim(),
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

  // ============================================================
  //  ➕ إضافة ولي أمر جديد (من نافذة الطالب)
  // ============================================================
  Future<void> _quickAddGuardian(BuildContext context,
      SchoolDataProvider data, Function(String) onCreated) async {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final phone2Ctrl = TextEditingController();
    String relation = 'أب';

    final created = await showDialog<String>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          backgroundColor: AppColors.darkNavy,
          title: const Text("إضافة ولي أمر جديد",
              style: TextStyle(
                  color: AppColors.gold, fontFamily: 'Changa')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  decoration: const InputDecoration(
                      hintText: "اسم ولي الأمر",
                      prefixIcon: Icon(Icons.person)),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: relation,
                  isExpanded: true,
                  dropdownColor: AppColors.darkNavy,
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.link)),
                  items: const [
                    DropdownMenuItem(value: 'أب', child: Text("أب")),
                    DropdownMenuItem(value: 'أم', child: Text("أم")),
                    DropdownMenuItem(value: 'أخ', child: Text("أخ")),
                    DropdownMenuItem(value: 'أخت', child: Text("أخت")),
                    DropdownMenuItem(value: 'جد', child: Text("جد")),
                    DropdownMenuItem(value: 'جدة', child: Text("جدة")),
                    DropdownMenuItem(value: 'عم', child: Text("عم")),
                    DropdownMenuItem(value: 'خال', child: Text("خال")),
                    DropdownMenuItem(value: 'وصي', child: Text("وصي")),
                  ],
                  onChanged: (v) => setD(() => relation = v!),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                      hintText: "📞 الرقم الأساسي",
                      prefixIcon: Icon(Icons.phone)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: phone2Ctrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                      hintText: "📞 الرقم الاحتياطي",
                      prefixIcon: Icon(Icons.phone)),
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
                if (nameCtrl.text.trim().isEmpty) return;
                final id = DateTime.now()
                    .millisecondsSinceEpoch
                    .toString();
                data.addGuardian(Guardian(
                  id: id,
                  name: nameCtrl.text.trim(),
                  relation: relation,
                  phonePrimary: phoneCtrl.text.trim(),
                  phoneSecondary: phone2Ctrl.text.trim(),
                ));
                Navigator.pop(ctx, id);
              },
              child: const Text("إضافة",
                  style: TextStyle(color: AppColors.gold)),
            ),
          ],
        ),
      ),
    );

    if (created != null) {
      onCreated(created);
    }
  }

  // ============================================================
  //  📋 التفاصيل
  // ============================================================
  void _details(BuildContext context, SchoolDataProvider data,
      Student st, int idx) {
    final grades = data.grades[st.classRoom]?[st.name] ?? {};
    final guardian = data.guardianById(st.guardianId);

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
              _photoAvatar(st.photoPath, st.name.substring(0, 1)),
              const SizedBox(height: 10),
              Text(st.name,
                  style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Changa')),
              Text(st.classRoom,
                  style: const TextStyle(
                      color: Colors.white70, fontFamily: 'Changa')),
              const SizedBox(height: 10),
              if (st.age.isNotEmpty)
                _chip("العمر: ${st.age} سنة", AppColors.blue),
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
                          color: Colors.white54,
                          fontFamily: 'Changa',
                          fontSize: 12)),
                ),
              ],
              const Divider(color: AppColors.gold),
              if (grades.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(15),
                  child: Text("لا توجد درجات مسجلة",
                      style: TextStyle(
                          color: Colors.white54,
                          fontFamily: 'Changa')),
                )
              else
                ...grades.entries.map((e) => ListTile(
                      dense: true,
                      title: Text(e.key,
                          style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Changa')),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontFamily: 'Changa', fontSize: 12)),
    );
  }

  void _confirmDelete(BuildContext context, SchoolDataProvider data,
      Student st, int idx) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkNavy,
        title: const Text("تأكيد الحذف",
            style: TextStyle(
                color: Colors.redAccent, fontFamily: 'Changa')),
        content: Text("حذف الطالب: ${st.name}؟",
            style: const TextStyle(
                color: Colors.white, fontFamily: 'Changa')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              data.removeStudent(idx);
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

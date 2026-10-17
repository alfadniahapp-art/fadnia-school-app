import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/school_data.dart';
import '../models/settings.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class GuardiansScreen extends StatefulWidget {
  const GuardiansScreen({super.key});
  @override
  State<GuardiansScreen> createState() => _GuardiansScreenState();
}

class _GuardiansScreenState extends State<GuardiansScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final data = context.watch<SchoolDataProvider>();
    final settings = context.watch<SettingsProvider>();
    final primary = settings.primaryColor;

    final filtered = data.guardians.where((g) {
      if (_search.isEmpty) return true;
      final q = _search.toLowerCase();
      return g.name.toLowerCase().contains(q) ||
          g.phonePrimary.contains(q) ||
          g.phoneSecondary.contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: settings.backgroundColor,
        title: Text("أولياء الأمور",
            style: TextStyle(color: primary, fontFamily: 'Changa')),
        iconTheme: IconThemeData(color: primary),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        onPressed: () => _guardianDialog(context, data),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              // 🔍 بحث
              TextField(
                onChanged: (v) => setState(() => _search = v),
                decoration: InputDecoration(
                  hintText: "🔍 ابحث بالاسم أو رقم الهاتف",
                  prefixIcon: Icon(Icons.search, color: primary),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          _search.isEmpty
                              ? "لا يوجد أولياء أمور. اضغط + للإضافة"
                              : "لا توجد نتائج",
                          style: const TextStyle(
                              color: Colors.white54,
                              fontFamily: 'Changa'),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final g = filtered[i];
                          final children = data.studentsOfGuardian(g.id);
                          return Card(
                            color: AppColors.darkNavy,
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                  color: AppColors.border),
                            ),
                            child: ListTile(
                              onTap: () => _details(
                                  context, data, g, children),
                              leading: CircleAvatar(
                                backgroundColor: AppColors.navy,
                                child: Text(
                                  g.name.isNotEmpty ? g.name[0] : '?',
                                  style: TextStyle(
                                      color: primary,
                                      fontFamily: 'Changa',
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(g.name,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Changa',
                                      fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text("🔗 ${g.relation}",
                                      style: const TextStyle(
                                          color: Colors.white70,
                                          fontFamily: 'Changa',
                                          fontSize: 12)),
                                  if (g.phonePrimary.isNotEmpty)
                                    Text("📞 ${g.phonePrimary}",
                                        style: const TextStyle(
                                            color: Colors.white54,
                                            fontFamily: 'Changa',
                                            fontSize: 11)),
                                  if (children.isNotEmpty)
                                    Text(
                                        "👥 ${children.length} أبناء مسجلون",
                                        style: TextStyle(
                                            color: primary,
                                            fontFamily: 'Changa',
                                            fontSize: 11)),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                icon: Icon(Icons.more_vert,
                                    color: primary),
                                color: AppColors.darkNavy,
                                onSelected: (v) {
                                  if (v == 'edit') {
                                    _guardianDialog(context, data,
                                        editing: g);
                                  } else if (v == 'delete') {
                                    _confirmDelete(context, data, g);
                                  }
                                },
                                itemBuilder: (_) => const [
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

  // ============ نافذة الإضافة/التعديل ============
  void _guardianDialog(BuildContext context, SchoolDataProvider data,
      {Guardian? editing}) {
    final nameCtrl = TextEditingController(text: editing?.name ?? '');
    final p1Ctrl = TextEditingController(text: editing?.phonePrimary ?? '');
    final p2Ctrl = TextEditingController(text: editing?.phoneSecondary ?? '');
    final addrCtrl = TextEditingController(text: editing?.address ?? '');
    final occCtrl = TextEditingController(text: editing?.occupation ?? '');
    final notesCtrl = TextEditingController(text: editing?.notes ?? '');
    String relation = editing?.relation ?? 'أب';

    // معرفة الطلاب المختارين حالياً لهذا الوالد
    final selectedStudents = editing == null
        ? <String>{}
        : data.studentsOfGuardian(editing.id).map((s) => s.name).toSet();

    // تجميع الطلاب حسب الفصل
    final studentsByClass = data.studentsPerClass;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          backgroundColor: AppColors.darkNavy,
          title: Text(editing == null ? "إضافة ولي أمر" : "تعديل ولي الأمر",
              style: const TextStyle(
                  color: AppColors.gold, fontFamily: 'Changa')),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(hintText: "اسم ولي الأمر"),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: relation,
                    isExpanded: true,
                    dropdownColor: AppColors.darkNavy,
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
                    controller: p1Ctrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(hintText: "📞 الرقم الأساسي"),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: p2Ctrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(hintText: "📞 الرقم الاحتياطي"),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: addrCtrl,
                    decoration: const InputDecoration(hintText: "🏠 العنوان (اختياري)"),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: occCtrl,
                    decoration: const InputDecoration(hintText: "💼 المهنة (اختياري)"),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notesCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(hintText: "📝 ملاحظات"),
                  ),

                  const Divider(color: AppColors.gold, height: 24),

                  // ============ قائمة الأبناء المجمّعة ============
                  const Text("👥 اختر الأبناء التابعين له:",
                      style: TextStyle(
                          color: AppColors.gold,
                          fontFamily: 'Changa',
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                  const SizedBox(height: 8),

                  if (studentsByClass.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                          "لا يوجد طلاب مسجلون بعد.\nأضف طلاباً أولاً من شاشة الطلاب.",
                          style: TextStyle(
                              color: Colors.white54,
                              fontFamily: 'Changa',
                              fontSize: 12),
                          textAlign: TextAlign.center),
                    )
                  else
                    ...studentsByClass.entries.map((entry) {
                      final cls = entry.key;
                      final studentsInClass = entry.value;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: AppColors.darkest,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Theme(
                          data: Theme.of(ctx).copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            title: Row(
                              children: [
                                const Icon(Icons.class_,
                                    color: AppColors.gold, size: 16),
                                const SizedBox(width: 6),
                                Text(cls,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Changa',
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold)),
                                const Spacer(),
                                Text("${studentsInClass.length} طالب",
                                    style: const TextStyle(
                                        color: Colors.white38,
                                        fontFamily: 'Changa',
                                        fontSize: 10)),
                              ],
                            ),
                            children: studentsInClass
                                .map((st) => CheckboxListTile(
                                      dense: true,
                                      contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      title: Text(st.name,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Changa',
                                              fontSize: 13)),
                                      activeColor: AppColors.gold,
                                      checkColor: AppColors.darkest,
                                      value: selectedStudents.contains(st.name),
                                      onChanged: (v) {
                                        setD(() {
                                          if (v == true) {
                                            selectedStudents.add(st.name);
                                          } else {
                                            selectedStudents.remove(st.name);
                                          }
                                        });
                                      },
                                    ))
                                .toList(),
                          ),
                        ),
                      );
                    }),
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

                final guardian = Guardian(
                  id: editing?.id ??
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameCtrl.text.trim(),
                  relation: relation,
                  phonePrimary: p1Ctrl.text.trim(),
                  phoneSecondary: p2Ctrl.text.trim(),
                  address: addrCtrl.text.trim(),
                  occupation: occCtrl.text.trim(),
                  notes: notesCtrl.text.trim(),
                );

                if (editing == null) {
                  data.addGuardian(guardian);
                } else {
                  final i = data.guardians
                      .indexWhere((x) => x.id == editing.id);
                  if (i != -1) data.updateGuardian(i, guardian);
                }

                // 🔗 ربط الطلاب المختارين بهذا الوالد
                for (final student in data.students) {
                  final shouldLink = selectedStudents.contains(student.name);
                  final currentlyLinked = student.guardianId == guardian.id;

                  if (shouldLink && !currentlyLinked) {
                    final idx = data.students.indexOf(student);
                    data.updateStudent(
                        idx,
                        Student(
                          name: student.name,
                          classRoom: student.classRoom,
                          age: student.age,
                          guardianId: guardian.id,
                          photoPath: student.photoPath,
                        ));
                  } else if (!shouldLink && currentlyLinked) {
                    // فصل الطالب من هذا الوالد
                    final idx = data.students.indexOf(student);
                    data.updateStudent(
                        idx,
                        Student(
                          name: student.name,
                          classRoom: student.classRoom,
                          age: student.age,
                          guardianId: null,
                          photoPath: student.photoPath,
                        ));
                  }
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

  // ============ تفاصيل ولي الأمر ============
  void _details(BuildContext context, SchoolDataProvider data,
      Guardian g, List<Student> children) {
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
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.navy,
                  child: Text(
                    g.name.isNotEmpty ? g.name[0] : '?',
                    style: const TextStyle(
                        color: AppColors.gold,
                        fontFamily: 'Changa',
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(g.name,
                    style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Changa')),
              ),
              Center(
                child: Text("🔗 ${g.relation}",
                    style: const TextStyle(
                        color: Colors.white70, fontFamily: 'Changa')),
              ),
              const Divider(color: AppColors.gold),

              if (g.phonePrimary.isNotEmpty)
                _contactRow(context, "📞 أساسي", g.phonePrimary),
              if (g.phoneSecondary.isNotEmpty)
                _contactRow(context, "📞 احتياطي", g.phoneSecondary),
              if (g.address.isNotEmpty)
                _infoRow(Icons.home, "🏠 العنوان", g.address),
              if (g.occupation.isNotEmpty)
                _infoRow(Icons.work, "💼 المهنة", g.occupation),
              if (g.notes.isNotEmpty)
                _infoRow(Icons.notes, "📝 ملاحظات", g.notes),

              const SizedBox(height: 10),
              const Divider(color: AppColors.gold),
              Text("👥 الأبناء المسجلون (${children.length})",
                  style: const TextStyle(
                      color: AppColors.gold,
                      fontFamily: 'Changa',
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (children.isEmpty)
                const Text("لا يوجد أبناء مسجلون",
                    style: TextStyle(
                        color: Colors.white54, fontFamily: 'Changa'))
              else
                ...children.map((s) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.school,
                          color: AppColors.gold),
                      title: Text(s.name,
                          style: const TextStyle(
                              color: Colors.white, fontFamily: 'Changa')),
                      subtitle: Text(s.classRoom,
                          style: const TextStyle(
                              color: Colors.white54,
                              fontFamily: 'Changa',
                              fontSize: 12)),
                    )),
              const SizedBox(height: 15),
              Row(children: [
                Expanded(
                  child: SuccessButton(
                    label: "✏️ تعديل",
                    icon: Icons.edit,
                    color: AppColors.blue,
                    onTap: () {
                      Navigator.pop(context);
                      _guardianDialog(context, data, editing: g);
                    },
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contactRow(BuildContext context, String label, String phone) {
    return ListTile(
      leading: const Icon(Icons.phone, color: AppColors.green),
      title: Text(label,
          style: const TextStyle(
              color: Colors.white70,
              fontFamily: 'Changa',
              fontSize: 12)),
      subtitle: Text(phone,
          style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Changa',
              fontWeight: FontWeight.bold)),
      trailing: IconButton(
        icon: const Icon(Icons.call, color: AppColors.green),
        onPressed: () async {
          final uri = Uri.parse("tel:$phone");
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
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
                    color: Colors.white, fontFamily: 'Changa')),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, SchoolDataProvider data, Guardian g) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkNavy,
        title: const Text("تأكيد الحذف",
            style: TextStyle(
                color: Colors.redAccent, fontFamily: 'Changa')),
        content: Text("حذف ولي الأمر: ${g.name}؟",
            style: const TextStyle(
                color: Colors.white, fontFamily: 'Changa')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              final i = data.guardians.indexWhere((x) => x.id == g.id);
              if (i != -1) data.removeGuardian(i);
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

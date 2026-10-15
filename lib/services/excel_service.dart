import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/school_data.dart';

class ExcelService {
  // ============================================================
  //  📅 جدول الحصص
  // ============================================================
  static Future<void> exportSchedule(
      SchoolDataProvider data, String cls) async {
    final excel = Excel.createExcel();
    final sheet = excel['جدول_$cls'];
    excel.setDefaultSheet('جدول_$cls');

    final headers = ['اليوم', ...data.lessons];
    sheet.appendRow(headers.map((e) => TextCellValue(e)).toList());

    for (final day in data.days) {
      final row = [day];
      for (final lesson in data.lessons) {
        row.add(data.getLesson(cls, day, lesson));
      }
      sheet.appendRow(row.map((e) => TextCellValue(e)).toList());
    }

    await _saveAndShare(excel, 'جدول_$cls.xlsx');
  }

  // ============================================================
  //  👤 قائمة الطلاب (بدون جنس/رقم جلوس)
  // ============================================================
  static Future<void> exportStudents(
      SchoolDataProvider data, String cls) async {
    final excel = Excel.createExcel();
    final sheet = excel['طلاب_$cls'];
    excel.setDefaultSheet('طلاب_$cls');

    sheet.appendRow([
      TextCellValue('م'),
      TextCellValue('الاسم'),
      TextCellValue('العمر'),
      TextCellValue('ولي الأمر'),
      TextCellValue('هاتف ولي الأمر'),
      TextCellValue('الفصل'),
    ]);

    final students = data.studentsOf(cls);
    for (int i = 0; i < students.length; i++) {
      final s = students[i];
      final guardian = data.guardianById(s.guardianId);
      sheet.appendRow([
        IntCellValue(i + 1),
        TextCellValue(s.name),
        TextCellValue(s.age),
        TextCellValue(guardian?.name ?? '-'),
        TextCellValue(guardian?.phonePrimary ?? '-'),
        TextCellValue(s.classRoom),
      ]);
    }

    await _saveAndShare(excel, 'طلاب_$cls.xlsx');
  }

  // ============================================================
  //  📊 الدرجات
  // ============================================================
  static Future<void> exportGrades(
      SchoolDataProvider data, String cls) async {
    final excel = Excel.createExcel();
    final sheet = excel['درجات_$cls'];
    excel.setDefaultSheet('درجات_$cls');

    final subjects = data.subjectsOf(cls);
    final students = data.studentsOf(cls);

    sheet.appendRow([
      TextCellValue('الطالب'),
      ...subjects.map((s) => TextCellValue(s)),
      TextCellValue('المعدل'),
    ]);

    for (final s in students) {
      double sum = 0;
      int count = 0;
      final row = <CellValue>[TextCellValue(s.name)];
      for (final subj in subjects) {
        final g = data.getGrade(cls, s.name, subj);
        row.add(g != null ? DoubleCellValue(g) : TextCellValue('-'));
        if (g != null) {
          sum += g;
          count++;
        }
      }
      row.add(DoubleCellValue(count == 0 ? 0 : sum / count));
      sheet.appendRow(row);
    }

    await _saveAndShare(excel, 'درجات_$cls.xlsx');
  }

  // ============================================================
  //  👨‍🏫 المعلمون
  // ============================================================
  static Future<void> exportTeachers(SchoolDataProvider data) async {
    final excel = Excel.createExcel();
    final sheet = excel['المعلمون'];
    excel.setDefaultSheet('المعلمون');

    sheet.appendRow([
      TextCellValue('م'),
      TextCellValue('الاسم'),
      TextCellValue('الدرجة'),
      TextCellValue('الشهادة'),
      TextCellValue('الهاتف'),
      TextCellValue('المواد'),
    ]);

    for (int i = 0; i < data.teachers.length; i++) {
      final t = data.teachers[i];
      sheet.appendRow([
        IntCellValue(i + 1),
        TextCellValue(t.name),
        TextCellValue(t.degree),
        TextCellValue(t.certificate),
        TextCellValue(t.phone),
        TextCellValue(t.subjects.join('، ')),
      ]);
    }

    await _saveAndShare(excel, 'المعلمون.xlsx');
  }

  // ============================================================
  //  👨‍👦 أولياء الأمور
  // ============================================================
  static Future<void> exportGuardians(SchoolDataProvider data) async {
    final excel = Excel.createExcel();
    final sheet = excel['أولياء الأمور'];
    excel.setDefaultSheet('أولياء الأمور');

    sheet.appendRow([
      TextCellValue('م'),
      TextCellValue('الاسم'),
      TextCellValue('الصلة'),
      TextCellValue('الهاتف الأساسي'),
      TextCellValue('الهاتف الاحتياطي'),
      TextCellValue('العنوان'),
      TextCellValue('المهنة'),
      TextCellValue('عدد الأبناء'),
    ]);

    for (int i = 0; i < data.guardians.length; i++) {
      final g = data.guardians[i];
      final children = data.studentsOfGuardian(g.id).length;
      sheet.appendRow([
        IntCellValue(i + 1),
        TextCellValue(g.name),
        TextCellValue(g.relation),
        TextCellValue(g.phonePrimary),
        TextCellValue(g.phoneSecondary),
        TextCellValue(g.address),
        TextCellValue(g.occupation),
        IntCellValue(children),
      ]);
    }

    await _saveAndShare(excel, 'أولياء_الأمور.xlsx');
  }

  // ============================================================
  //  📤 الحفظ والمشاركة
  // ============================================================
  static Future<void> _saveAndShare(Excel excel, String filename) async {
    final bytes = excel.save();
    if (bytes == null) return;
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)],
        text: 'تصدير من نظام Mulla');
  }
}

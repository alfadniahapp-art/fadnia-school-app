import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/school_data.dart';
import '../models/payroll.dart';

class PdfService {
  /// تحميل خط عربي
  static Future<pw.Font> _loadRegular() async {
    return await PdfGoogleFonts.cairoRegular();
  }

  static Future<pw.Font> _loadBold() async {
    return await PdfGoogleFonts.cairoBold();
  }

  // ============================================================
  //  📅 جدول الحصص
  // ============================================================
  static Future<void> printSchedule(
    SchoolDataProvider data,
    String cls, {
    bool isLandscape = false,
  }) async {
    final doc = pw.Document();
    final font = await _loadRegular();
    final fontBold = await _loadBold();

    doc.addPage(pw.MultiPage(
      pageFormat: isLandscape
          ? PdfPageFormat.a4.landscape
          : PdfPageFormat.a4.portrait,
      textDirection: pw.TextDirection.rtl,
      theme: pw.ThemeData.withFont(base: font, bold: fontBold),
      build: (ctx) => [
        pw.Header(
          level: 0,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(data.name,
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.Text('المرحلة ${data.stage} - ${data.type}',
                  style: const pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 6),
              pw.Text('جدول حصص: $cls',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table.fromTextArray(
          headers: ['اليوم', ...data.lessons],
          data: data.days
              .map((d) => [
                    d,
                    ...data.lessons.map((l) => data.getLesson(cls, d, l)),
                  ])
              .toList(),
          headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold, fontSize: 11),
          cellStyle: const pw.TextStyle(fontSize: 9),
          headerDecoration:
              const pw.BoxDecoration(color: PdfColors.grey300),
          cellAlignment: pw.Alignment.center,
          headerAlignment: pw.Alignment.center,
          border:
              pw.TableBorder.all(color: PdfColors.grey700, width: 0.5),
        ),
      ],
    ));

    await Printing.layoutPdf(onLayout: (f) => doc.save());
  }

  // ============================================================
  //  📊 كشف الدرجات
  // ============================================================
  static Future<void> printGrades(
      SchoolDataProvider data, String cls) async {
    final doc = pw.Document();
    final font = await _loadRegular();
    final fontBold = await _loadBold();
    final subjects = data.subjectsOf(cls);
    final students = data.studentsOf(cls);

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      textDirection: pw.TextDirection.rtl,
      theme: pw.ThemeData.withFont(base: font, bold: fontBold),
      build: (ctx) => [
        pw.Header(
          level: 0,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(data.name,
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.Text('كشف درجات: $cls',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table.fromTextArray(
          headers: ['م', 'الطالب', ...subjects, 'المعدل'],
          data: List.generate(students.length, (i) {
            final s = students[i];
            double sum = 0;
            int count = 0;
            final row = <String>['${i + 1}', s.name];
            for (final subj in subjects) {
              final g = data.getGrade(cls, s.name, subj);
              row.add(g?.toStringAsFixed(0) ?? '-');
              if (g != null) {
                sum += g;
                count++;
              }
            }
            row.add(count == 0 ? '-' : (sum / count).toStringAsFixed(1));
            return row;
          }),
          headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold, fontSize: 11),
          cellStyle: const pw.TextStyle(fontSize: 10),
          headerDecoration:
              const pw.BoxDecoration(color: PdfColors.grey300),
          cellAlignment: pw.Alignment.center,
          border:
              pw.TableBorder.all(color: PdfColors.grey700, width: 0.5),
        ),
      ],
    ));
    await Printing.layoutPdf(onLayout: (f) => doc.save());
  }

  // ============================================================
  //  🏆 شهادة تقدير
  // ============================================================
  static Future<void> printCertificate(
    SchoolDataProvider data,
    String cls,
    String studentName,
  ) async {
    final doc = pw.Document();
    final font = await _loadRegular();
    final fontBold = await _loadBold();
    final subjects = data.subjectsOf(cls);

    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4.landscape,
      textDirection: pw.TextDirection.rtl,
      theme: pw.ThemeData.withFont(base: font, bold: fontBold),
      build: (ctx) => pw.Container(
        padding: const pw.EdgeInsets.all(30),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.amber, width: 4),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.SizedBox(height: 20),
            pw.Text(data.name,
                style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.amber800)),
            pw.SizedBox(height: 6),
            pw.Text('المرحلة ${data.stage} - ${data.type}',
                style: const pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 30),
            pw.Text('شهادة تقدير',
                style: pw.TextStyle(
                    fontSize: 32,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.amber900)),
            pw.SizedBox(height: 30),
            pw.Text('تشهد إدارة المدرسة بأن الطالب/الطالبة',
                style: const pw.TextStyle(fontSize: 16)),
            pw.SizedBox(height: 12),
            pw.Text(studentName,
                style: pw.TextStyle(
                    fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 12),
            pw.Text('قد أتم بنجاح متطلبات الفصل $cls',
                style: const pw.TextStyle(fontSize: 16)),
            pw.SizedBox(height: 30),
            pw.Table.fromTextArray(
              headers: ['المادة', 'الدرجة'],
              data: subjects.map((s) {
                final g = data.getGrade(cls, studentName, s);
                return [s, g?.toStringAsFixed(0) ?? '-'];
              }).toList(),
              headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.amber700),
              cellAlignment: pw.Alignment.center,
              border: pw.TableBorder.all(color: PdfColors.grey400),
            ),
            pw.Spacer(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                pw.Column(children: [
                  pw.Text('مدير المدرسة'),
                  pw.SizedBox(height: 30),
                  pw.Text('................'),
                ]),
                pw.Column(children: [
                  pw.Text('التاريخ'),
                  pw.SizedBox(height: 30),
                  pw.Text(DateTime.now().toString().substring(0, 10)),
                ]),
              ],
            ),
          ],
        ),
      ),
    ));
    await Printing.layoutPdf(onLayout: (f) => doc.save());
  }

  // ============================================================
  //  📋 تقرير الغياب
  // ============================================================
  static Future<void> printAttendanceReport(
    SchoolDataProvider data,
    Map<String, Map<String, Map<String, String>>> attendance,
    String cls,
  ) async {
    final doc = pw.Document();
    final font = await _loadRegular();
    final fontBold = await _loadBold();
    final students = data.studentsOf(cls);

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      textDirection: pw.TextDirection.rtl,
      theme: pw.ThemeData.withFont(base: font, bold: fontBold),
      build: (ctx) => [
        pw.Header(
          level: 0,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(data.name,
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.Text('تقرير الغياب - $cls',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table.fromTextArray(
          headers: ['م', 'الطالب', 'عدد الغياب'],
          data: List.generate(students.length, (i) {
            int abs = 0;
            for (final date in attendance.keys) {
              if (attendance[date]?[cls]?[students[i].name] == 'absent') {
                abs++;
              }
            }
            return ['${i + 1}', students[i].name, '$abs'];
          }),
          headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold, fontSize: 11),
          cellStyle: const pw.TextStyle(fontSize: 10),
          headerDecoration:
              const pw.BoxDecoration(color: PdfColors.grey300),
          cellAlignment: pw.Alignment.center,
          border:
              pw.TableBorder.all(color: PdfColors.grey700, width: 0.5),
        ),
      ],
    ));
    await Printing.layoutPdf(onLayout: (f) => doc.save());
  }

  // ============================================================
  //  🏫 تقرير عام
  // ============================================================
  static Future<void> printSchoolReport(SchoolDataProvider data) async {
    final doc = pw.Document();
    final font = await _loadRegular();
    final fontBold = await _loadBold();

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      textDirection: pw.TextDirection.rtl,
      theme: pw.ThemeData.withFont(base: font, bold: fontBold),
      build: (ctx) => [
        pw.Header(
          level: 0,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('تقرير عام',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Text(data.name,
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text('المرحلة ${data.stage} - ${data.type}',
                  style: const pw.TextStyle(fontSize: 14)),
            ],
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Header(level: 1, text: 'الإحصائيات العامة'),
        pw.Bullet(text: 'عدد الفصول: ${data.classes.length}'),
        pw.Bullet(text: 'عدد المعلمين: ${data.teachers.length}'),
        pw.Bullet(text: 'عدد الطلاب: ${data.students.length}'),
        pw.Bullet(text: 'عدد أولياء الأمور: ${data.guardians.length}'),
        pw.Bullet(text: 'عدد الموظفين: ${data.employees.length}'),
        pw.SizedBox(height: 20),
        pw.Header(level: 1, text: 'قائمة المعلمين'),
        pw.Table.fromTextArray(
          headers: ['م', 'الاسم', 'الدرجة', 'الشهادة', 'الهاتف'],
          data: List.generate(data.teachers.length, (i) {
            final t = data.teachers[i];
            return [
              '${i + 1}',
              t.name,
              t.degree.isEmpty ? '-' : t.degree,
              t.certificate.isEmpty ? '-' : t.certificate,
              t.phone.isEmpty ? '-' : t.phone,
            ];
          }),
          headerDecoration:
              const pw.BoxDecoration(color: PdfColors.grey300),
          cellAlignment: pw.Alignment.center,
        ),
      ],
    ));
    await Printing.layoutPdf(onLayout: (f) => doc.save());
  }

  // ============================================================
  //  💰 كشف الرواتب الشهري
  // ============================================================
  static Future<void> printPayroll(
    SchoolDataProvider data,
    int month,
    int year,
    List<String> monthNames,
  ) async {
    final doc = pw.Document();
    final font = await _loadRegular();
    final fontBold = await _loadBold();

    final records = data.payrollForMonth(month, year);
    final summary = data.payrollSummary(month, year);
    final monthName = monthNames[month - 1];

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      textDirection: pw.TextDirection.rtl,
      theme: pw.ThemeData.withFont(base: font, bold: fontBold),
      build: (ctx) => [
        pw.Header(
          level: 0,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(data.name,
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text('كشف الرواتب - $monthName $year هـ',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ),
        pw.SizedBox(height: 10),

        // جدول الموظفين
        pw.Table.fromTextArray(
          headers: [
            'م',
            'الاسم',
            'النوع',
            'الأساسي',
            'الحوافز',
            'الخصومات',
            'الصافي',
            'الحالة',
          ],
          data: List.generate(records.length, (i) {
            final r = records[i];
            return [
              '${i + 1}',
              r.employeeName,
              r.employeeType.label,
              r.baseSalary.toStringAsFixed(0),
              r.totalIncomes > 0
                  ? '+${r.totalIncomes.toStringAsFixed(0)}'
                  : '-',
              r.totalDeductions > 0
                  ? '-${r.totalDeductions.toStringAsFixed(0)}'
                  : '-',
              r.netSalary.toStringAsFixed(0),
              r.status.label,
            ];
          }),
          headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
              color: PdfColors.white),
          cellStyle: const pw.TextStyle(fontSize: 9),
          headerDecoration:
              const pw.BoxDecoration(color: PdfColors.grey800),
          cellAlignment: pw.Alignment.center,
          border:
              pw.TableBorder.all(color: PdfColors.grey700, width: 0.5),
        ),

        pw.SizedBox(height: 20),

        // ملخص الشهر
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey200,
            border: pw.Border.all(color: PdfColors.grey700),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('ملخص الشهر',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                      'عدد الموظفين: ${summary.totalEmployees}'),
                  pw.Text(
                      'المرتبات المدفوعة: ${summary.paidCount}'),
                  pw.Text(
                      'المرتبات المعلقة: ${summary.pendingCount}'),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                      'إجمالي الرواتب: ${summary.totalBaseSalary.toStringAsFixed(0)}'),
                  pw.Text(
                      'إجمالي الحوافز: ${summary.totalIncomes.toStringAsFixed(0)}'),
                  pw.Text(
                      'إجمالي الخصومات: ${summary.totalDeductions.toStringAsFixed(0)}'),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                      'صافي المستحق: ${summary.totalNetSalary.toStringAsFixed(0)}',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                      'المدفوع: ${summary.totalPaid.toStringAsFixed(0)}',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.green800)),
                  pw.Text(
                      'المتبقي: ${summary.totalRemaining.toStringAsFixed(0)}',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.red800)),
                ],
              ),
            ],
          ),
        ),

        pw.SizedBox(height: 20),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
          children: [
            pw.Column(children: [
              pw.Text('المحاسب'),
              pw.SizedBox(height: 30),
              pw.Text('...............'),
            ]),
            pw.Column(children: [
              pw.Text('مدير المدرسة'),
              pw.SizedBox(height: 30),
              pw.Text('...............'),
            ]),
            pw.Column(children: [
              pw.Text('التاريخ'),
              pw.SizedBox(height: 30),
              pw.Text(DateTime.now().toString().substring(0, 10)),
            ]),
          ],
        ),
      ],
    ));

    await Printing.layoutPdf(onLayout: (f) => doc.save());
  }
}

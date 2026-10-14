import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/school_data.dart';
import '../models/attendance.dart';
import '../services/pdf_service.dart';
import '../services/excel_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String? _cls;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<SchoolDataProvider>();
    final att = context.watch<AttendanceProvider>();
    _cls ??= data.classes.first;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkNavy,
        title: const Text("التقارير",
            style: TextStyle(color: AppColors.gold, fontFamily: 'Changa')),
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: SingleChildScrollView(
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
              const SizedBox(height: 20),
              _section('التقارير المطبوعة (PDF)'),
              SuccessButton(
                label: "🖨️ جدول الحصص",
                color: AppColors.blue,
                onTap: () => PdfService.printSchedule(data, _cls!),
              ),
              const SizedBox(height: 8),
              SuccessButton(
                label: "🖨️ كشف الدرجات",
                color: AppColors.blue,
                onTap: () => PdfService.printGrades(data, _cls!),
              ),
              const SizedBox(height: 8),
              SuccessButton(
                label: "🖨️ تقرير الغياب",
                color: AppColors.blue,
                onTap: () => PdfService.printAttendanceReport(
                    data, att.attendance, _cls!),
              ),
              const SizedBox(height: 8),
              SuccessButton(
                label: "🖨️ تقرير عام عن المدرسة",
                color: AppColors.blue,
                onTap: () => PdfService.printSchoolReport(data),
              ),
              const SizedBox(height: 20),
              _section('التصدير إلى Excel'),
              SuccessButton(
                label: "📊 جدول الحصص",
                color: AppColors.green,
                onTap: () => ExcelService.exportSchedule(data, _cls!),
              ),
              const SizedBox(height: 8),
              SuccessButton(
                label: "📊 قائمة الطلاب",
                color: AppColors.green,
                onTap: () => ExcelService.exportStudents(data, _cls!),
              ),
              const SizedBox(height: 8),
              SuccessButton(
                label: "📊 الدرجات",
                color: AppColors.green,
                onTap: () => ExcelService.exportGrades(data, _cls!),
              ),
              const SizedBox(height: 8),
              SuccessButton(
                label: "📊 قائمة المعلمين",
                color: AppColors.green,
                onTap: () => ExcelService.exportTeachers(data),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(title,
            style: const TextStyle(
                color: AppColors.gold,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Changa')),
      ),
    );
  }
}

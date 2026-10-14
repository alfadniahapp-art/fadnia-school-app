import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/school_data.dart';
import '../services/pdf_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});
  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  String? _cls;
  String? _student;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<SchoolDataProvider>();
    _cls ??= data.classes.first;
    final students = data.studentsOf(_cls!);
    if (_student == null || !students.any((s) => s.name == _student)) {
      _student = students.isEmpty ? null : students.first.name;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkNavy,
        title: const Text("شهادات الطلاب",
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
              const CustomLabel("الطالب:"),
              DropdownButtonFormField<String>(
                value: _student,
                isExpanded: true,
                dropdownColor: AppColors.darkNavy,
                items: students
                    .map((s) =>
                        DropdownMenuItem(value: s.name, child: Text(s.name)))
                    .toList(),
                onChanged: (v) => setState(() => _student = v),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.gold, width: 3),
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.darkNavy,
                ),
                child: Column(
                  children: [
                    const Icon(Icons.card_membership,
                        color: AppColors.gold, size: 50),
                    const SizedBox(height: 10),
                    Text(_student ?? '—',
                        style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 20,
                            fontFamily: 'Changa',
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(_cls ?? '—',
                        style: const TextStyle(
                            color: Colors.white70,
                            fontFamily: 'Changa')),
                  ],
                ),
              ),
              const Spacer(),
              SuccessButton(
                label: "🖨️ طباعة الشهادة",
                icon: Icons.print,
                color: AppColors.blue,
                onTap: () {
                  if (_student == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("اختر طالباً أولاً")),
                    );
                    return;
                  }
                  PdfService.printCertificate(data, _cls!, _student!);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

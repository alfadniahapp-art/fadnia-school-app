import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/school_data.dart';
import '../models/attendance.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});
  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String? _cls;
  DateTime _date = DateTime.now();

  String get _dateKey => DateFormat('yyyy-MM-dd').format(_date);

  @override
  Widget build(BuildContext context) {
    final data = context.watch<SchoolDataProvider>();
    final att = context.watch<AttendanceProvider>();
    _cls ??= data.classes.first;
    final students = data.studentsOf(_cls!);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkNavy,
        title: const Text("سجل الغياب",
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
              const SizedBox(height: 10),
              Row(children: [
                const Icon(Icons.calendar_today,
                    color: AppColors.gold, size: 18),
                const SizedBox(width: 8),
                Text(_dateKey,
                    style: const TextStyle(
                        color: AppColors.gold, fontFamily: 'Changa')),
                const Spacer(),
                TextButton.icon(
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (d != null) setState(() => _date = d);
                  },
                  icon: const Icon(Icons.edit, color: AppColors.gold),
                  label: const Text("تغيير التاريخ",
                      style: TextStyle(
                          color: AppColors.gold, fontFamily: 'Changa')),
                ),
              ]),
              const SizedBox(height: 10),
              Expanded(
                child: students.isEmpty
                    ? const Center(
                        child: Text("لا يوجد طلاب",
                            style: TextStyle(
                                color: Colors.white54,
                                fontFamily: 'Changa')),
                      )
                    : ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (_, i) {
                          final s = students[i];
                          final status =
                              att.getStatus(_dateKey, _cls!, s.name);
                          return Card(
                            color: AppColors.darkNavy,
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                  color: AppColors.border),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.navy,
                                  child: Text('${i + 1}',
                                      style: const TextStyle(
                                          color: AppColors.gold,
                                          fontFamily: 'Changa')),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(s.name,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Changa',
                                          fontSize: 15)),
                                ),
                                _statusBtn(att, s.name, 'present',
                                    Icons.check, Colors.green, status),
                                _statusBtn(att, s.name, 'absent',
                                    Icons.close, Colors.red, status),
                                _statusBtn(att, s.name, 'late',
                                    Icons.access_time, Colors.orange, status),
                                _statusBtn(att, s.name, 'excused',
                                    Icons.note, Colors.blue, status),
                              ]),
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

  Widget _statusBtn(AttendanceProvider att, String student, String value,
      IconData icon, Color color, String current) {
    final active = current == value;
    return IconButton(
      onPressed: () =>
          att.setStatus(_dateKey, _cls!, student, value),
      icon: Icon(icon,
          color: active ? color : Colors.white24, size: 22),
      tooltip: value,
    );
  }
}

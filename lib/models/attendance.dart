import 'package:flutter/material.dart';
import '../services/storage_service.dart';

enum AttendanceStatus { present, absent, late, excused }

class AttendanceProvider extends ChangeNotifier {
  Map<String, Map<String, Map<String, String>>> attendance = {};

  Future<void> load() async {
    final data = await StorageService.loadAttendance();
    if (data != null) {
      attendance = data.map(
        (date, classes) => MapEntry(
          date,
          classes.map(
            (cls, students) => MapEntry(
              cls,
              students.map((s, v) => MapEntry(s, v.toString())),
            ),
          ),
        ),
      );
    }
    notifyListeners();
  }

  Future<void> save() async {
    await StorageService.saveAttendance(attendance);
  }

  String getStatus(String date, String cls, String student) {
    return attendance[date]?[cls]?[student] ?? 'present';
  }

  void setStatus(String date, String cls, String student, String status) {
    attendance.putIfAbsent(date, () => {});
    attendance[date]!.putIfAbsent(cls, () => {});
    attendance[date]![cls]![student] = status;
    save();
    notifyListeners();
  }

  int countAbsent(String cls, String student) {
    int count = 0;
    for (final date in attendance.keys) {
      if (attendance[date]?[cls]?[student] == 'absent') count++;
    }
    return count;
  }
}

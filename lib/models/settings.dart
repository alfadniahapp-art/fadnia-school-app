import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  String password = "1234";
  bool notificationsEnabled = true;
  bool autoBackup = false;
  String academicYear = "1446 هـ";
  String semester = "الفصل الأول";

  Future<void> load() async {
    final data = await StorageService.loadSettings();
    if (data != null) {
      password = data['password'] ?? password;
      notificationsEnabled = data['notificationsEnabled'] ?? true;
      autoBackup = data['autoBackup'] ?? false;
      academicYear = data['academicYear'] ?? academicYear;
      semester = data['semester'] ?? semester;
    }
    notifyListeners();
  }

  Future<void> save() async {
    await StorageService.saveSettings({
      'password': password,
      'notificationsEnabled': notificationsEnabled,
      'autoBackup': autoBackup,
      'academicYear': academicYear,
      'semester': semester,
    });
    notifyListeners();
  }

  void setPassword(String p) {
    password = p;
    save();
  }

  void toggleNotifications(bool v) {
    notificationsEnabled = v;
    save();
  }

  void toggleAutoBackup(bool v) {
    autoBackup = v;
    save();
  }

  void setYear(String y) {
    academicYear = y;
    save();
  }

  void setSemester(String s) {
    semester = s;
    save();
  }
}

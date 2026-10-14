import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  String password = "1234";
  bool notificationsEnabled = true;
  bool autoBackup = false;
  String academicYear = "1446 هـ";
  String semester = "الفصل الأول";

  // 💰 العملة
  String currencySymbol = "ج.س";

  // 🎨 الألوان
  int primaryColorValue = 0xFFF1C40F;   // ذهبي
  int backgroundColorValue = 0xFF0B132B; // كحلي

  // 🏫 القالب
  String schoolTemplate = "كبيرة"; // صغيرة / متوسطة / كبيرة

  // 📦 الوحدات المفعّلة
  Map<String, bool> enabledModules = {
    'schedule': true,      // جدول الحصص
    'teachers': true,      // المعلمون
    'subjects': true,      // المواد
    'students': true,      // الطلاب
    'guardians': true,     // أولياء الأمور
    'grades': true,        // الدرجات
    'attendance': true,    // الغياب
    'calendar': false,     // التقويم
    'fees': true,          // الرسوم
    'certificates': true,  // الشهادات
    'reports': true,       // التقارير
    'stats': true,         // الإحصائيات
    'teacherDaily': true,  // جدول المعلم
    'finance': false,      // المالية
    'payroll': false,      // الرواتب
  };

  Color get primaryColor => Color(primaryColorValue);
  Color get backgroundColor => Color(backgroundColorValue);

  // ============ التحميل ============
  Future<void> load() async {
    final data = await StorageService.loadSettings();
    if (data != null) {
      password = data['password'] ?? password;
      notificationsEnabled = data['notificationsEnabled'] ?? true;
      autoBackup = data['autoBackup'] ?? false;
      academicYear = data['academicYear'] ?? academicYear;
      semester = data['semester'] ?? semester;
      currencySymbol = data['currencySymbol'] ?? currencySymbol;
      primaryColorValue = data['primaryColorValue'] ?? primaryColorValue;
      backgroundColorValue =
          data['backgroundColorValue'] ?? backgroundColorValue;
      schoolTemplate = data['schoolTemplate'] ?? schoolTemplate;
      final mods = data['enabledModules'];
      if (mods != null) {
        enabledModules = Map<String, bool>.from(mods);
      }
    }
    notifyListeners();
  }

  // ============ الحفظ ============
  Future<void> save() async {
    await StorageService.saveSettings({
      'password': password,
      'notificationsEnabled': notificationsEnabled,
      'autoBackup': autoBackup,
      'academicYear': academicYear,
      'semester': semester,
      'currencySymbol': currencySymbol,
      'primaryColorValue': primaryColorValue,
      'backgroundColorValue': backgroundColorValue,
      'schoolTemplate': schoolTemplate,
      'enabledModules': enabledModules,
    });
    notifyListeners();
  }

  // ============ المُعدِّلات ============
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

  void setCurrency(String c) {
    currencySymbol = c;
    save();
  }

  void setPrimaryColor(int v) {
    primaryColorValue = v;
    save();
  }

  void setBackgroundColor(int v) {
    backgroundColorValue = v;
    save();
  }

  void setTemplate(String t) {
    schoolTemplate = t;
    applyTemplate(t);
    save();
  }

  void applyTemplate(String t) {
    schoolTemplate = t;
    if (t == 'صغيرة') {
      enabledModules = {
        'schedule': true,
        'teachers': true,
        'subjects': true,
        'students': true,
        'guardians': false,
        'grades': true,
        'attendance': false,
        'calendar': false,
        'fees': false,
        'certificates': false,
        'reports': false,
        'stats': false,
        'teacherDaily': false,
        'finance': false,
        'payroll': false,
      };
    } else if (t == 'متوسطة') {
      enabledModules = {
        'schedule': true,
        'teachers': true,
        'subjects': true,
        'students': true,
        'guardians': true,
        'grades': true,
        'attendance': true,
        'calendar': true,
        'fees': true,
        'certificates': true,
        'reports': true,
        'stats': true,
        'teacherDaily': true,
        'finance': false,
        'payroll': false,
      };
    } else {
      // كبيرة
      enabledModules = {
        'schedule': true,
        'teachers': true,
        'subjects': true,
        'students': true,
        'guardians': true,
        'grades': true,
        'attendance': true,
        'calendar': true,
        'fees': true,
        'certificates': true,
        'reports': true,
        'stats': true,
        'teacherDaily': true,
        'finance': true,
        'payroll': true,
      };
    }
    save();
  }

  void toggleModule(String key, bool value) {
    enabledModules[key] = value;
    save();
  }

  bool isEnabled(String key) => enabledModules[key] ?? false;
}

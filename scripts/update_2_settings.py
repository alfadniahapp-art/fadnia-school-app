import os

CONTENT = r'''import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../utils/date_formatter.dart';
import 'defaults.dart';

class SettingsProvider extends ChangeNotifier {
  String password = "1234";
  bool notificationsEnabled = true;
  bool autoBackup = false;
  String academicYear = "1446 هـ";
  String semester = "الفصل الأول";

  // 💰 العملة
  String currencySymbol = "ج.س";

  // 🎨 الألوان
  int primaryColorValue = 0xFFF1C40F;
  int backgroundColorValue = 0xFF0B132B;

  // 🏫 القالب
  String schoolTemplate = "كبيرة";

  // 📅 أيام العمل
  int workDaysPerMonth = 22;

  // 🗓️ نوع التقويم
  String calendarTypeKey = 'both';

  CalendarType get calendarType =>
      CalendarTypeExt.fromKey(calendarTypeKey);

  // 📦 الوحدات المفعّلة
  Map<String, bool> enabledModules = {
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
    'employees': true,
    'payroll': true,
    'finance': true,
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
      workDaysPerMonth = data['workDaysPerMonth'] ?? workDaysPerMonth;
      calendarTypeKey = data['calendarTypeKey'] ?? calendarTypeKey;
      final mods = data['enabledModules'];
      if (mods != null) {
        final loaded = Map<String, bool>.from(mods);
        for (final key in enabledModules.keys) {
          if (!loaded.containsKey(key)) {
            loaded[key] = enabledModules[key]!;
          }
        }
        enabledModules = loaded;
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
      'workDaysPerMonth': workDaysPerMonth,
      'calendarTypeKey': calendarTypeKey,
      'enabledModules': enabledModules,
    });
    notifyListeners();
  }

  // ============ المُعدِّلات ============
  void setPassword(String p) { password = p; save(); }
  void toggleNotifications(bool v) { notificationsEnabled = v; save(); }
  void toggleAutoBackup(bool v) { autoBackup = v; save(); }
  void setYear(String y) { academicYear = y; save(); }
  void setSemester(String s) { semester = s; save(); }
  void setCurrency(String c) { currencySymbol = c; save(); }
  void setPrimaryColor(int v) { primaryColorValue = v; save(); }
  void setBackgroundColor(int v) { backgroundColorValue = v; save(); }
  void setWorkDays(int days) { workDaysPerMonth = days; save(); }
  void setCalendarType(CalendarType type) {
    calendarTypeKey = type.key;
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
        'schedule': true, 'teachers': true, 'subjects': true,
        'students': true, 'guardians': false, 'grades': true,
        'attendance': false, 'calendar': false, 'fees': false,
        'certificates': false, 'reports': false, 'stats': false,
        'teacherDaily': false, 'employees': false, 'payroll': false,
        'finance': false,
      };
    } else if (t == 'متوسطة') {
      enabledModules = {
        'schedule': true, 'teachers': true, 'subjects': true,
        'students': true, 'guardians': true, 'grades': true,
        'attendance': true, 'calendar': true, 'fees': true,
        'certificates': true, 'reports': true, 'stats': true,
        'teacherDaily': true, 'employees': true, 'payroll': true,
        'finance': false,
      };
    } else {
      enabledModules = {
        'schedule': true, 'teachers': true, 'subjects': true,
        'students': true, 'guardians': true, 'grades': true,
        'attendance': true, 'calendar': true, 'fees': true,
        'certificates': true, 'reports': true, 'stats': true,
        'teacherDaily': true, 'employees': true, 'payroll': true,
        'finance': true,
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
'''

path = 'lib/models/settings.dart'
with open(path, 'w', encoding='utf-8') as f:
    f.write(CONTENT)
print(f'✅ تم: {path} ({len(CONTENT)} حرف)')

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _keyData = 'mulla_school_data_v3';
  static const _keySettings = 'mulla_settings_v2';
  static const _keyAttendance = 'mulla_attendance_v2';
  static const _keyCalendar = 'mulla_calendar_v1';
  static const _keyFees = 'mulla_fees_v1';

  static Future<void> save(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyData, jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyData);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveSettings(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySettings, jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keySettings);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveAttendance(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAttendance, jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> loadAttendance() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyAttendance);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveCalendar(List<Map<String, dynamic>> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCalendar, jsonEncode(data));
  }

  static Future<List<Map<String, dynamic>>?> loadCalendar() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyCalendar);
    if (raw == null) return null;
    try {
      return (jsonDecode(raw) as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveFees(List<Map<String, dynamic>> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFees, jsonEncode(data));
  }

  static Future<List<Map<String, dynamic>>?> loadFees() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyFees);
    if (raw == null) return null;
    try {
      return (jsonDecode(raw) as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    } catch (_) {
      return null;
    }
  }

  static Future<String> exportAll() async {
    final prefs = await SharedPreferences.getInstance();
    return jsonEncode({
      'data': prefs.getString(_keyData),
      'settings': prefs.getString(_keySettings),
      'attendance': prefs.getString(_keyAttendance),
      'calendar': prefs.getString(_keyCalendar),
      'fees': prefs.getString(_keyFees),
      'exportedAt': DateTime.now().toIso8601String(),
    });
  }

  static Future<bool> importAll(String json) async {
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      final prefs = await SharedPreferences.getInstance();
      if (map['data'] != null) await prefs.setString(_keyData, map['data']);
      if (map['settings'] != null)
        await prefs.setString(_keySettings, map['settings']);
      if (map['attendance'] != null)
        await prefs.setString(_keyAttendance, map['attendance']);
      if (map['calendar'] != null)
        await prefs.setString(_keyCalendar, map['calendar']);
      if (map['fees'] != null) await prefs.setString(_keyFees, map['fees']);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

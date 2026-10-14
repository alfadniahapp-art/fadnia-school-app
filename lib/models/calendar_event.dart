import 'package:flutter/material.dart';
import '../services/storage_service.dart';

enum EventType { exam, holiday, meeting, activity, other }

class CalendarEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final EventType type;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'date': date.toIso8601String(),
        'type': type.index,
      };

  factory CalendarEvent.fromJson(Map<String, dynamic> j) => CalendarEvent(
        id: j['id'],
        title: j['title'],
        description: j['description'] ?? '',
        date: DateTime.parse(j['date']),
        type: EventType.values[j['type'] ?? 0],
      );

  Color get color {
    switch (type) {
      case EventType.exam:
        return const Color(0xFFE74C3C);
      case EventType.holiday:
        return const Color(0xFF27AE60);
      case EventType.meeting:
        return const Color(0xFF3498DB);
      case EventType.activity:
        return const Color(0xFFF39C12);
      case EventType.other:
        return const Color(0xFF9B59B6);
    }
  }

  String get typeName {
    switch (type) {
      case EventType.exam:
        return 'اختبار';
      case EventType.holiday:
        return 'إجازة';
      case EventType.meeting:
        return 'اجتماع';
      case EventType.activity:
        return 'نشاط';
      case EventType.other:
        return 'أخرى';
    }
  }

  IconData get icon {
    switch (type) {
      case EventType.exam:
        return Icons.quiz;
      case EventType.holiday:
        return Icons.beach_access;
      case EventType.meeting:
        return Icons.groups;
      case EventType.activity:
        return Icons.sports_soccer;
      case EventType.other:
        return Icons.event;
    }
  }
}

class CalendarProvider extends ChangeNotifier {
  List<CalendarEvent> events = [];

  Future<void> load() async {
    final data = await StorageService.loadCalendar();
    if (data != null) {
      events = data.map((e) => CalendarEvent.fromJson(e)).toList();
    }
    notifyListeners();
  }

  Future<void> save() async {
    await StorageService.saveCalendar(events.map((e) => e.toJson()).toList());
  }

  void add(CalendarEvent e) {
    events.add(e);
    save();
    notifyListeners();
  }

  void update(CalendarEvent e) {
    final i = events.indexWhere((x) => x.id == e.id);
    if (i != -1) {
      events[i] = e;
      save();
      notifyListeners();
    }
  }

  void remove(String id) {
    events.removeWhere((e) => e.id == id);
    save();
    notifyListeners();
  }

  List<CalendarEvent> eventsOn(DateTime date) {
    return events
        .where((e) =>
            e.date.year == date.year &&
            e.date.month == date.month &&
            e.date.day == date.day)
        .toList();
  }
}

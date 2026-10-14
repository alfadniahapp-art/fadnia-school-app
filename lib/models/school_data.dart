import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class Teacher {
  final String name;
  final String subject;
  final String? photoPath;
  Teacher({required this.name, required this.subject, this.photoPath});

  String get display => '$subject - $name';

  Map<String, dynamic> toJson() => {
        'name': name,
        'subject': subject,
        'photoPath': photoPath,
      };
  factory Teacher.fromJson(Map<String, dynamic> j) => Teacher(
        name: j['name'],
        subject: j['subject'],
        photoPath: j['photoPath'],
      );
}

class Student {
  final String name;
  final String classRoom;
  final String? photoPath;
  Student({required this.name, required this.classRoom, this.photoPath});

  Map<String, dynamic> toJson() => {
        'name': name,
        'classRoom': classRoom,
        'photoPath': photoPath,
      };
  factory Student.fromJson(Map<String, dynamic> j) => Student(
        name: j['name'],
        classRoom: j['classRoom'],
        photoPath: j['photoPath'],
      );
}

class SchoolDataProvider extends ChangeNotifier {
  String name = "مدارس الفادنية شرق";
  String stage = "المتوسطة";
  String type = "بنين";

  List<String> classes = [
    "الأول المتوسط",
    "الثاني المتوسط",
    "الثالث المتوسط",
  ];

  List<Teacher> teachers = [];
  List<Student> students = [];

  Map<String, Map<String, Map<String, String>>> schedule = {};
  Map<String, List<String>> subjectsByClass = {};
  Map<String, Map<String, Map<String, double>>> grades = {};

  final List<String> days = [
    "الأحد", "الإثنين", "الثلاثاء", "الأربعاء", "الخميس",
  ];

  final List<String> lessons = [
    "الأولى", "الثانية", "الثالثة", "الرابعة",
    "الخامسة", "السادسة", "السابعة", "الثامنة",
  ];

  Future<void> loadData() async {
    final data = await StorageService.load();
    if (data != null) {
      name = data['name'] ?? name;
      stage = data['stage'] ?? stage;
      type = data['type'] ?? type;
      classes = List<String>.from(data['classes'] ?? classes);
      teachers = (data['teachers'] as List? ?? [])
          .map((e) => Teacher.fromJson(e))
          .toList();
      students = (data['students'] as List? ?? [])
          .map((e) => Student.fromJson(e))
          .toList();
      subjectsByClass = (data['subjectsByClass'] as Map?)?.map(
            (k, v) => MapEntry(k.toString(), List<String>.from(v)),
          ) ??
          {};
      schedule = (data['schedule'] as Map?)?.map(
            (cls, daysMap) => MapEntry(
              cls.toString(),
              (daysMap as Map).map(
                (day, lessonsMap) => MapEntry(
                  day.toString(),
                  (lessonsMap as Map).map(
                    (l, v) => MapEntry(l.toString(), v.toString()),
                  ),
                ),
              ),
            ),
          ) ??
          {};
      grades = (data['grades'] as Map?)?.map(
            (cls, stMap) => MapEntry(
              cls.toString(),
              (stMap as Map).map(
                (st, subjMap) => MapEntry(
                  st.toString(),
                  (subjMap as Map).map(
                    (s, v) => MapEntry(s.toString(), (v as num).toDouble()),
                  ),
                ),
              ),
            ),
          ) ??
          {};
    }
    if (teachers.isEmpty) {
      teachers = [
        Teacher(name: "أ. محمد", subject: "رياضيات"),
        Teacher(name: "أ. أحمد", subject: "لغة عربية"),
      ];
    }
    notifyListeners();
  }

  Future<void> saveData() async {
    await StorageService.save({
      'name': name,
      'stage': stage,
      'type': type,
      'classes': classes,
      'teachers': teachers.map((t) => t.toJson()).toList(),
      'students': students.map((s) => s.toJson()).toList(),
      'subjectsByClass': subjectsByClass,
      'schedule': schedule,
      'grades': grades,
    });
  }

  void updateStage(String newStage) {
    stage = newStage;
    if (newStage == "الابتدائية") {
      classes = [
        "الاول الابتدائي", "الثاني الابتدائي", "الثالث الابتدائي",
        "الرابع الابتدائي", "الخامس الابتدائي", "السادس الابتدائي",
      ];
    } else if (newStage == "المتوسطة") {
      classes = ["الأول المتوسط", "الثاني المتوسط", "الثالث المتوسط"];
    } else {
      classes = ["الاول الثانوي", "الثاني الثانوي", "الثالث الثانوي"];
    }
    saveData();
    notifyListeners();
  }

  void setSchoolInfo({required String n, required String s, required String t}) {
    name = n;
    stage = s;
    type = t;
    updateStage(s);
    notifyListeners();
  }

  void assignLesson({
    required String cls,
    required String day,
    required String lesson,
    required String value,
  }) {
    schedule.putIfAbsent(cls, () => {});
    schedule[cls]!.putIfAbsent(day, () => {});
    schedule[cls]![day]![lesson] = value;
    saveData();
    notifyListeners();
  }

  void removeLesson(String cls, String day, String lesson) {
    schedule[cls]?[day]?.remove(lesson);
    saveData();
    notifyListeners();
  }

  String getLesson(String cls, String day, String lesson) {
    return schedule[cls]?[day]?[lesson] ?? '-';
  }

  Map<String, String> getTeacherDaySchedule(String teacherDisplay, String day) {
    final result = <String, String>{};
    for (final cls in classes) {
      final lessonsMap = schedule[cls]?[day];
      if (lessonsMap == null) continue;
      lessonsMap.forEach((lesson, value) {
        if (value == teacherDisplay) {
          result[lesson] = cls;
        }
      });
    }
    return result;
  }

  void addTeacher(String name, String subject, {String? photoPath}) {
    teachers.add(Teacher(name: name, subject: subject, photoPath: photoPath));
    saveData();
    notifyListeners();
  }

  void updateTeacherPhoto(int index, String? path) {
    final t = teachers[index];
    teachers[index] = Teacher(name: t.name, subject: t.subject, photoPath: path);
    saveData();
    notifyListeners();
  }

  void removeTeacher(int i) {
    teachers.removeAt(i);
    saveData();
    notifyListeners();
  }

  void addStudent(String name, String cls, {String? photoPath}) {
    students.add(Student(name: name, classRoom: cls, photoPath: photoPath));
    saveData();
    notifyListeners();
  }

  void updateStudentPhoto(int index, String? path) {
    final s = students[index];
    students[index] =
        Student(name: s.name, classRoom: s.classRoom, photoPath: path);
    saveData();
    notifyListeners();
  }

  void removeStudent(int i) {
    students.removeAt(i);
    saveData();
    notifyListeners();
  }

  List<Student> studentsOf(String cls) =>
      students.where((s) => s.classRoom == cls).toList();

  List<String> subjectsOf(String cls) => subjectsByClass[cls] ?? [];

  void addSubject(String cls, String subj) {
    subjectsByClass.putIfAbsent(cls, () => []);
    if (!subjectsByClass[cls]!.contains(subj)) {
      subjectsByClass[cls]!.add(subj);
      saveData();
      notifyListeners();
    }
  }

  void removeSubject(String cls, String subj) {
    subjectsByClass[cls]?.remove(subj);
    saveData();
    notifyListeners();
  }

  double? getGrade(String cls, String student, String subj) =>
      grades[cls]?[student]?[subj];

  void setGrade(String cls, String student, String subj, double value) {
    grades.putIfAbsent(cls, () => {});
    grades[cls]!.putIfAbsent(student, () => {});
    grades[cls]![student]![subj] = value;
    saveData();
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class Guardian {
  final String id;
  final String name;
  final String relation;
  final String phonePrimary;
  final String phoneSecondary;
  final String address;
  final String occupation;
  final String notes;

  Guardian({
    required this.id,
    required this.name,
    this.relation = 'أب',
    this.phonePrimary = '',
    this.phoneSecondary = '',
    this.address = '',
    this.occupation = '',
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'relation': relation,
        'phonePrimary': phonePrimary,
        'phoneSecondary': phoneSecondary,
        'address': address,
        'occupation': occupation,
        'notes': notes,
      };

  factory Guardian.fromJson(Map<String, dynamic> j) => Guardian(
        id: j['id'] ?? '',
        name: j['name'] ?? '',
        relation: j['relation'] ?? 'أب',
        phonePrimary: j['phonePrimary'] ?? '',
        phoneSecondary: j['phoneSecondary'] ?? '',
        address: j['address'] ?? '',
        occupation: j['occupation'] ?? '',
        notes: j['notes'] ?? '',
      );
}

class Teacher {
  final String name;
  final String degree;
  final String certificate;
  final String phone;
  final List<String> subjects;
  final String? photoPath;

  Teacher({
    required this.name,
    this.degree = '',
    this.certificate = '',
    this.phone = '',
    this.subjects = const [],
    this.photoPath,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'degree': degree,
        'certificate': certificate,
        'phone': phone,
        'subjects': subjects,
        'photoPath': photoPath,
      };

  factory Teacher.fromJson(Map<String, dynamic> j) => Teacher(
        name: j['name'] ?? '',
        degree: j['degree'] ?? '',
        certificate: j['certificate'] ?? '',
        phone: j['phone'] ?? '',
        subjects: List<String>.from(j['subjects'] ?? []),
        photoPath: j['photoPath'],
      );
}

class Student {
  final String name;
  final String classRoom;
  final String age;
  final String gender;
  final String seatNumber;
  final String? guardianId;
  final String? photoPath;

  Student({
    required this.name,
    required this.classRoom,
    this.age = '',
    this.gender = 'ذكر',
    this.seatNumber = '',
    this.guardianId,
    this.photoPath,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'classRoom': classRoom,
        'age': age,
        'gender': gender,
        'seatNumber': seatNumber,
        'guardianId': guardianId,
        'photoPath': photoPath,
      };

  factory Student.fromJson(Map<String, dynamic> j) => Student(
        name: j['name'] ?? '',
        classRoom: j['classRoom'] ?? '',
        age: j['age'] ?? '',
        gender: j['gender'] ?? 'ذكر',
        seatNumber: j['seatNumber'] ?? '',
        guardianId: j['guardianId'],
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
  List<Guardian> guardians = [];

  /// رسوم افتراضية لكل فصل
  Map<String, double> feesByClass = {};

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

  // ============ التحميل والحفظ ============
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
      guardians = (data['guardians'] as List? ?? [])
          .map((e) => Guardian.fromJson(e))
          .toList();
      feesByClass = (data['feesByClass'] as Map?)?.map(
            (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
          ) ??
          {};
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
        Teacher(name: "أ. محمد", subjects: ["رياضيات"]),
        Teacher(name: "أ. أحمد", subjects: ["لغة عربية"]),
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
      'guardians': guardians.map((g) => g.toJson()).toList(),
      'feesByClass': feesByClass,
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

  // ============ الجدول ============
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

  Map<String, String> getTeacherDaySchedule(String teacherName, String day) {
    final result = <String, String>{};
    for (final cls in classes) {
      final lessonsMap = schedule[cls]?[day];
      if (lessonsMap == null) continue;
      lessonsMap.forEach((lesson, value) {
        if (value.contains(teacherName)) {
          result[lesson] = cls;
        }
      });
    }
    return result;
  }

  // ============ المعلمون ============
  void addTeacher(Teacher t) {
    teachers.add(t);
    saveData();
    notifyListeners();
  }

  void updateTeacher(int index, Teacher t) {
    teachers[index] = t;
    saveData();
    notifyListeners();
  }

  void removeTeacher(int i) {
    teachers.removeAt(i);
    saveData();
    notifyListeners();
  }

  List<Teacher> teachersForSubject(String subject) {
    return teachers.where((t) => t.subjects.contains(subject)).toList();
  }

  // ============ الطلاب ============
  void addStudent(Student s) {
    students.add(s);
    saveData();
    notifyListeners();
  }

  void updateStudent(int index, Student s) {
    students[index] = s;
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

  // ============ أولياء الأمور ============
  void addGuardian(Guardian g) {
    guardians.add(g);
    saveData();
    notifyListeners();
  }

  void updateGuardian(int index, Guardian g) {
    guardians[index] = g;
    saveData();
    notifyListeners();
  }

  void removeGuardian(int i) {
    guardians.removeAt(i);
    saveData();
    notifyListeners();
  }

  Guardian? guardianById(String? id) {
    if (id == null) return null;
    try {
      return guardians.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Student> studentsOfGuardian(String guardianId) {
    return students.where((s) => s.guardianId == guardianId).toList();
  }

  // ============ المواد ============
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

  // ============ الدرجات ============
  double? getGrade(String cls, String student, String subj) =>
      grades[cls]?[student]?[subj];

  void setGrade(String cls, String student, String subj, double value) {
    grades.putIfAbsent(cls, () => {});
    grades[cls]!.putIfAbsent(student, () => {});
    grades[cls]![student]![subj] = value;
    saveData();
    notifyListeners();
  }

  // ============ رسوم الفصول ============
  double feeOfClass(String cls) => feesByClass[cls] ?? 0;

  void setClassFee(String cls, double amount) {
    feesByClass[cls] = amount;
    saveData();
    notifyListeners();
  }
}

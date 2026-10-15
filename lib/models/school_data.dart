import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'employee.dart';
import 'payroll.dart';
import 'finance.dart';

// ============================================================
//  👨‍👦 ولي الأمر
// ============================================================
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

// ============================================================
//  👨‍🏫 المعلم
// ============================================================
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

// ============================================================
//  👤 الطالب
// ============================================================
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

// ============================================================
//  🏫 مزوّد البيانات الرئيسي
// ============================================================
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
  List<Employee> employees = [];
  List<PayrollRecord> payrollRecords = [];

  // 💰 المالية
  List<FinanceAccount> financeAccounts = [];
  List<FinanceTransaction> financeTransactions = [];

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

  // ============================================================
  //  📥 التحميل والحفظ
  // ============================================================
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
      employees = (data['employees'] as List? ?? [])
          .map((e) => Employee.fromJson(e))
          .toList();
      payrollRecords = (data['payrollRecords'] as List? ?? [])
          .map((e) => PayrollRecord.fromJson(e))
          .toList();
      financeAccounts = (data['financeAccounts'] as List? ?? [])
          .map((e) => FinanceAccount.fromJson(e))
          .toList();
      financeTransactions = (data['financeTransactions'] as List? ?? [])
          .map((e) => FinanceTransaction.fromJson(e))
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

    // 🏦 إنشاء صندوق افتراضي إن لم يوجد
    if (financeAccounts.isEmpty) {
      financeAccounts = [
        FinanceAccount(
          id: 'default_cash',
          name: 'الصندوق النقدي',
          type: AccountType.cash,
          openingBalance: 0,
          isDefault: true,
        ),
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
      'employees': employees.map((e) => e.toJson()).toList(),
      'payrollRecords': payrollRecords.map((p) => p.toJson()).toList(),
      'financeAccounts': financeAccounts.map((f) => f.toJson()).toList(),
      'financeTransactions':
          financeTransactions.map((f) => f.toJson()).toList(),
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

  // ============================================================
  //  📅 الجدول
  // ============================================================
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

  // ============================================================
  //  👨‍🏫 المعلمون
  // ============================================================
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

  // ============================================================
  //  👤 الطلاب
  // ============================================================
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

  // ============================================================
  //  👨‍👦 أولياء الأمور
  // ============================================================
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

  // ============================================================
  //  📚 المواد
  // ============================================================
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

  // ============================================================
  //  📊 الدرجات
  // ============================================================
  double? getGrade(String cls, String student, String subj) =>
      grades[cls]?[student]?[subj];

  void setGrade(String cls, String student, String subj, double value) {
    grades.putIfAbsent(cls, () => {});
    grades[cls]!.putIfAbsent(student, () => {});
    grades[cls]![student]![subj] = value;
    saveData();
    notifyListeners();
  }

  // ============================================================
  //  💰 رسوم الفصول
  // ============================================================
  double feeOfClass(String cls) => feesByClass[cls] ?? 0;

  void setClassFee(String cls, double amount) {
    feesByClass[cls] = amount;
    saveData();
    notifyListeners();
  }

  // ============================================================
  //  👥 الموظفون
  // ============================================================
  void addEmployee(Employee e) {
    employees.add(e);
    saveData();
    notifyListeners();
  }

  void updateEmployee(int index, Employee e) {
    employees[index] = e;
    saveData();
    notifyListeners();
  }

  void removeEmployee(int i) {
    employees.removeAt(i);
    saveData();
    notifyListeners();
  }

  Employee? employeeById(String id) {
    try {
      return employees.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Employee> employeesOfType(EmployeeType type) {
    return employees.where((e) => e.type == type).toList();
  }

  double get totalMonthlySalaries =>
      employees.fold(0.0, (sum, e) => sum + e.baseSalary);

  // ============================================================
  //  📋 الرواتب
  // ============================================================
  void addPayroll(PayrollRecord p) {
    payrollRecords.add(p);
    saveData();
    notifyListeners();
  }

  void updatePayroll(PayrollRecord p) {
    final i = payrollRecords.indexWhere((r) => r.id == p.id);
    if (i != -1) {
      final old = payrollRecords[i];
      // 🔗 ربط تلقائي بالخزينة عند تحوّل الحالة إلى مدفوع
      if (old.status != PaymentStatus.paid &&
          p.status == PaymentStatus.paid) {
        _recordPayrollPayment(p);
      }
      payrollRecords[i] = p;
      saveData();
      notifyListeners();
    }
  }

  void removePayroll(String id) {
    payrollRecords.removeWhere((r) => r.id == id);
    saveData();
    notifyListeners();
  }

  List<PayrollRecord> payrollForMonth(int month, int year) {
    return payrollRecords
        .where((r) => r.month == month && r.year == year)
        .toList();
  }

  PayrollSummary payrollSummary(int month, int year) {
    return PayrollSummary(
      month: month,
      year: year,
      records: payrollForMonth(month, year),
    );
  }

  PayrollRecord? payrollForEmployee(String employeeId, int month, int year) {
    try {
      return payrollRecords.firstWhere(
        (r) =>
            r.employeeId == employeeId &&
            r.month == month &&
            r.year == year,
      );
    } catch (_) {
      return null;
    }
  }

  List<PayrollRecord> payrollHistoryFor(String employeeId) {
    return payrollRecords
        .where((r) => r.employeeId == employeeId)
        .toList()
      ..sort((a, b) {
        if (a.year != b.year) return b.year.compareTo(a.year);
        return b.month.compareTo(a.month);
      });
  }

  List<String> get payrollMonths {
    final set = <String>{};
    for (final r in payrollRecords) {
      set.add('${r.year}-${r.month.toString().padLeft(2, '0')}');
    }
    final list = set.toList()..sort();
    return list.reversed.toList();
  }

  double totalPayrollFor(int month, int year) {
    return payrollForMonth(month, year)
        .fold(0.0, (sum, r) => sum + r.netSalary);
  }

  double totalPaidFor(int month, int year) {
    return payrollForMonth(month, year)
        .fold(0.0, (sum, r) => sum + r.paidAmount);
  }

  double get totalMonthlyExpenses => totalMonthlySalaries;

  // ============================================================
  //  💰 المالية — الحسابات
  // ============================================================
  void addAccount(FinanceAccount a) {
    financeAccounts.add(a);
    saveData();
    notifyListeners();
  }

  void updateAccount(FinanceAccount a) {
    final i = financeAccounts.indexWhere((x) => x.id == a.id);
    if (i != -1) {
      financeAccounts[i] = a;
      saveData();
      notifyListeners();
    }
  }

  void removeAccount(String id) {
    financeAccounts.removeWhere((a) => a.id == id);
    // حذف الحركات المرتبطة
    financeTransactions.removeWhere((t) => t.accountId == id);
    saveData();
    notifyListeners();
  }

  FinanceAccount? accountById(String id) {
    try {
      return financeAccounts.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// الصندوق الافتراضي
  FinanceAccount get defaultAccount {
    try {
      return financeAccounts.firstWhere((a) => a.isDefault);
    } catch (_) {
      if (financeAccounts.isNotEmpty) return financeAccounts.first;
      final acc = FinanceAccount(
        id: 'default_cash',
        name: 'الصندوق النقدي',
        type: AccountType.cash,
        isDefault: true,
      );
      financeAccounts.add(acc);
      return acc;
    }
  }

  // ============================================================
  //  💰 المالية — الحركات
  // ============================================================
  void addTransaction(FinanceTransaction t) {
    financeTransactions.add(t);
    saveData();
    notifyListeners();
  }

  void updateTransaction(FinanceTransaction t) {
    final i = financeTransactions.indexWhere((x) => x.id == t.id);
    if (i != -1) {
      financeTransactions[i] = t;
      saveData();
      notifyListeners();
    }
  }

  void removeTransaction(String id) {
    financeTransactions.removeWhere((t) => t.id == id);
    saveData();
    notifyListeners();
  }

  /// حركات حساب معين
  List<FinanceTransaction> transactionsOf(String accountId) {
    return financeTransactions
        .where((t) => t.accountId == accountId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// كل الحركات مرتبة
  List<FinanceTransaction> get allTransactions {
    return [...financeTransactions]
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// رصيد حساب معين
  double balanceOf(String accountId) {
    final acc = accountById(accountId);
    if (acc == null) return 0;
    double balance = acc.openingBalance;
    for (final t in financeTransactions) {
      if (t.accountId == accountId) {
        balance += t.signedAmount;
      }
    }
    return balance;
  }

  /// إجمالي الرصيد
  double get totalBalance {
    double total = 0;
    for (final a in financeAccounts) {
      total += balanceOf(a.id);
    }
    return total;
  }

  /// الملخص المالي
  FinanceSummary get financeSummary => FinanceSummary(
        accounts: financeAccounts,
        transactions: financeTransactions,
      );

  /// توليد رقم سند تسلسلي
  String nextReference(TransactionType type) {
    final prefix = type == TransactionType.receipt ? 'RC' : 'PV';
    final year = DateTime.now().year;
    final count = financeTransactions
            .where((t) => t.type == type)
            .length +
        1;
    return '$prefix-$year-${count.toString().padLeft(4, '0')}';
  }

  // ============================================================
  //  🔗 الربط التلقائي
  // ============================================================

  /// عند دفع راتب موظف → خصم من الخزينة
  void _recordPayrollPayment(PayrollRecord p) {
    final account = defaultAccount;
    final t = FinanceTransaction(
      id: 'payroll_${p.id}_${DateTime.now().millisecondsSinceEpoch}',
      accountId: account.id,
      type: TransactionType.payment,
      amount: p.netSalary,
      categoryName: 'رواتب',
      date: p.paymentDate ?? DateTime.now(),
      description: 'راتب ${p.employeeName} - ${p.periodLabel}',
      reference: nextReference(TransactionType.payment),
      party: p.employeeName,
      source: TransactionSource.payroll,
      linkedId: p.id,
    );
    financeTransactions.add(t);
  }

  /// عند استلام رسوم طالب → إضافة للخزينة
  void recordStudentFeePayment({
    required String studentName,
    required String classRoom,
    required double amount,
    required String category,
    String? linkedId,
  }) {
    final account = defaultAccount;
    final t = FinanceTransaction(
      id: 'fee_${DateTime.now().millisecondsSinceEpoch}',
      accountId: account.id,
      type: TransactionType.receipt,
      amount: amount,
      categoryName: category,
      date: DateTime.now(),
      description: '$category - $studentName',
      reference: nextReference(TransactionType.receipt),
      party: studentName,
      source: TransactionSource.studentFee,
      linkedId: linkedId,
    );
    financeTransactions.add(t);
    saveData();
    notifyListeners();
  }

  // ============================================================
  //  📊 إحصائيات
  // ============================================================
  double get totalIncome => financeSummary.totalReceipts;
  double get totalExpense => financeSummary.totalPayments;
  double get netProfit => totalIncome - totalExpense;
}

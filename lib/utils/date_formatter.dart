import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

/// نوع التقويم
enum CalendarType {
  hijri,      // هجري فقط
  gregorian,  // ميلادي فقط
  both,       // الاثنان معاً
}

extension CalendarTypeExt on CalendarType {
  String get label {
    switch (this) {
      case CalendarType.hijri:
        return 'هجري';
      case CalendarType.gregorian:
        return 'ميلادي';
      case CalendarType.both:
        return 'الاثنان معاً';
    }
  }

  String get key {
    switch (this) {
      case CalendarType.hijri:
        return 'hijri';
      case CalendarType.gregorian:
        return 'gregorian';
      case CalendarType.both:
        return 'both';
    }
  }

  static CalendarType fromKey(String key) {
    switch (key) {
      case 'hijri':
        return CalendarType.hijri;
      case 'gregorian':
        return CalendarType.gregorian;
      case 'both':
        return CalendarType.both;
      default:
        return CalendarType.both;
    }
  }
}

/// تنسيق التواريخ حسب نوع التقويم
class DateFormatter {
  /// تحويل التاريخ الميلادي إلى هجري
  static HijriCalendar toHijri(DateTime date) {
    return HijriCalendar.fromDate(date);
  }

  /// اسم الشهر الهجري بالعربي
  static String hijriMonthName(int month) {
    const names = [
      'محرم', 'صفر', 'ربيع الأول', 'ربيع الآخر',
      'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان',
      'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة',
    ];
    return names[(month - 1).clamp(0, 11)];
  }

  /// اسم الشهر الميلادي بالعربي
  static String gregorianMonthName(int month) {
    const names = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    return names[(month - 1).clamp(0, 11)];
  }

  /// التاريخ فقط (بدون وقت)
  static String formatDate(DateTime date, CalendarType type) {
    final h = toHijri(date);
    final hijriStr = '${h.hDay} ${hijriMonthName(h.hMonth)} ${h.hYear} هـ';
    final gregStr = DateFormat('yyyy/MM/dd').format(date);

    switch (type) {
      case CalendarType.hijri:
        return hijriStr;
      case CalendarType.gregorian:
        return gregStr;
      case CalendarType.both:
        return '$hijriStr  •  $gregStr';
    }
  }

  /// التاريخ والوقت (للحركات المالية)
  static String formatDateTime(DateTime date, CalendarType type) {
    final h = toHijri(date);
    final time = DateFormat('HH:mm').format(date);
    final hijriStr = '${h.hDay} ${hijriMonthName(h.hMonth)} ${h.hYear} هـ';
    final gregStr = DateFormat('yyyy/MM/dd').format(date);

    switch (type) {
      case CalendarType.hijri:
        return '$hijriStr - $time';
      case CalendarType.gregorian:
        return '$gregStr - $time';
      case CalendarType.both:
        return '$hijriStr\n$gregStr - $time';
    }
  }

  /// الشهر والسنة (للأرشيف وكشوف الرواتب)
  static String formatMonthYear(DateTime date, CalendarType type) {
    final h = toHijri(date);
    final hijriStr = '${hijriMonthName(h.hMonth)} ${h.hYear} هـ';
    final gregStr =
        '${gregorianMonthName(date.month)} ${date.year} م';

    switch (type) {
      case CalendarType.hijri:
        return hijriStr;
      case CalendarType.gregorian:
        return gregStr;
      case CalendarType.both:
        return '$hijriStr  •  $gregStr';
    }
  }

  /// شهور السنة الهجرية (للقوائم المنسدلة)
  static List<String> hijriMonths = const [
    'محرم', 'صفر', 'ربيع الأول', 'ربيع الآخر',
    'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان',
    'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة',
  ];

  /// التاريخ المختصر (للجداول)
  static String shortDate(DateTime date, CalendarType type) {
    final h = toHijri(date);
    final hijriStr = '${h.hDay}/${h.hMonth}/${h.hYear}';
    final gregStr = DateFormat('yy/MM/dd').format(date);

    switch (type) {
      case CalendarType.hijri:
        return hijriStr;
      case CalendarType.gregorian:
        return gregStr;
      case CalendarType.both:
        return '$hijriStr\n$gregStr';
    }
  }

  /// السنة الهجرية الحالية
  static int currentHijriYear() {
    return toHijri(DateTime.now()).hYear;
  }

  /// الشهر الهجري الحالي
  static int currentHijriMonth() {
    return toHijri(DateTime.now()).hMonth;
  }
}

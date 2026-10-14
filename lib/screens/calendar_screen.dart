import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/calendar_event.dart';
import '../theme/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focused = DateTime.now();
  DateTime _selected = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final cal = context.watch<CalendarProvider>();
    final events = cal.eventsOn(_selected);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkNavy,
        title: const Text("التقويم الدراسي",
            style: TextStyle(color: AppColors.gold, fontFamily: 'Changa')),
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.gold,
        onPressed: () => _addEventDialog(context, cal, _selected),
        child: const Icon(Icons.add, color: AppColors.darkNavy),
      ),
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.darkNavy,
                border: Border.all(color: AppColors.gold, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TableCalendar(
                locale: 'ar',
                firstDay: DateTime(2020),
                lastDay: DateTime(2100),
                focusedDay: _focused,
                selectedDayPredicate: (d) => isSameDay(d, _selected),
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.saturday,
                headerStyle: const HeaderStyle(
                  titleTextStyle: TextStyle(
                      color: AppColors.gold,
                      fontSize: 18,
                      fontFamily: 'Changa'),
                  formatButtonVisible: false,
                  leftChevronIcon:
                      Icon(Icons.chevron_left, color: AppColors.gold),
                  rightChevronIcon:
                      Icon(Icons.chevron_right, color: AppColors.gold),
                  titleCentered: true,
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle:
                      TextStyle(color: AppColors.gold, fontFamily: 'Changa'),
                  weekendStyle:
                      TextStyle(color: AppColors.gold, fontFamily: 'Changa'),
                ),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  defaultTextStyle: const TextStyle(
                      color: Colors.white, fontFamily: 'Changa'),
                  weekendTextStyle: const TextStyle(
                      color: Colors.white70, fontFamily: 'Changa'),
                  todayDecoration: const BoxDecoration(
                    color: AppColors.blue,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: const TextStyle(
                      color: AppColors.darkNavy,
                      fontFamily: 'Changa',
                      fontWeight: FontWeight.bold),
                  markerDecoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 3,
                ),
                eventLoader: cal.eventsOn,
                onDaySelected: (selected, focused) {
                  setState(() {
                    _selected = selected;
                    _focused = focused;
                  });
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isEmpty) return null;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: events
                          .take(3)
                          .map((e) => Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 1),
                                decoration: BoxDecoration(
                                  color: (e as CalendarEvent).color,
                                  shape: BoxShape.circle,
                                ),
                              ))
                          .toList(),
                    );
                  },
                ),
              ),
            ),
            const Divider(color: AppColors.gold, thickness: 1),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                "أحداث ${DateFormat('yyyy/MM/dd').format(_selected)}",
                style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 16,
                    fontFamily: 'Changa',
                    fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: events.isEmpty
                  ? const Center(
                      child: Text("لا توجد أحداث في هذا اليوم",
                          style: TextStyle(
                              color: Colors.white54,
                              fontFamily: 'Changa')))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: events.length,
                      itemBuilder: (_, i) {
                        final e = events[i];
                        return Card(
                          color: AppColors.darkNavy,
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: e.color, width: 2),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: e.color.withOpacity(0.2),
                              child: Icon(e.icon, color: e.color),
                            ),
                            title: Text(e.title,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Changa',
                                    fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.typeName,
                                    style: TextStyle(
                                        color: e.color, fontFamily: 'Changa')),
                                if (e.description.isNotEmpty)
                                  Text(e.description,
                                      style: const TextStyle(
                                          color: Colors.white70,
                                          fontFamily: 'Changa',
                                          fontSize: 12)),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: AppColors.gold),
                                  onPressed: () => _addEventDialog(
                                      context, cal, _selected, event: e),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  onPressed: () => cal.remove(e.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _addEventDialog(BuildContext context, CalendarProvider cal,
      DateTime date, {CalendarEvent? event}) {
    final titleCtrl = TextEditingController(text: event?.title ?? '');
    final descCtrl = TextEditingController(text: event?.description ?? '');
    EventType type = event?.type ?? EventType.exam;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          backgroundColor: AppColors.darkNavy,
          title: Text(event == null ? "إضافة حدث" : "تعديل الحدث",
              style: const TextStyle(
                  color: AppColors.gold, fontFamily: 'Changa')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(hintText: "عنوان الحدث"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration:
                      const InputDecoration(hintText: "الوصف (اختياري)"),
                ),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text("نوع الحدث:",
                      style: TextStyle(
                          color: AppColors.gold, fontFamily: 'Changa')),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: EventType.values.map((t) {
                    final selected = t == type;
                    return ChoiceChip(
                      label: Text(_typeName(t),
                          style: TextStyle(
                              color: selected
                                  ? AppColors.darkNavy
                                  : AppColors.gold,
                              fontFamily: 'Changa')),
                      selected: selected,
                      selectedColor: AppColors.gold,
                      backgroundColor: AppColors.navy,
                      onSelected: (_) => setD(() => type = t),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("إلغاء"),
            ),
            TextButton(
              onPressed: () {
                if (titleCtrl.text.isEmpty) return;
                final newEvent = CalendarEvent(
                  id: event?.id ??
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleCtrl.text,
                  description: descCtrl.text,
                  date: date,
                  type: type,
                );
                if (event == null) {
                  cal.add(newEvent);
                } else {
                  cal.update(newEvent);
                }
                Navigator.pop(ctx);
              },
              child: const Text("حفظ",
                  style: TextStyle(color: AppColors.gold)),
            ),
          ],
        ),
      ),
    );
  }

  String _typeName(EventType t) {
    switch (t) {
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
}

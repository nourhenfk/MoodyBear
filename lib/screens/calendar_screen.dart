import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/mood_provider.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  Color _getMoodColor(int mood) {
    return switch (mood) {
      1 => Colors.red.shade400,
      2 => Colors.orange.shade400,
      3 => Colors.purple.shade400,
      4 => Colors.pink.shade400,
      5 => Colors.green.shade400,
      _ => Colors.grey.shade300,
    };
  }

  @override
  Widget build(BuildContext context) {
    final entries = context.watch<MoodProvider>().entries;

    final moodMap = {
      for (var e in entries)
        DateTime(e.date.year, e.date.month, e.date.day): e.mood
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mood Calendar"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: DateTime.now(),
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Colors.purple.shade300,
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: Colors.purple,
            shape: BoxShape.circle,
          ),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            final mood = moodMap[DateTime(day.year, day.month, day.day)];
            if (mood == null) return null;

            return Center(
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _getMoodColor(mood),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
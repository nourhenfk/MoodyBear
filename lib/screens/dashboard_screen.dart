import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../providers/mood_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String emoji(int mood) => ['😢', '😢', '😐', '😊', '😄'][mood - 1];

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodProvider>(
      builder: (context, mp, _) {
        final entries = mp.entries;
        if (entries.isEmpty) {
          return const Center(
            child: Text(
              "No mood yet.\nGo log how you feel today! 🧸",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
          );
        }

        final avgMood = mp.avgMood.toStringAsFixed(1);
        final avgProd = mp.avgProductivity.toStringAsFixed(1);
        final totalDays = entries
            .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
            .toSet()
            .length;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    const Text(
                      "Your Mood Journey",
                      style:
                      TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      emoji(mp.avgMood.round()),
                      style: const TextStyle(fontSize: 90),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _Stat(
                          emoji: emoji(mp.avgMood.round()),
                          value: avgMood,
                          label: "Avg Mood",
                        ),
                        _Stat(
                          emoji: "🚀",
                          value: avgProd,
                          label: "Avg Productivity",
                        ),
                        _Stat(
                          emoji: "📅",
                          value: "$totalDays",
                          label: "Active Days",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Last 7 Days",
                      style:
                      TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(7, (i) {
                        final day =
                        DateTime.now().subtract(Duration(days: i));
                        final entry = entries.firstWhereOrNull(
                              (e) => isSameDay(e.date, day),
                        );
                        return Column(
                          children: [
                            Text(
                              entry == null ? "➖" : emoji(entry.mood),
                              style: const TextStyle(fontSize: 40),
                            ),
                            const SizedBox(height: 8),
                            Text(DateFormat('E').format(day)),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "History",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            ...entries.map(
                  (e) => Dismissible(
                key: Key(e.id ?? e.date.toIso8601String()),
                background: Container(color: Colors.red),
                onDismissed: (_) {
                  if (e.id != null) {
                    mp.deleteEntry(e.id!);
                  }
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: Text(
                      emoji(e.mood),
                      style: const TextStyle(fontSize: 40),
                    ),
                    title: Text(
                      DateFormat('EEEE, MMM dd, yyyy').format(e.date),
                    ),
                    subtitle: Text(
                      "Productivity: ${"⭐" * e.productivity}\n"
                          "${e.notes.isEmpty ? "No notes" : e.notes}",
                    ),
                    isThreeLine: e.notes.isNotEmpty,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;

  const _Stat({
    required this.emoji,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 48)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }
}

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

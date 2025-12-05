import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mood_entry.dart';
import '../providers/mood_provider.dart';

class MoodEntryScreen extends StatefulWidget {
  const MoodEntryScreen({super.key});

  @override
  State<MoodEntryScreen> createState() => _MoodEntryScreenState();
}

class _MoodEntryScreenState extends State<MoodEntryScreen> {
  int _mood = 3;
  double _productivity = 3.0;
  final _notesController = TextEditingController();

  final List<Map<String, dynamic>> _moods = [
    {'emoji': '😭', 'label': 'Very Sad', 'value': 1},
    {'emoji': '😢', 'label': 'Sad', 'value': 2},
    {'emoji': '😐', 'label': 'Okay', 'value': 3},
    {'emoji': '😊', 'label': 'Good', 'value': 4},
    {'emoji': '😄', 'label': 'Amazing', 'value': 5},
  ];

  @override
  void initState() {
    super.initState();

    // Pre-fill form if today's entry already exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final entries = context.read<MoodProvider>().entries;
      final todayNormalized = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

      MoodEntry? todayEntry;
      try {
        todayEntry = entries.firstWhere(
              (e) =>
          e.date.year == todayNormalized.year &&
              e.date.month == todayNormalized.month &&
              e.date.day == todayNormalized.day,
        );
      } on StateError {
        todayEntry = null;
      }

      if (todayEntry != null) {
        setState(() {
          _mood = todayEntry!.mood;
          _productivity = todayEntry!.productivity.toDouble();
          _notesController.text = todayEntry!.notes;
        });
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await context.read<MoodProvider>().addOrUpdateTodayEntry(
      _mood,
      _productivity.round(),
      _notesController.text.trim(),
    );

    // Auto-hide the top toast after 12 seconds
    Future.delayed(const Duration(seconds: 12), () {
      if (mounted) {
        context.read<MoodProvider>().clearAiQuote();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final moodProvider = context.watch<MoodProvider>();

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "How are you feeling today?",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              Card(
                elevation: 10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Mood", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _moods.map((m) {
                          final selected = _mood == m['value'];
                          return GestureDetector(
                            onTap: () => setState(() => _mood = m['value']),
                            child: Column(
                              children: [
                                Text(m['emoji'], style: TextStyle(fontSize: selected ? 80 : 60)),
                                const SizedBox(height: 8),
                                Text(
                                  m['label'],
                                  style: TextStyle(
                                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 16,
                                    color: selected ? Colors.purple : null,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 48),

                      const Text("Productivity", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Slider(
                        value: _productivity,
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: _productivity.round().toString(),
                        activeColor: Colors.purple,
                        onChanged: (v) => setState(() => _productivity = v),
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("😴 Low"),
                          Text("🚀 High"),
                        ],
                      ),
                      const SizedBox(height: 48),

                      const Text("Notes", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _notesController,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: "What made today special?",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 40),

                      SizedBox(
                        height: 56,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: moodProvider.isLoading ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: moodProvider.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Save Mood', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),


        if (moodProvider.aiQuote.isNotEmpty)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: Material(
              elevation: 20,
              borderRadius: BorderRadius.circular(20),
              shadowColor: Colors.black.withOpacity(0.4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    const Text('🧸', style: TextStyle(fontSize: 34)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        moodProvider.aiQuote,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17.5,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => moodProvider.clearAiQuote(),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
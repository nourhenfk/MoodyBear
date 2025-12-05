import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/mood_entry.dart';
import '../services/mood_service.dart';
import '../services/gemini_service.dart';
import '../services/auth_service.dart';

class MoodProvider with ChangeNotifier {
  final MoodService _moodService = MoodService();
  final GeminiService _geminiService = GeminiService();
  final AuthService _authService = AuthService();

  List<MoodEntry> _entries = [];
  bool _isLoading = false;
  String _aiQuote = '';

  List<MoodEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  String get aiQuote => _aiQuote;

  double get avgMood => _entries.isEmpty
      ? 0
      : _entries.map((e) => e.mood).reduce((a, b) => a + b) / _entries.length;

  double get avgProductivity => _entries.isEmpty
      ? 0
      : _entries
      .map((e) => e.productivity)
      .reduce((a, b) => a + b) /
      _entries.length;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> loadEntries() async {
    final userId = _authService.currentUser?.id;
    if (userId == null) {
      _entries = [];
      _setLoading(false);
      return;
    }

    _setLoading(true);
    try {
      _entries = await _moodService.getMoodEntries(userId);
    } catch (e) {
      debugPrint('Error loading entries: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addOrUpdateTodayEntry(
      int mood,
      int productivity,
      String notes,
      ) async {
    final userId = _authService.currentUser?.id;
    if (userId == null) {
      debugPrint('No user logged in, cannot save mood.');
      return;
    }

    _setLoading(true);

    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);

    final existingIndex = _entries.indexWhere(
          (e) =>
      e.date.year == todayMidnight.year &&
          e.date.month == todayMidnight.month &&
          e.date.day == todayMidnight.day,
    );

    try {
      final supabase = Supabase.instance.client;

      if (existingIndex != -1) {
        // UPDATE existing entry
        final entry = _entries[existingIndex];

        await supabase
            .from('mood_entries')
            .update({
          'mood': mood,
          'productivity': productivity,
          'notes': notes,
        })
            .eq('id', entry.id!);

        _entries[existingIndex] = MoodEntry(
          id: entry.id,
          mood: mood,
          productivity: productivity,
          notes: notes,
          date: entry.date,
          userId: userId,
        );
      } else {
        // INSERT new entry
        final response = await supabase
            .from('mood_entries')
            .insert({
          'mood': mood,
          'productivity': productivity,
          'notes': notes,
          'date': todayMidnight.toIso8601String(),
          'user_id': userId,
        })
            .select()
            .single(); // 👈 ensure single row

        final newEntry = MoodEntry.fromMap(response as Map<String, dynamic>);
        _entries.insert(0, newEntry);
      }

      // Ask Gemini for a motivational quote
      _aiQuote = await _geminiService.getMotivationalQuote(mood);
    } catch (e) {
      debugPrint('Mood save error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteEntry(String id) async {
    try {
      await _moodService.deleteMoodEntry(id);
      _entries.removeWhere((e) => e.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Delete mood error: $e');
    }
  }

  void clearAiQuote() {
    _aiQuote = '';
    notifyListeners();
  }
}

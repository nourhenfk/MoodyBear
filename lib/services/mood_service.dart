import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/mood_entry.dart';

class MoodService {
  final SupabaseClient client = Supabase.instance.client;

  Future<List<MoodEntry>> getMoodEntries(String userId) async {
    final response = await client
        .from('mood_entries')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false);

    return (response as List).map((json) => MoodEntry.fromMap(json)).toList();
  }

  Future<void> deleteMoodEntry(String id) async {
    await client.from('mood_entries').delete().eq('id', id);
  }
}
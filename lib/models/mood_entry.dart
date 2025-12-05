class MoodEntry {
  final String? id;
  final int mood;
  final int productivity;
  final String notes;
  final DateTime date;
  final String userId;

  MoodEntry({
    this.id,
    required this.mood,
    required this.productivity,
    required this.notes,
    required this.date,
    required this.userId,
  });

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'] as String?,
      mood: map['mood'] as int,
      productivity: map['productivity'] as int,
      notes: map['notes'] as String? ?? '',
      date: DateTime.parse(map['date'] as String),
      userId: map['user_id'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mood': mood,
      'productivity': productivity,
      'notes': notes,
      'date': date.toIso8601String(),
      'user_id': userId,
    };
  }
}

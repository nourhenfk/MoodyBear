import 'package:http/http.dart' as http;
import 'dart:convert';

class GeminiService {
  static const String apiKey = 'AIzaSyA1wXt-2a2nTUuxW4TQk1M_MbhWkKWNOp0';
  static const String apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  final Map<int, String> fallbackQuotes = {
    1: "Even the darkest night will end and the sun will rise. You've got this 🌅",
    2: "It's okay to have a bad day. Tomorrow is fresh with no mistakes in it yet 💙",
    3: "You're doing just fine. Keep going, one step at a time ⭐",
    4: "Your vibe is contagious today! Keep shining ✨",
    5: "You're absolutely crushing it! Keep that fire burning 🔥",
  };

  Future<String> getMotivationalQuote(int mood) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "contents": [{
            "parts": [{
              "text": "Give me a short, warm motivational quote (max 15 words) for someone feeling ${_moodText(mood)}. Add one emoji."
            }]
          }]
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      }
    } catch (e) {
      // silent fallback
    }
    return fallbackQuotes[mood] ?? fallbackQuotes[3]!;
  }

  String _moodText(int mood) {
    switch (mood) {
      case 1: return "very sad";
      case 2: return "low";
      case 3: return "neutral";
      case 4: return "good";
      case 5: return "amazing";
      default: return "okay";
    }
  }
}
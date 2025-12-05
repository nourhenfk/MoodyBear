import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../providers/mood_provider.dart';

class TodaysBearScreen extends StatelessWidget {
  const TodaysBearScreen({super.key});


  ({String lottie, String message, Color bg}) getBearForMood(double avgMood) {
    if (avgMood <= 1.5) {
      return (
      lottie: 'https://lottie.host/401e1723-5419-4cc9-b635-ae9a9f18821b/zdqwHNmgxo.json', // sleepy bear
      message: "Hey... it's okay to rest. I'm here hugging you tight.",
      bg: Colors.purple.shade100
      );
    } else if (avgMood <= 2.5) {
      return (
      lottie: 'https://lottie.host/4461b4c8-2b15-4297-a60b-811d7750c9d5/jIAYWczmXI.json', // sad bear
      message: "Some days are heavy. But you're stronger than you know.",
      bg: Colors.blue.shade100
      );
    } else if (avgMood <= 3.5) {
      return (
      lottie: 'https://lottie.host/4da13016-fb64-4c38-88db-f19eda006b58/B5GFCpPOwY.json', // calm bear
      message: "You're doing just fine. Keep going, one step at a time.",
      bg: Colors.grey.shade200
      );
    } else if (avgMood <= 4.5) {
      return (
      lottie: 'https://lottie.host/b64dd6be-78dc-4da7-b7f0-ff770c74ba4d/kpZ2uNutPV.json', // happy bear
      message: "Look at you shining! Keep spreading that good energy!",
      bg: Colors.pink.shade100
      );
    } else {
      return (
      lottie: 'https://lottie.host/337767cf-cb2a-49d1-b9d6-bf8c2efed286/31ecPAqvtK.json', // dancing bear
      message: "YOU ARE ON FIRE TODAY!!! Let's dance through life!!!",
      bg: Colors.orange.shade100
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final moodProvider = context.watch<MoodProvider>();
    final avgMood = moodProvider.avgMood;
    final bear = getBearForMood(avgMood);

    return Scaffold(
      backgroundColor: bear.bg,
      appBar: AppBar(
        title: const Text("Today's Bear Says"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              height: 300,
              child: Lottie.network(bear.lottie),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    bear.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              avgMood > 0 ? "Your average mood: ${avgMood.toStringAsFixed(1)}" : "Start tracking to meet your bear!",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
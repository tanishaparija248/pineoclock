import 'dart:async';
import 'package:flutter/material.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  int totalSeconds = 60;
  int initialSeconds = 60;
  Timer? timer;
  bool isRunning = false;

  void startTimer() {
    if (isRunning) return;
    isRunning = true;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (totalSeconds > 0) {
        setState(() { totalSeconds--; });
      } else {
        timer.cancel();
        setState(() { isRunning = false; });
      }
    });
    setState(() {});
  }

  void pauseTimer() {
    timer?.cancel();
    setState(() { isRunning = false; });
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      totalSeconds = initialSeconds;
      isRunning = false;
    });
  }

  String formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$mins:$secs";
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Widget _presetChip(int minutes) {
    return ActionChip(
      label: Text(
        "${minutes}m",
        style: const TextStyle(
          color: Color(0xFF43A047),
          fontWeight: FontWeight.w600,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFFFB300), width: 1.5),
      ),
      backgroundColor: Colors.transparent,
      onPressed: () {
        setState(() {
          initialSeconds = minutes * 60;
          totalSeconds = initialSeconds;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: const Text("Timer"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Amber progress ring
                SizedBox(
                  width: 280,
                  height: 280,
                  child: CircularProgressIndicator(
                    value: totalSeconds / initialSeconds,
                    strokeWidth: 10,
                    backgroundColor: Colors.white30,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFFFB300)),
                  ),
                ),
                // White circle fill inside ring
                Container(
                  width: 245,
                  height: 245,
                  decoration: const BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      formatTime(totalSeconds),
                      style: const TextStyle(
                        color: Color(0xFF43A047),
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Wrap(
              spacing: 10,
              children: [
                _presetChip(5),
                _presetChip(10),
                _presetChip(25),
                _presetChip(45),
                _presetChip(60),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: isRunning ? pauseTimer : startTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB300),
                    foregroundColor: const Color(0xFF43A047),
                    elevation: 0,
                    side: const BorderSide(color: Color(0xFFFFB300), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(isRunning ? "Pause" : "Start"),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: resetTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB300),
                    foregroundColor: const Color(0xFF43A047),
                    elevation: 0,
                    side: const BorderSide(color: Color(0xFFFFB300), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Reset"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

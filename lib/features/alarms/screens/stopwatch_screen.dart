import 'dart:async';
import 'package:flutter/material.dart';

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  final Stopwatch stopwatch = Stopwatch();
  Timer? timer;

  final List<String> laps = [];

  void startTimer() {
    timer = Timer.periodic(
      const Duration(milliseconds: 30),
          (_) => setState(() {}),
    );
  }

  void startPause() {
    if (stopwatch.isRunning) {
      stopwatch.stop();
      timer?.cancel();
    } else {
      stopwatch.start();
      startTimer();
    }

    setState(() {});
  }

  void reset() {
    stopwatch.stop();
    stopwatch.reset();
    timer?.cancel();

    setState(() {
      laps.clear();
    });
  }

  void addLap() {
    setState(() {
      laps.insert(0, formatTime(stopwatch.elapsed));
    });
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final centiseconds =
    twoDigits((duration.inMilliseconds.remainder(1000) ~/ 10));

    return "$hours:$minutes:$seconds.$centiseconds";
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: const Text("Stopwatch"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),

            Text(
              formatTime(stopwatch.elapsed),
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            Wrap(
              alignment: WrapAlignment.center,
              spacing: 0,
              runSpacing: 1,
              children: [
                ElevatedButton(
                  onPressed: startPause,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD54F),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: Text(
                    stopwatch.isRunning ? "Pause" : "Start",
                    style: const TextStyle(fontSize: 18),
                  ),
                ),

                const SizedBox(width: 10),

                ElevatedButton(
                  onPressed: reset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD54F),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: const Text(
                    "Reset",
                    style: TextStyle(fontSize: 18),
                  ),
                ),

                const SizedBox(width: 10),

                ElevatedButton(
                  onPressed: stopwatch.isRunning ? addLap : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD54F),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    "Lap",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            if (laps.isNotEmpty)
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Laps",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: laps.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Text(
                      "Lap ${laps.length - index}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Text(laps[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
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
      backgroundColor:  Colors.white,
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
            Center(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0XFFFAFAFA),
                  border: Border.all(
                    color: const Color(0xFFFFB300),
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Text(
                      formatTime(stopwatch.elapsed),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                ElevatedButton.icon(
                  onPressed: startPause,
                  icon: Icon(
                    stopwatch.isRunning
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),
                  label: Text(
                    stopwatch.isRunning
                        ? "Pause"
                        : "Start",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD54F),
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: reset,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Reset"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD54F),
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: stopwatch.isRunning
                      ? addLap
                      : null,
                  icon: const Icon(Icons.flag),
                  label: const Text("Lap"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD54F),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            if (laps.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFFB300),
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      size: 40,
                      color: Color(0xFFFFB300),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "No laps yet",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
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
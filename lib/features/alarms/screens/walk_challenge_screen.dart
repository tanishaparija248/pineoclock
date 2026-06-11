import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:alarm/alarm.dart';
import '../services/alarm_storage.dart';

class WalkChallengeScreen extends StatefulWidget {
  final int alarmId;
  final int stepTarget;

  const WalkChallengeScreen({
    super.key,
    required this.alarmId,
    required this.stepTarget,
  });

  @override
  State<WalkChallengeScreen> createState() => _WalkChallengeScreenState();
}

class _WalkChallengeScreenState extends State<WalkChallengeScreen> {
  StreamSubscription<StepCount>? _stepSubscription;

  int? _initialSteps; 
  int _stepsWalked = 0;
  bool _challengeCompleted = false;
  bool _isSensorStuck = false;
  Timer? _stuckTimer;

  @override
  void initState() {
    super.initState();
    _initChallenge();
  }

  void _initChallenge() {
    _stuckTimer?.cancel();
    _isSensorStuck = false;
    
    // Small delay before starting sensor to ensure a clean session
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _startListening();
    });

    // If steps don't initialize in 5 seconds, show the manual refresh option
    _stuckTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _initialSteps == null) {
        setState(() => _isSensorStuck = true);
      }
    });
  }

  void _startListening() {
    _stepSubscription?.cancel();
    _stepSubscription = Pedometer.stepCountStream.listen(
      (StepCount event) {
        if (!mounted) return;

        // Baseline on first event
        if (_initialSteps == null) {
          setState(() {
            _initialSteps = event.steps;
            _isSensorStuck = false;
          });
          _stuckTimer?.cancel();
        }

        final walked = event.steps - _initialSteps!;

        setState(() {
          _stepsWalked = walked < 0 ? 0 : walked;
        });

        if (_stepsWalked >= widget.stepTarget && !_challengeCompleted) {
          _challengeCompleted = true;
          _completeChallenge();
        }
      },
      onError: (error) {
        debugPrint("Step Counter Error: $error");
        setState(() => _isSensorStuck = true);
      },
      cancelOnError: false,
    );
  }

  Future<void> _completeChallenge() async {
    _stepSubscription?.cancel();
    _stuckTimer?.cancel();

    // Stop the alarm sound and update storage status to "OFF"
    await Alarm.stop(widget.alarmId);
    await AlarmStorage.handleAlarmDismissed(widget.alarmId);


    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFFFFF8E1),
        title: const Text(
          "Challenge Completed 🎉",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24, 
            fontWeight: FontWeight.bold,
            color: Color(0xFF3E2723),
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🍍', style: TextStyle(fontSize: 60)),
            SizedBox(height: 16),
            Text(
              "Great job! You're fully awake now. Pine-tastic start to your day!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF5D4037)),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB300),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Exit challenge screen
            },
            child: const Text("Awesome!",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _stepSubscription?.cancel();
    _stuckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = _initialSteps == null ? 0 : _stepsWalked / widget.stepTarget;
    if (progress > 1) progress = 1;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFB300),
                Color(0xFFFFD54F),
                Color(0xFFFFF8E1),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Walking Challenge",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(height: 60),
                
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 14,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3E2723)),
                      ),
                    ),
                    const Text(
                      '🚶',
                      style: TextStyle(fontSize: 90),
                    ),
                  ],
                ),

                const SizedBox(height: 60),

                Text(
                  "Steps: $_stepsWalked / ${widget.stepTarget}",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                if (_isSensorStuck) ...[
                   ElevatedButton.icon(
                    onPressed: _initChallenge,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Sensor not responding? Refresh"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () async {
                      await Alarm.stop(widget.alarmId);
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    },
                    child: const Text("Skip Challenge (Emergency)", style: TextStyle(color: Colors.red)),
                  )
                ] else ...[
                   Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _initialSteps == null ? "Waiting for sensor..." : "Keep moving! 🍍",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

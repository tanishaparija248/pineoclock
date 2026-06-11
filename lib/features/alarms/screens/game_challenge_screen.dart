import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import '../services/alarm_storage.dart';

class GameChallengeScreen extends StatefulWidget {
  final int alarmId;

  const GameChallengeScreen({
    super.key,
    required this.alarmId,
  });

  @override
  State<GameChallengeScreen> createState() => _GameChallengeScreenState();
}

class _GameChallengeScreenState extends State<GameChallengeScreen> {
  final List<int> _targetPattern = [];
  final List<int> _userPattern = [];
  bool _isShowingPattern = true;
  bool _isGameOver = false;
  final int _patternLength = 4;

  @override
  void initState() {
    super.initState();
    _generatePattern();
    _showPattern();
  }

  void _generatePattern() {
    final random = Random();
    for (int i = 0; i < _patternLength; i++) {
      _targetPattern.add(random.nextInt(4));
    }
  }

  Future<void> _showPattern() async {
    setState(() {
      _isShowingPattern = true;
      _userPattern.clear();
    });

    await Future.delayed(const Duration(seconds: 1));

    for (int i = 0; i < _targetPattern.length; i++) {
      if (!mounted) return;
      setState(() {
        _activeButton = _targetPattern[i];
      });
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() {
        _activeButton = -1;
      });
      await Future.delayed(const Duration(milliseconds: 200));
    }

    if (mounted) {
      setState(() {
        _isShowingPattern = false;
      });
    }
  }

  int _activeButton = -1;

  void _handleTap(int index) {
    if (_isShowingPattern || _isGameOver) return;

    setState(() {
      _userPattern.add(index);
    });

    if (_userPattern[(_userPattern.length - 1)] != _targetPattern[_userPattern.length - 1]) {
      // Wrong tap
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Wrong pattern! Try again."), duration: Duration(milliseconds: 500)),
      );
      _showPattern();
      return;
    }

    if (_userPattern.length == _targetPattern.length) {
      // Completed!
      setState(() {
        _isGameOver = true;
      });
      _completeChallenge();
    }
  }

  Future<void> _completeChallenge() async {
    await Alarm.stop(widget.alarmId);
    await AlarmStorage.handleAlarmDismissed(widget.alarmId);
    final index = AlarmStorage.alarms.indexWhere(
          (alarm) => alarm.id == widget.alarmId,
    );

    if (index != -1) {
      AlarmStorage.alarms[index] =
          AlarmStorage.alarms[index].copyWith(
            isEnabled: false,
          );

      await AlarmStorage.saveAlarms(AlarmStorage.alarms);
      AlarmStorage.changeNotifier.notifyListeners();
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFFFFF8E1),
        title: const Text(
          "Mind Sharp! 🧠",
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
              "Brain game completed! You're ready to tackle the day.",
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
            child: const Text("Let's Go!",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  "Brain Escape Mode",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isShowingPattern ? "Watch the pattern..." : "Repeat the pattern!",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF5D4037),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 60),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(40),
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  children: List.generate(4, (index) {
                    return GestureDetector(
                      onTap: () => _handleTap(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: _activeButton == index
                              ? const Color(0xFF3E2723)
                              : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF3E2723),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            _getIcon(index),
                            size: 40,
                            color: _activeButton == index ? Colors.white : const Color(0xFF3E2723),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 40),
                if (_isGameOver)
                  const CircularProgressIndicator(color: Color(0xFF3E2723)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon(int index) {
    switch (index) {
      case 0: return Icons.star;
      case 1: return Icons.favorite;
      case 2: return Icons.circle;
      default: return Icons.square;
    }
  }
}

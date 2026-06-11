import 'dart:async';
import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'home_screen.dart';
import 'world_clock_screen.dart';
import 'stopwatch_screen.dart';
import 'timer_screen.dart';
import 'alarm_ring_screen.dart';
import 'walk_challenge_screen.dart';
import 'game_challenge_screen.dart';
import '../services/alarm_storage.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int currentIndex = 0;
  StreamSubscription<AlarmSettings>? _alarmSubscription;

  final List<Widget> screens = [
    const HomeScreen(),
    const WorldClockScreen(),
    const StopwatchScreen(),
    const TimerScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _listenToAlarm();
  }

  bool _isNavigationInProgress = false;

  void _listenToAlarm() {
    _alarmSubscription = Alarm.ringStream.stream.listen(
          (alarmSettings) {
        if (_isNavigationInProgress) return;
        _isNavigationInProgress = true;

        // ✅ Read alarmType directly from notification body
        final body = alarmSettings.notificationSettings.body.toLowerCase();
        String alarmType = 'normal';
        if (body.contains('walk')) {
          alarmType = 'walk';
        } else if (body.contains('game') || body.contains('brain')) {
          alarmType = 'game';
        }

        final matched = AlarmStorage.alarms.where((a) => a.id == alarmSettings.id).firstOrNull;
        final stepTarget = matched?.stepTarget ?? 50;

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) {
            _isNavigationInProgress = false;
            return;
          }

          try {
            if (alarmType == 'walk') {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => WalkChallengeScreen(
                    alarmId: alarmSettings.id,
                    stepTarget: stepTarget,
                  ),
                ),
              );
            } else if (alarmType == 'game') {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GameChallengeScreen(
                    alarmId: alarmSettings.id,
                  ),
                ),
              );
            } else {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AlarmRingScreen(
                    alarmSettings: alarmSettings,
                    alarmType: alarmType,
                  ),
                ),
              );
            }
          } catch (e) {
            debugPrint('Navigation error: $e');
          } finally {
            _isNavigationInProgress = false;
          }
        });
      },
      onError: (e) => debugPrint('Alarm stream error: $e'),
      cancelOnError: false,
    );
  }

  @override
  void dispose() {
    _alarmSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        selectedItemColor: const Color(0xFF7CB342),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.alarm), label: 'Alarm'),
          BottomNavigationBarItem(icon: Icon(Icons.public), label: 'World Clock'),
          BottomNavigationBarItem(icon: Icon(Icons.timer_outlined), label: 'Stop Watch'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Timer'),
        ],
      ),
    );
  }
}
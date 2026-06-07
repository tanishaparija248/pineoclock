import 'dart:async';
import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'home_screen.dart';
import 'world_clock_screen.dart';
import 'stopwatch_screen.dart';
import 'timer_screen.dart';
import 'alarm_ring_screen.dart';

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

  void _listenToAlarm() {
    _alarmSubscription = Alarm.ringStream.stream.listen(
          (alarmSettings) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => AlarmRingScreen(alarmSettings: alarmSettings),
              ),
                  (route) => false,
            );
          }
        });
      },
      onError: (e) => print('Alarm stream error: $e'),
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
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF7CB342),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: 'Alarm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: 'World Clock',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_outlined),
            label: 'Stop Watch',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Timer',
          ),
        ],
      ),
    );
  }
}

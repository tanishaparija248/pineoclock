import 'package:flutter/material.dart';
import 'package:pineoclock_app/features/alarms/screens/main_navigation_screen.dart';
import 'package:timezone/data/latest.dart' as tz;
void main() {
  tz.initializeTimeZones();
  runApp(const PineOClockApp());
}

class PineOClockApp extends StatelessWidget {
  const PineOClockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PineOClock',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFF8E1),
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFB300),
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

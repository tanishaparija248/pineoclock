import 'package:flutter/material.dart';
import 'package:pineoclock_app/features/alarms/screens/main_navigation_screen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'features/alarms/services/notification_service.dart';
import 'package:alarm/alarm.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'features/alarms/screens/alarm_overlay_widget.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma("vm:entry-point")
void overlayMain() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Material(
      child: AlarmOverlayWidget(),
    ),
  ));
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Alarm.init();

  await Permission.systemAlertWindow.request(); // ← only this added

  if (!await FlutterOverlayWindow.isPermissionGranted()) {
    await FlutterOverlayWindow.requestPermission();
  }

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

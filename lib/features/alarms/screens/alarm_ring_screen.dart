import 'dart:async';
import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import '../services/alarm_storage.dart';
// This screen is only used for NORMAL alarms.
// Walk alarms go directly to WalkChallengeScreen via main_navigation_screen.dart

class AlarmRingScreen extends StatefulWidget {
  final AlarmSettings alarmSettings;
  final String alarmType;

  const AlarmRingScreen({
    super.key,
    required this.alarmSettings,
    required this.alarmType,
  });

  @override
  State<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends State<AlarmRingScreen>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  DateTime _now = DateTime.now();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String get _timeString {
    final hour = _now.hour > 12
        ? _now.hour - 12
        : _now.hour == 0
        ? 12
        : _now.hour;
    final minute = _now.minute.toString().padLeft(2, '0');
    final period = _now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String get _dateString {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${days[_now.weekday - 1]}, ${months[_now.month - 1]} ${_now.day}';
  }

  Future<void> _stopAlarm() async {
    await Alarm.stop(widget.alarmSettings.id);

    final alarms = AlarmStorage.alarms;

    final index = alarms.indexWhere(
          (alarm) => alarm.id == widget.alarmSettings.id,
    );

    if (index != -1) {
      alarms[index] = alarms[index].copyWith(
        isEnabled: false,
      );

      AlarmStorage.saveAlarms(alarms);
      AlarmStorage.changeNotifier.notifyListeners();
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _snoozeAlarm() async {
    await Alarm.stop(widget.alarmSettings.id);
    final snoozeTime = DateTime.now().add(const Duration(minutes: 5));
    await Alarm.set(
      alarmSettings: AlarmSettings(
        id: widget.alarmSettings.id,
        dateTime: snoozeTime,
        assetAudioPath: widget.alarmSettings.assetAudioPath,
        loopAudio: true,
        vibrate: true,
        androidFullScreenIntent: true,
        warningNotificationOnKill: true,
        notificationSettings: widget.alarmSettings.notificationSettings,
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top: time & date
                Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Column(
                    children: [
                      Text(
                        _timeString,
                        style: const TextStyle(
                          fontSize: 65,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3E2723),
                          letterSpacing: -2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _dateString,
                        style: const TextStyle(
                          fontSize: 19,
                          color: Color(0xFF5D4037),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.alarm,
                                color: Color(0xFF3E2723), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              widget.alarmSettings.notificationSettings.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3E2723),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),


                // Bottom: Stop & Snooze
                Padding(
                  padding: const EdgeInsets.only(bottom: 60),
                  child: Column(
                    children: [
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: GestureDetector(
                          onTap: _stopAlarm,
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3E2723),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF3E2723)
                                      .withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Stop",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF3E2723),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      GestureDetector(
                        onTap: _snoozeAlarm,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                                color: const Color(0xFFFFB300), width: 1.5),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.snooze,
                                  color: Color(0xFF3E2723), size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Snooze 5 mins',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3E2723),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

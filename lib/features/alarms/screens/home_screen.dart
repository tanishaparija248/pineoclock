import 'dart:async';
import 'package:flutter/material.dart';
import '../models/alarm_model.dart';
import 'package:alarm/alarm.dart';
import '../services/alarm_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer _timer;
  DateTime _now = DateTime.now();
  List<AlarmModel> _alarms = [];

  String selectedRingtone = 'assets/alarm.mp3';

  final List<String> ringtones = [
    'assets/alarm.mp3',
    'assets/bell.mp3',
    'assets/birds.mp3',
    'assets/digital.mp3',
  ];

  @override
  void initState() {
    super.initState();
    _alarms = AlarmStorage.alarms;
    
    // Listen for external storage changes (like when an alarm is dismissed)
    AlarmStorage.changeNotifier.addListener(_syncAlarms);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  void _syncAlarms() {
    if (mounted) {
      setState(() {
        _alarms = List.from(AlarmStorage.alarms);
      });
    }
  }

  @override
  void dispose() {
    AlarmStorage.changeNotifier.removeListener(_syncAlarms);
    _timer.cancel();
    super.dispose();
  }

  String get _greeting {
    final hour = _now.hour;
    if (hour < 12) {
      return 'Good Morning ☀️';
    }
    if (hour < 17) return 'Good Afternoon 🌤️';
    if (hour < 21) return 'Good Evening 🌇';
    return 'Good Night 🌙';
  }

  String get _subGreeting {
    final hour = _now.hour;
    if (hour < 12) return "The snooze button lost today 😎";
    if (hour < 17) return 'Keep the streak alive ⚡';
    if (hour < 21) return 'Clocking out soon? ⏰';
    return 'Sleep > scrolling 😴';
  }

  String get _currentTime {
    final hour = _now.hour > 12 ? _now.hour - 12 : _now.hour == 0 ? 12 : _now.hour;
    final minute = _now.minute.toString().padLeft(2, '0');
    final second = _now.second.toString().padLeft(2, '0');
    final period = _now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute:$second $period';
  }

  Future<void> _addAlarm() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFFB300),
              onPrimary: Colors.white,
              onSurface: Color(0xFF3E2723),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    final String? label = await _showLabelDialog();
    if (label == null || !mounted) return;

    // Step 1: Choose alarm type
    final selectedType = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Choose Alarm Type",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.alarm, color: Color(0xFFFFB300)),
              title: const Text("Normal Alarm",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("Tap to dismiss"),
              onTap: () => Navigator.pop(context, "normal"),
            ),
            ListTile(
              leading: const Icon(Icons.directions_walk, color: Color(0xFF8DB600)),
              title: const Text("Walk Escape Mode",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("Walk steps to dismiss"),
              onTap: () => Navigator.pop(context, "walk"),
            ),
            ListTile(
              leading: const Icon(Icons.psychology, color: Color(0xFFD32F2F)),
              title: const Text("Brain Escape Mode",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("Memory game to dismiss"),
              onTap: () => Navigator.pop(context, "game"),
            ),
          ],
        ),
      ),
    );

    if (selectedType == null || !mounted) return;

    // Step 2: If walk, let user pick step target
    int stepTarget = 50;
    if (selectedType == "walk") {
      final selectedSteps = await showDialog<int>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Choose Step Target",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Text("🚶", style: TextStyle(fontSize: 24)),
                title: const Text("20 Steps",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Easy"),
                onTap: () => Navigator.pop(context, 20),
              ),
              ListTile(
                leading: const Text("🏃", style: TextStyle(fontSize: 24)),
                title: const Text("50 Steps",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Medium"),
                onTap: () => Navigator.pop(context, 50),
              ),
              ListTile(
                leading: const Text("💪", style: TextStyle(fontSize: 24)),
                title: const Text("100 Steps",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Hard"),
                onTap: () => Navigator.pop(context, 100),
              ),
            ],
          ),
        ),
      );

      if (selectedSteps == null) return;
      stepTarget = selectedSteps;
    }

    final now = DateTime.now();
    DateTime alarmTime = DateTime(
      now.year, now.month, now.day,
      picked.hour, picked.minute,
    );

    if (alarmTime.isBefore(now)) {
      alarmTime = alarmTime.add(const Duration(days: 1));
    }

    final alarmId = DateTime.now().millisecondsSinceEpoch % 2147483647;

    setState(() {
      _alarms.add(
        AlarmModel(
          id: alarmId,
          label: label.isEmpty ? 'Alarm' : label,
          time: alarmTime,
          isEnabled: true,
          repeatDays: [],
          alarmType: selectedType,
          stepTarget: stepTarget,
        ),
      );
      _alarms.sort((a, b) => a.time.compareTo(b.time));
      AlarmStorage.saveAlarms(_alarms);
    });

    String notificationBody = 'Your alarm is ringing!';
    if (selectedType == 'walk') {
      notificationBody = 'Walk $stepTarget steps to dismiss!';
    } else if (selectedType == 'game') {
      notificationBody = 'Solve the Brain Game to dismiss!';
    }
    selectedRingtone = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Choose Ringtone"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("Default Alarm"),
              onTap: () =>
                  Navigator.pop(context, 'assets/alarm.mp3'),
            ),
            ListTile(
              title: const Text("Loud"),
              onTap: () =>
                  Navigator.pop(context, 'assets/loud.mp3'),
            ),
            ListTile(
              title: const Text("Siren"),
              onTap: () =>
                  Navigator.pop(context, 'assets/siren.mp3'),
            ),
            ListTile(
              title: const Text("Soft"),
              onTap: () =>
                  Navigator.pop(context, 'assets/soft.mp3'),
            ),
            ListTile(
              title: const Text("Wakeup"),
              onTap: () =>
                  Navigator.pop(context, 'assets/wakeup.mp3'),
            ),

          ],
        ),
      ),
    ) ??
        'assets/alarm.mp3';
    await Alarm.set(
      alarmSettings: AlarmSettings(
        id: alarmId,
        dateTime: alarmTime,
        assetAudioPath: selectedRingtone,
        loopAudio: true,
        vibrate: true,
        androidFullScreenIntent: true,
        warningNotificationOnKill: true,
        notificationSettings: NotificationSettings(
          title: 'Pine🍍Clock',
          body: notificationBody,
          // ✅ no stopButton for walk/game alarms — must complete challenge to dismiss
          stopButton: (selectedType == 'walk' || selectedType == 'game') ? null : 'Stop Alarm',
          icon: 'ic_launcher',
        ),
      ),
    );
  }

  Future<String?> _showLabelDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Alarm Label',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'e.g. School, Gym, Wake up...',
            filled: true,
            fillColor: const Color(0xFFFFF8E1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.black54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Add',
                style: TextStyle(
                    color: Color(0xFFFFB300),
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleAlarm(int index) async {
    final alarm = _alarms[index];
    final newEnabled = !alarm.isEnabled;

    if (newEnabled) {
      String notificationBody = 'Your alarm is ringing!';
      if (alarm.alarmType == 'walk') {
        notificationBody = 'Walk ${alarm.stepTarget} steps to dismiss!';
      } else if (alarm.alarmType == 'game') {
        notificationBody = 'Solve the Brain Game to dismiss!';
      }

      await Alarm.set(
        alarmSettings: AlarmSettings(
          id: alarm.id,
          dateTime: alarm.time,
          assetAudioPath: selectedRingtone,
          loopAudio: true,
          vibrate: true,
          androidFullScreenIntent: true,
          warningNotificationOnKill: true,
          notificationSettings: NotificationSettings(
            title: 'PineOClock 🍍',
            body: notificationBody,
            // ✅ no stopButton for walk/game alarms
            stopButton: (alarm.alarmType == 'walk' || alarm.alarmType == 'game') ? null : 'Stop Alarm',
            icon: 'ic_launcher',
          ),
        ),
      );
    } else {
      await Alarm.stop(alarm.id);
    }

    setState(() {
      _alarms[index] = alarm.copyWith(isEnabled: newEnabled);
      AlarmStorage.saveAlarms(_alarms);
    });
  }

  void _deleteAlarm(int index) {
    AlarmModel deletedAlarm = _alarms[index];
    int deletedIndex = index;

    setState(() {
      _alarms.removeAt(index);
    });

    AlarmStorage.saveAlarms(_alarms);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Alarm deleted'),
        backgroundColor: const Color(0xFFFFB300),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _alarms.insert(deletedIndex, deletedAlarm);
            });

            AlarmStorage.saveAlarms(_alarms);
          },
        ),
      ),
    );
  }

  String _formatAlarmTime(DateTime time) {
    final hour = time.hour > 12
        ? time.hour - 12
        : time.hour == 0 ? 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _timeUntil(DateTime alarmTime) {
    final diff = alarmTime.difference(_now);
    if (diff.isNegative) return 'Passed';
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    if (hours > 0) return 'In ${hours}h ${minutes}m';
    if (minutes > 0) return 'In ${minutes}m';
    return 'In less than a minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFFB300),
        onPressed: _addAlarm,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(_greeting,
                style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937))),
            const SizedBox(height: 6),
            Text(_subGreeting,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Color(0XFF6B7280))),
            const SizedBox(height: 24),
            _buildClockCard(),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Alarms',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937))),
                Text('${_alarms.length} set',
                    style: const TextStyle(
                        fontSize: 14, color: Colors.black)),
              ],
            ),
            const SizedBox(height: 16),
            _alarms.isEmpty ? _buildEmptyState() : _buildAlarmList(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildClockCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 24,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFC107),
            Color(0xFFFFE082),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _currentTime,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '${_getDayName(_now.weekday)} • ${_getMonthName(_now.month)} ${_now.day}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF5D4037),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    return months[month - 1];
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Icon(
              Icons.alarm_add,
              size: 60,
              color: Color(0xFFFFC107),
            ),
            const Text('No alarms yet!',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            const SizedBox(height: 8),
            const Text('Tap + to add your first alarm',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildAlarmList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _alarms.length,
      itemBuilder: (context, index) {
        final alarm = _alarms[index];
        return _buildAlarmCard(alarm, index);
      },
    );
  }

  Widget _buildAlarmCard(AlarmModel alarm, int index) {
    return Dismissible(
      key: Key('alarm_${alarm.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => _deleteAlarm(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
         color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: alarm.isEnabled
                ? const Color(0xFFFFC107)
                : Colors.grey.shade300,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_formatAlarmTime(alarm.time),
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: alarm.isEnabled
                              ? const Color(0xFF3E2723)
                              : Colors.grey)),
                  const SizedBox(height: 4),
                  Text(alarm.label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        alarm.alarmType == "walk"
                            ? "🚶 Walk Challenge"
                            : (alarm.alarmType == "game" ? "🧠 Brain Game" : "🔔 Normal Alarm"),
                        style: TextStyle(
                            fontSize: 14,
                            color: alarm.isEnabled
                                ? Colors.black87
                                : Colors.grey),
                      ),
                      if (alarm.alarmType == "walk") ...[
                        const SizedBox(width: 6),
                        Text(
                          "(${alarm.stepTarget} steps)",
                          style: TextStyle(
                              fontSize: 12,
                              color: alarm.isEnabled
                                  ? const Color(0xFF5D4037)
                                  : Colors.grey),
                        ),
                      ]
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(_timeUntil(alarm.time),
                      style: TextStyle(
                          fontSize: 12,
                          color: alarm.isEnabled
                              ? const Color(0xFF5D4037)
                              : Colors.grey.shade400)),
                ],
              ),
            ),
            Switch(
              value: alarm.isEnabled,
              activeThumbColor: const Color(0xFFFFB300),
              onChanged: (_) async => await _toggleAlarm(index),
            ),
          ],
        ),
      ),
    );
  }
}

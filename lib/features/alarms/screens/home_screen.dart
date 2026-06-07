import 'dart:async';
import 'package:flutter/material.dart';
import '../models/alarm_model.dart';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/notification_settings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer _timer;
  DateTime _now = DateTime.now();
  final List<AlarmModel> _alarms = [];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _greeting {
    final hour = _now.hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    if (hour < 21) return 'Good Evening 🌇';
    return 'Good Night 🌙';
  }

  String get _subGreeting {
    final hour = _now.hour;
    if (hour < 12) return 'Wakey,wakey🌞';
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
    if (label == null) return;

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
      _alarms.add(AlarmModel(
        id: alarmId,
        label: label.isEmpty ? 'Alarm' : label,
        time: alarmTime,
        isEnabled: true,
        repeatDays: [],
      ));
      _alarms.sort((a, b) => a.time.compareTo(b.time));
    });

    final result = await Alarm.set(
      alarmSettings: AlarmSettings(
        id: alarmId,
        dateTime: alarmTime,
        assetAudioPath: 'assets/alarm.mp3',
        loopAudio: true,
        vibrate: true,
        androidFullScreenIntent: true,
        warningNotificationOnKill: true,
    notificationSettings: NotificationSettings(
      title: 'PineOClock 🍍',
      body: 'Your alarm is ringing! Tap to stop.',
      stopButton: 'Stop Alarm',
      icon: 'ic_launcher',
    ),
    ),
    );

    print('🍍🍍🍍 ALARM SET RESULT: $result 🍍🍍🍍');
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
      // Re-enable — reschedule the alarm
      await Alarm.set(
        alarmSettings: AlarmSettings(
          id: alarm.id,
          dateTime: alarm.time,
          assetAudioPath: 'assets/alarm.mp3',
          loopAudio: true,
          vibrate: true,
          androidFullScreenIntent: true,
          warningNotificationOnKill: true,
          notificationSettings: NotificationSettings(
            title: 'PineOClock 🍍',
            body: 'Your alarm is ringing! Tap to stop.',
            stopButton: 'Stop Alarm',
            icon: 'ic_launcher',
          ),
        ),
      );
    } else {
      // Disable — cancel the alarm
      await Alarm.stop(alarm.id);
    }

    setState(() {
      _alarms[index] = alarm.copyWith(isEnabled: newEnabled);
    });
  }

  void _deleteAlarm(int index) {
    setState(() => _alarms.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Alarm deleted'),
        backgroundColor: const Color(0xFFFFB300),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {},
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
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: const Text('Pine🍍Clock',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
            Text(_greeting,
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8DB600))),
            const SizedBox(height: 6),
            Text(_subGreeting,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            const SizedBox(height: 24),
            _buildClockCard(),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Alarms',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8DB600))),
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
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFFFB300), Color(0xFFFFD54F)]),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB300).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(_currentTime,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723),
                  letterSpacing: -1)),
          const SizedBox(height: 2),
          Text(
              '${_now.day}/${_now.month}/${_now.year} • ${_getDayName(_now.weekday)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF5D4037),
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text('No alarms yet!',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8DB600))),
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
        child: const Icon(Icons.delete_outline,
            color: Colors.white, size: 28),
      ),
      onDismissed: (_) => _deleteAlarm(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: alarm.isEnabled
              ? const Color(0xFFFFD54F)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: alarm.isEnabled
                ? const Color(0xFFFFB300).withValues(alpha: 0.4)
                : Colors.grey.shade200,
          ),
          boxShadow: alarm.isEnabled
              ? [
            BoxShadow(
              color: const Color(0xFFFFB300).withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
              : [],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_formatAlarmTime(alarm.time),
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: alarm.isEnabled
                              ? const Color(0xFF3E2723)
                              : Colors.grey)),
                  const SizedBox(height: 4),
                  Text(alarm.label,
                      style: TextStyle(
                          fontSize: 14,
                          color: alarm.isEnabled
                              ? Colors.black87
                              : Colors.grey)),
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
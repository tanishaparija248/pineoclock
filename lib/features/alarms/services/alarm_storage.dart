import 'package:hive_flutter/hive_flutter.dart';
import '../models/alarm_model.dart';
import 'package:flutter/foundation.dart';

class AlarmStorage {
  static const String _boxName = 'alarms_box';
  static List<AlarmModel> alarms = [];
  
  // To notify HomeScreen when an alarm is stopped from another screen
  static ValueNotifier<int> changeNotifier = ValueNotifier(0);

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
    loadAlarms();
  }

  static void loadAlarms() {
    final box = Hive.box(_boxName);
    final List<dynamic> rawAlarms = box.get('list', defaultValue: []);
    
    alarms = rawAlarms.map((item) {
      final map = Map<String, dynamic>.from(item);
      return AlarmModel(
        id: map['id'],
        label: map['label'],
        time: DateTime.parse(map['time']),
        isEnabled: map['isEnabled'],
        repeatDays: List<int>.from(map['repeatDays'] ?? []),
        alarmType: map['alarmType'] ?? 'normal',
        stepTarget: map['stepTarget'] ?? 50,
      );
    }).toList();
  }

  static Future<void> saveAlarms(List<AlarmModel> list) async {
    final box = Hive.box(_boxName);
    alarms = list;
    
    final rawList = alarms.map((a) => {
      'id': a.id,
      'label': a.label,
      'time': a.time.toIso8601String(),
      'isEnabled': a.isEnabled,
      'repeatDays': a.repeatDays,
      'alarmType': a.alarmType,
      'stepTarget': a.stepTarget,
    }).toList();
    
    await box.put('list', rawList);
    changeNotifier.value++; // Notify listeners
  }

  static Future<void> handleAlarmDismissed(int id) async {
    // Find the alarm and disable it in storage
    final index = alarms.indexWhere((a) => a.id == id);
    if (index != -1) {
      alarms[index] = alarms[index].copyWith(isEnabled: false);
      await saveAlarms(alarms);
    }
  }
}

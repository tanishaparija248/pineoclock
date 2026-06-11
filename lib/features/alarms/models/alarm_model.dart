class AlarmModel {
  final int id;
  final String label;
  final DateTime time;
  final bool isEnabled;
  final List<int> repeatDays;
  final String alarmType; // "normal", "walk", or "game"
  final int stepTarget;   // only used when alarmType == "walk"

  AlarmModel({
    required this.id,
    required this.label,
    required this.time,
    required this.isEnabled,
    required this.repeatDays,
    required this.alarmType,
    this.stepTarget = 50,
  });

  AlarmModel copyWith({
    int? id,
    String? label,
    DateTime? time,
    bool? isEnabled,
    List<int>? repeatDays,
    String? alarmType,
    int? stepTarget,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      label: label ?? this.label,
      time: time ?? this.time,
      isEnabled: isEnabled ?? this.isEnabled,
      repeatDays: repeatDays ?? this.repeatDays,
      alarmType: alarmType ?? this.alarmType,
      stepTarget: stepTarget ?? this.stepTarget,
    );
  }
}

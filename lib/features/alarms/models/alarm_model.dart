class AlarmModel {
  final int id;
  final String label;
  final DateTime time;
  final bool isEnabled;
  final List repeatDays;

  AlarmModel({
    required this.id,
    required this.label,
    required this.time,
    required this.isEnabled,
    required this.repeatDays,
});

  AlarmModel copyWith({
    int? id,
    String? label,
    DateTime? time,
    bool? isEnabled,
    List<int>? repeatDays,
}) {
    return AlarmModel(
      id: id ??this.id,
      label: label?? this.label,
      time: time?? this.time,
      isEnabled: isEnabled?? this.isEnabled,
      repeatDays: repeatDays?? this.repeatDays,
    );
  }
}
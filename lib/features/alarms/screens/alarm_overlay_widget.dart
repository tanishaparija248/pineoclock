import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:alarm/alarm.dart';
import '../services/alarm_storage.dart';

class AlarmOverlayWidget extends StatelessWidget {
  const AlarmOverlayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFB300), Color(0xFFFFD54F)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFB300).withOpacity(0.5), // ✅ fixed: withOpacity
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            const Text('🍍', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PineOClock',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  Text(
                    'Your alarm is ringing!',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                ],
              ),
            ),
            // Stop button
            GestureDetector(
              onTap: () async {
                // ✅ fixed: actually stop all ringing alarms before closing overlay
                for (final alarm in AlarmStorage.alarms) {
                  await Alarm.stop(alarm.id);
                }
                await FlutterOverlayWindow.closeOverlay();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3E2723),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Stop',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Snooze button
            GestureDetector(
              onTap: () async {
                await FlutterOverlayWindow.closeOverlay();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4), // ✅ fixed: withOpacity
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF3E2723),
                    width: 1,
                  ),
                ),
                child: const Text(
                  'Snooze',
                  style: TextStyle(
                    color: Color(0xFF3E2723),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
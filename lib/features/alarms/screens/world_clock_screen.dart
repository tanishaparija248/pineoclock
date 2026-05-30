import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/world_clock_model.dart';

class WorldClockScreen extends StatefulWidget {
  const WorldClockScreen({super.key});

  @override
  State<WorldClockScreen> createState() => _WorldClockScreenState();
}

class _WorldClockScreenState extends State<WorldClockScreen> {
  Timer? timer;

  final List<WorldClock> clocks = [
    WorldClock(
      city: 'New York',
      timezone: 'America/New_York',
    ),
    WorldClock(
      city: 'London',
      timezone: 'Europe/London',
    ),
    WorldClock(
      city: 'Tokyo',
      timezone: 'Asia/Tokyo',
    ),
  ];

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String getTime(String timezone) {
    final location = tz.getLocation(timezone);
    final now = tz.TZDateTime.now(location);

    return DateFormat('hh:mm a').format(now);
  }

  String getGMT(String timezone) {
    final location = tz.getLocation(timezone);
    final now = tz.TZDateTime.now(location);

    final offset = now.timeZoneOffset.inHours;

    if (offset >= 0) {
      return 'GMT +$offset';
    } else {
      return 'GMT $offset';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),

      appBar: AppBar(
        title: const Text('World Clock'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: clocks.length,
          itemBuilder: (context, index) {
            final clock = clocks[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),

              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: const Color(0xFFFFD54F),
                  borderRadius: BorderRadius.circular(16),
                ),

                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

                  children: [
                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [
                        Text(
                          clock.city,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          getGMT(clock.timezone),
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    Text(
                      getTime(clock.timezone),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_analog_clock/flutter_analog_clock.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/world_clock_model.dart';
import 'globe_screen.dart';

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

  final List<WorldClock> availableCities = [
    WorldClock(
      city: 'Paris',
      timezone: 'Europe/Paris',
    ),
    WorldClock(
      city: 'Dubai',
      timezone: 'Asia/Dubai',
    ),
    WorldClock(
      city: 'Singapore',
      timezone: 'Asia/Singapore',
    ),
    WorldClock(
      city: 'Sydney',
      timezone: 'Australia/Sydney',
    ),
    WorldClock(
      city: 'Moscow',
      timezone: 'Europe/Moscow',
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

    return DateFormat('hh:mm:ss a').format(now);
  }

  String getGMT(String timezone) {
    final location = tz.getLocation(timezone);
    final now = tz.TZDateTime.now(location);

    final offset = now.timeZoneOffset.inHours;

    if (offset >= 0) {
      return 'GMT +$offset';
    }

    return 'GMT $offset';
  }

  String getDayNight(String timezone) {
    final location = tz.getLocation(timezone);
    final now = tz.TZDateTime.now(location);

    return now.hour >= 6 && now.hour < 18
        ? '☀️ Day'
        : '🌙 Night';
  }

  String getFlag(String city) {
    switch (city) {
      case 'New York':
        return '🇺🇸';
      case 'London':
        return '🇬🇧';
      case 'Tokyo':
        return '🇯🇵';
      case 'Paris':
        return '🇫🇷';
      case 'Dubai':
        return '🇦🇪';
      case 'Singapore':
        return '🇸🇬';
      case 'Sydney':
        return '🇦🇺';
      case 'Moscow':
        return '🇷🇺';
      default:
        return '🌍';
    }
  }

  String getTimeDifference(String timezone) {
    final india =
    tz.TZDateTime.now(tz.getLocation('Asia/Kolkata'));

    final city =
    tz.TZDateTime.now(tz.getLocation(timezone));

    final difference =
        city.timeZoneOffset - india.timeZoneOffset;

    final hours = difference.inHours;
    final minutes =
        difference.inMinutes.abs() % 60;

    if (hours == 0 && minutes == 0) {
      return 'Same as India';
    }

    return difference.isNegative
        ? '${hours.abs()}h ${minutes}m behind'
        : '${hours.abs()}h ${minutes}m ahead';
  }

  void showAddCitySheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: availableCities.length,
          itemBuilder: (context, index) {
            final city = availableCities[index];

            return ListTile(
              title: Text(city.city),
              onTap: () {
                if (!clocks.any(
                      (c) => c.city == city.city,
                )) {
                  setState(() {
                    clocks.add(city);
                  });
                }

                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
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

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "globe",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const GlobeScreen(),
                ),
              );
            },
            child: const Icon(Icons.public),
          ),

          const SizedBox(height: 12),

          FloatingActionButton(
            heroTag: "add",
            onPressed: showAddCitySheet,
            child: const Icon(Icons.add),
          ),
        ],
      ),





      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD54F),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Text(
                    'India (Local Time)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Center(
                    child: SizedBox(
                      height: 150,
                      width: 150,
                      child: AnalogClock(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    DateFormat('hh:mm:ss a')
                        .format(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    DateFormat('EEEE, d MMM yyyy')
                        .format(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'GMT +5:30',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: clocks.length,
                itemBuilder: (context, index) {
                  final clock = clocks[index];

                  return Padding(
                    padding:
                    const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onLongPress: () async {
                        final remove =
                        await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title:
                            const Text('Remove City'),
                            content: Text(
                              'Remove ${clock.city} from World Clock?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(
                                      context,
                                      false,
                                    ),
                                child:
                                const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(
                                      context,
                                      true,
                                    ),
                                child:
                                const Text('Remove'),
                              ),
                            ],
                          ),
                        );

                        if (remove == true) {
                          setState(() {
                            clocks.removeAt(index);
                          });
                        }
                      },
                      child: Container(
                        padding:
                        const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                          const Color(0xFFFFD54F),
                          borderRadius:
                          BorderRadius.circular(
                            16,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${getFlag(clock.city)} ${clock.city}',
                                    style:
                                    const TextStyle(
                                      fontSize: 18,
                                      fontWeight:
                                      FontWeight
                                          .bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  getTime(
                                    clock.timezone,
                                  ),
                                  style:
                                  const TextStyle(
                                    fontSize: 20,
                                    fontWeight:
                                    FontWeight
                                        .bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            Row(
                              children: [
                                Text(
                                  getGMT(
                                    clock.timezone,
                                  ),
                                ),

                                const SizedBox(
                                  width: 12,
                                ),

                                Expanded(
                                  child: Text(
                                    '${getDayNight(clock.timezone)} • ${getTimeDifference(clock.timezone)}',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
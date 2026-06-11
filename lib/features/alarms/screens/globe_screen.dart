import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_earth_globe/flutter_earth_globe.dart';
import 'package:flutter_earth_globe/flutter_earth_globe_controller.dart';
import 'package:flutter_earth_globe/globe_coordinates.dart';
import 'package:flutter_earth_globe/point.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/world_clock_model.dart';

class GlobeScreen extends StatefulWidget {
  const GlobeScreen({super.key});

  @override
  State<GlobeScreen> createState() => _GlobeScreenState();
}

class _GlobeScreenState extends State<GlobeScreen> {
  late FlutterEarthGlobeController _controller;
  bool _isLoading = false;
  bool _isSurfaceLoaded = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _controller = FlutterEarthGlobeController(
      rotationSpeed: 0.1,
      zoom: 0.7,
      surface: const NetworkImage(
        'https://www.solarsystemscope.com/textures/download/2k_earth_daymap.jpg',
      ),
    );

    _controller.addListener(_onControllerUpdate);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.load();
        _controller.startRotation();
        _addCityMarkers();
      }
    });
  }

  void _addCityMarkers() {
    final cities = [
      {'id': 'ny', 'lat': 40.7128, 'lng': -74.0060, 'name': 'New York'},
      {'id': 'lon', 'lat': 51.5074, 'lng': -0.1278, 'name': 'London'},
      {'id': 'tok', 'lat': 35.6762, 'lng': 139.6503, 'name': 'Tokyo'},
      {'id': 'dub', 'lat': 25.2048, 'lng': 55.2708, 'name': 'Dubai'},
      {'id': 'del', 'lat': 28.6139, 'lng': 77.2090, 'name': 'New Delhi'},
      {'id': 'syd', 'lat': -33.8688, 'lng': 151.2093, 'name': 'Sydney'},
      {'id': 'par', 'lat': 48.8566, 'lng': 2.3522, 'name': 'Paris'},
      {'id': 'rio', 'lat': -22.9068, 'lng': -43.1729, 'name': 'Rio'},
      {'id': 'cai', 'lat': 30.0444, 'lng': 31.2357, 'name': 'Cairo'},
      {'id': 'mos', 'lat': 55.7558, 'lng': 37.6173, 'name': 'Moscow'},
      {'id': 'mum', 'lat': 19.0760, 'lng': 72.8777, 'name': 'Mumbai'},
      {'id': 'ber', 'lat': 52.5200, 'lng': 13.4050, 'name': 'Berlin'},
      {'id': 'cap', 'lat': -33.9249, 'lng': 18.4241, 'name': 'Cape Town'},
      {'id': 'sin', 'lat': 1.3521, 'lng': 103.8198, 'name': 'Singapore'},
    ];

    for (var city in cities) {
      _controller.addPoint(Point(
        id: city['id'] as String,
        coordinates: GlobeCoordinates(city['lat'] as double, city['lng'] as double),
        label: city['name'] as String,
        style: const PointStyle(color: Color(0xFFFFB300), size: 6),
        labelBuilder: (context, point, isHovering, isVisible) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFB300), width: 1),
            ),
            child: Text(
              point.label!,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          );
        },
      ));
    }
  }

  void _onControllerUpdate() {
    if (_controller.surface != null && !_isSurfaceLoaded) {
      if (mounted) setState(() => _isSurfaceLoaded = true);
    }
  }

  Future<void> _handleTap(GlobeCoordinates? coordinates) async {
    if (coordinates == null) return;
    setState(() => _isLoading = true);

    try {
      final geoResponse = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=${coordinates.latitude}&lon=${coordinates.longitude}&zoom=10'),
        headers: {'User-Agent': 'PineOClock_App'},
      ).timeout(const Duration(seconds: 5));

      if (geoResponse.statusCode == 200) {
        final geoData = json.decode(geoResponse.body);
        final address = geoData['address'] ?? {};
        final city = address['city'] ?? address['town'] ?? address['village'] ?? address['state'] ?? 'Selected Location';
        final country = address['country'] ?? '';
        
        if (mounted) {
          _showCityDetails(city, country, _findBestTimezoneMatch(coordinates.latitude, coordinates.longitude));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not find location details.')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _findBestTimezoneMatch(double lat, double lng) {
    if (lng > 68 && lng < 97 && lat > 8 && lat < 37) return 'Asia/Kolkata';
    if (lng > -125 && lng < -66 && lat > 24 && lat < 49) return 'America/New_York';
    if (lng > -10 && lng < 2 && lat > 50 && lat < 60) return 'Europe/London';
    if (lng > 130 && lng < 150 && lat > 30 && lat < 45) return 'Asia/Tokyo';
    if (lng > 2 && lng < 15 && lat > 42 && lat < 55) return 'Europe/Paris';
    if (lng > 113 && lng < 154 && lat > -44 && lat < -10) return 'Australia/Sydney';
    if (lng > 35 && lng < 40 && lat > 54 && lat < 56) return 'Europe/Moscow';
    if (lng > 54 && lng < 56 && lat > 24 && lat < 26) return 'Asia/Dubai';
    if (lng > 103 && lng < 105 && lat > 1 && lat < 2) return 'Asia/Singapore';
    return 'UTC';
  }

  void _showCityDetails(String city, String country, String timezone) {
    final location = tz.getLocation(timezone);
    final now = tz.TZDateTime.now(location);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFFFFF8E1),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(city, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            Text(country, style: const TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 20),
            Text(DateFormat('hh:mm a').format(now), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFFFFB300))),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB300),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, WorldClock(city: city, timezone: timezone));
              },
              child: const Text('Add to World Clock', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000511),
      appBar: AppBar(
        title: const Text('Interactive Globe', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                colors: [Color(0xFF1B263B), Color(0xFF000814)],
                radius: 1.2,
              ),
            ),
          ),
          
          Center(
            child: SizedBox(
              width: 380,
              height: 380,
              child: FlutterEarthGlobe(
                controller: _controller,
                radius: 150,
                onTap: _handleTap,
              ),
            ),
          ),

          if (!_isSurfaceLoaded)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Color(0xFFFFB300)),
                  const SizedBox(height: 20),
                  const Text("Building 3D World...", 
                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          
          if (_isLoading) 
            const Center(child: CircularProgressIndicator(color: Color(0xFFFFB300))),

          if (_isSurfaceLoaded)
            Positioned(
              bottom: 40, 
              left: 0, 
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white10, 
                    borderRadius: BorderRadius.circular(30), 
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app, color: Colors.white70, size: 20),
                      SizedBox(width: 10),
                      Text('Tap any city name to explore', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

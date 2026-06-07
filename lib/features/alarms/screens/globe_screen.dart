import 'package:flutter/material.dart';
import 'package:flutter_earth_globe/flutter_earth_globe.dart';
import 'package:flutter_earth_globe/flutter_earth_globe_controller.dart';

class GlobeScreen extends StatefulWidget {
  const GlobeScreen({super.key});

  @override
  State<GlobeScreen> createState() => _GlobeScreenState();
}

class _GlobeScreenState extends State<GlobeScreen> {
  late FlutterEarthGlobeController controller;

  @override
  void initState() {
    super.initState();
    controller = FlutterEarthGlobeController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: const Text("Choose City"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        color: const Color(0xFFFFF8E1),
        child: Center(
          child: SizedBox(
            width: 320,
            height: 320,
            child: FlutterEarthGlobe(
              radius: 150,
              controller: controller,
            ),
          ),
        ),
      ),
    );
  }
}
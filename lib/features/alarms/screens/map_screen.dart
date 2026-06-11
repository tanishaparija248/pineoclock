import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AddCityMapScreen extends StatelessWidget {
  const AddCityMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add City'),
      ),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(20.5937, 78.9629), // India
          initialZoom: 3,
        ),
        children: [
          TileLayer(
            urlTemplate:
            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.clock_app',
          ),
        ],
      ),
    );
  }
}
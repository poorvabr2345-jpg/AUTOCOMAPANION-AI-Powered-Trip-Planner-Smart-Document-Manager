import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class OfflineMapPage extends StatelessWidget {
  final double startLat;
  final double startLng;
  final List<Map<String, dynamic>> waypoints;

  const OfflineMapPage({
    super.key,
    required this.startLat,
    required this.startLng,
    required this.waypoints,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Offline Map")),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(startLat, startLng),
          zoom: 13,
        ),
        children: [
          PolylineLayer(
            polylines: [
              Polyline(
                points: waypoints
                    .map((p) => LatLng(p['lat'], p['lng']))
                    .toList(),
                strokeWidth: 4,
              ),
            ],
          ),
          MarkerLayer(
            markers: waypoints.map((p) {
              return Marker(
                point: LatLng(p['lat'], p['lng']),
                child: const Icon(Icons.location_on, color: Colors.red),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

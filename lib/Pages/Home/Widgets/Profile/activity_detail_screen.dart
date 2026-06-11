import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:runvix/export.dart';

class ActivityDetailScreen extends StatelessWidget {
  final WorkoutModel workout;

  const ActivityDetailScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    final List<LatLng> points = workout.route
        .map((e) => LatLng(e.latitude, e.longitude))
        .toList();

    debugPrint('🗺️ Route points count: ${workout.route.length}');
    debugPrint('🗺️ LatLng points count: ${points.length}');
    if (points.isNotEmpty) {
      debugPrint('🗺️ First point: ${points.first}');
      debugPrint('🗺️ Last point: ${points.last}');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('dd/MM/yyyy HH:mm').format(workout.timestamp)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Map Preview
            SizedBox(
              height: 300,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: points.isNotEmpty ? points.first : const LatLng(0, 0),
                  zoom: 17,
                ),
                polylines: {
                  Polyline(
                    polylineId: const PolylineId('route'),
                    points: points,
                    color: Colors.blue,
                    width: 5,
                  ),
                },
                onMapCreated: (controller) {
                  if (points.isNotEmpty) {
                    // Tính tâm route để camera nhìn vào giữa, không phải điểm đầu
                    LatLng center = _getCenter(points);
                    Future.delayed(const Duration(milliseconds: 300), () {
                      controller.animateCamera(
                        CameraUpdate.newLatLngZoom(center, 17),
                      );
                    });
                  }
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        "${(workout.distance / 1000).toStringAsFixed(2)}",
                        "km",
                      ),
                      _buildStatItem(
                        "${workout.duration ~/ 60}:${(workout.duration % 60).toString().padLeft(2, '0')}",
                        "thời gian",
                      ),
                      _buildStatItem(
                        "${workout.averagePace.toStringAsFixed(2)}",
                        "/km",
                      ),
                    ],
                  ),
                  const Divider(height: 40),
                  const ListTile(
                    leading: Icon(Icons.description_outlined),
                    title: Text("Mô tả"),
                    subtitle: Text("Không có mô tả cho hoạt động này."),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  LatLngBounds _getBounds(List<LatLng> points) {
    double south = points.first.latitude;
    double north = points.first.latitude;
    double west = points.first.longitude;
    double east = points.first.longitude;

    for (var p in points) {
      if (p.latitude < south) south = p.latitude;
      if (p.latitude > north) north = p.latitude;
      if (p.longitude < west) west = p.longitude;
      if (p.longitude > east) east = p.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(south, west),
      northeast: LatLng(north, east),
    );
  }
  LatLng _getCenter(List<LatLng> points) {
    LatLngBounds bounds = _getBounds(points);
    return LatLng(
      (bounds.southwest.latitude + bounds.northeast.latitude) / 2,
      (bounds.southwest.longitude + bounds.northeast.longitude) / 2,
    );
  }
  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.buttonColor,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}

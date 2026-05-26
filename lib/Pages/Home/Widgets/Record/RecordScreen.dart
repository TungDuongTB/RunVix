import 'package:flutter/material.dart';
import 'package:runvix/export.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  
  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    
    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RecordController());

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: _currentPosition == null
                ? const Center(child: CircularProgressIndicator())
                : Obx(() => GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(_currentPosition!.latitude,
                    _currentPosition!.longitude),
                zoom: 16,
              ),
              onMapCreated: (mapController) =>
              _mapController = mapController,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              polylines: {
                Polyline(
                  polylineId: const PolylineId('route'),
                  points: controller.polylinePoints.toList(),
                  color: AppColors.buttonColor,
                  width: 5,
                ),
              },
            )),
          ),

          // 2. Top UI: Badge Trends
          const RecordTopTrendsBadge(),

          // 3. Right UI: Floating Buttons
          const RecordFloatingButtons(),

          // 4. Bảng thông số Stats (GPS OK & Data)
          const RecordStatsCard(),

          // 5. Draggable Sheet (Controls & Settings)
          _buildDraggableSheet(),
        ],
      ),
    );
  }

  Widget _buildDraggableSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.2,
      minChildSize: 0.2,
      maxChildSize: 0.8,
      snap: true,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 12),
              Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2)))),
              const RecordControls(),
              const RecordAdvancedSettings(),
            ],
          ),
        );
      },
    );
  }
}

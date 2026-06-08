import 'package:runvix/export.dart';

class RecordScreen extends GetView<RecordController> {
  const RecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<RecordController>()) {
      Get.put(RecordController());
    }

    return Scaffold(
      body: Stack(
        children: [
          // 1. Lớp Bản đồ nền
          Positioned.fill(
            child: Obx(() {
              final pos = controller.currentPosition.value;
              final polylinesSet = controller.polylines;

              return GoogleMap(
                onMapCreated: controller.onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: pos != null
                      ? LatLng(pos.latitude, pos.longitude)
                      : const LatLng(21.0285, 105.8542),
                  zoom: 16.0,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapType: MapType.normal,
                polylines: polylinesSet,
                padding: const EdgeInsets.only(bottom: 150),
              );
            }),
          ),

          // 2. Overlay: Thông số chạy
          const RecordStatsCard(),

          // 3. Overlay: Nút chức năng bản đồ
          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height * 0.2,
            child: Column(
              children: [
                _buildMapButton(
                  icon: Icons.my_location,
                  onPressed: () {
                    if (controller.currentPosition.value != null) {
                      controller.mapController?.animateCamera(
                        CameraUpdate.newLatLng(
                          LatLng(
                            controller.currentPosition.value!.latitude,
                            controller.currentPosition.value!.longitude,
                          ),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),
                _buildMapButton(
                  icon: Icons.layers,
                  onPressed: () {
                    // Logic chọn loại bản đồ
                  },
                ),
              ],
            ),
          ),

          // 4. Overlay: Bảng điều khiển (Draggable Sheet)
          _buildDraggableSheet(),
        ],
      ),
    );
  }

  Widget _buildMapButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black87),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildDraggableSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.22,
      minChildSize: 0.22,
      maxChildSize: 0.85,
      snap: true,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
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
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const RecordControls(),
              const Divider(height: 1, indent: 20, endIndent: 20),
              const RecordAdvancedSettings(),
            ],
          ),
        );
      },
    );
  }
}

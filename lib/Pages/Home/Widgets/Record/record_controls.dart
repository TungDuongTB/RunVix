import 'package:flutter/material.dart';
import 'package:runvix/export.dart';

class RecordControls extends StatelessWidget {
  const RecordControls({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RecordController());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Obx(() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildModeButton(Icons.directions_run, 'Chạy bộ'),
          
          // Nút Start / Stop / Resume
          if (!controller.isRecording.value)
            _buildActionButton(
              icon: Icons.play_arrow_rounded,
              label: 'BẮT ĐẦU',
              onTap: () => controller.startRecording(),
              color: AppColors.buttonColor,
            )
          else ...[
            if (controller.isPaused.value)
              _buildActionButton(
                icon: Icons.play_arrow_rounded,
                label: 'TIẾP TỤC',
                onTap: () => controller.resumeRecording(),
                color: Colors.green,
              )
            else
              _buildActionButton(
                icon: Icons.pause_rounded,
                label: 'TẠM DỪNG',
                onTap: () => controller.pauseRecording(),
                color: Colors.orange,
              ),
            
            _buildActionButton(
              icon: Icons.stop_rounded,
              label: 'KẾT THÚC',
              onTap: () => _showStopConfirmation(context, controller),
              color: Colors.red,
            ),
          ],

          _buildRouteButton(Icons.add_location_alt_outlined, 'Thêm lộ trình'),
        ],
      )),
    );
  }

  void _showStopConfirmation(BuildContext context, RecordController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Kết thúc hoạt động?"),
        content: const Text("Bạn có chắc chắn muốn dừng và lưu hoạt động này không?"),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () {
              controller.stopRecording();
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Kết thúc", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap, required Color color}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5))
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 45),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildModeButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.orange.shade200, width: 2),
          ),
          child: Icon(icon, color: Colors.orange.shade900, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildRouteButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.black87, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

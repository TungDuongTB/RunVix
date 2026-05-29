import 'package:flutter/material.dart';
import 'package:runvix/export.dart';

class MapDistanceFilterSheet extends StatefulWidget {
  const MapDistanceFilterSheet({super.key});

  @override
  State<MapDistanceFilterSheet> createState() => _MapDistanceFilterSheetState();
}

class _MapDistanceFilterSheetState extends State<MapDistanceFilterSheet> {
  late double _currentValue;
  final controller = StravaController.instance;

  @override
  void initState() {
    super.initState();
    _currentValue = controller.selectedDistance.value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Độ dài',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Distance Preference Row
          Row(
            children: [
              const Text(
                'Độ dài ưa thích',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              const Icon(Icons.edit_outlined, color: Colors.black, size: 20),
              const SizedBox(width: 8),
              Text(
                _currentValue == 0 ? 'Bất kỳ' : '${_currentValue.round()} km+',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.lightBlue,
              inactiveTrackColor: Colors.grey[900],
              thumbColor: AppColors.buttonColor,
              overlayColor: Colors.black.withOpacity(0.1),
              trackHeight: 2,
            ),
            child: Slider(
              value: _currentValue,
              min: 0,
              max: 100,
              onChanged: (value) {
                setState(() {
                  _currentValue = value;
                });
              },
            ),
          ),
          const SizedBox(height: 32),
          
          // Bottom Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _currentValue = 0;
                  });
                },
                child: const Text(
                  'Đặt lại',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  controller.selectedDistance.value = _currentValue;
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Áp dụng',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:runvix/export.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Map Background Placeholder
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://i.stack.imgur.com/HILJv.png'), // Placeholder map image
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. Top Search & Filters
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.directions_run, color: Color(0xFFFF4500)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: const TextField(
                            decoration: InputDecoration(
                              hintText: 'Tìm kiếm vị trí',
                              prefixIcon: Icon(Icons.search),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.bookmark_border, size: 20),
                            SizedBox(width: 4),
                            Text('Đã lưu', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildFilterChip('Lộ trình', isSelected: true, hasDropdown: true),
                      _buildFilterChip('Độ dài'),
                      _buildFilterChip('Độ cao'),
                      _buildFilterChip('Bề mặt'),
                      _buildFilterChip('Khó khăn'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4500),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Tìm kiếm tại đây', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // 3. Floating Action Buttons (Right Side)
          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height * 0.3,
            child: Column(
              children: [
                _buildSideButton(const Text('B', style: TextStyle(fontWeight: FontWeight.bold))),
                const SizedBox(height: 12),
                Stack(
                  children: [
                    _buildSideButton(const Icon(Icons.layers_outlined)),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                        child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 8)),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                _buildSideButton(const Text('3D', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                const SizedBox(height: 12),
                _buildSideButton(const Icon(Icons.my_location)),
                const SizedBox(height: 12),
                _buildSideButton(const Icon(Icons.edit_outlined)),
              ],
            ),
          ),

          // 4. Bottom Info Card
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                    child: Image.network(
                      'https://via.placeholder.com/140x140',
                      width: 100,
                      height: 140,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Đường Di Trạch-Đường Di Ái',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('Dễ dàng', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  '6.40 km • 3 m • 0 giờ 43 phút',
                                  style: TextStyle(fontSize: 11, color: Colors.grey),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Row(
                            children: [
                              Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                              SizedBox(width: 4),
                              Text('Vị trí hiện tại', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Icon(Icons.auto_awesome, size: 14, color: Colors.orange.shade700),
                              const SizedBox(width: 4),
                              Text(
                                'Được thiết kế riêng cho bạn',
                                style: TextStyle(color: Colors.orange.shade700, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false, bool hasDropdown = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? const Color(0xFFFF4500) : Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFFF4500) : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (hasDropdown) ...[
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, size: 16, color: isSelected ? const Color(0xFFFF4500) : Colors.black),
          ]
        ],
      ),
    );
  }

  Widget _buildSideButton(Widget icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Center(child: icon),
    );
  }
}

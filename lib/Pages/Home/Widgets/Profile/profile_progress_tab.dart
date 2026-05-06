import 'package:flutter/material.dart';
import 'package:runvix/export.dart';

class ProfileProgressTab extends StatelessWidget {
  const ProfileProgressTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Nút chọn loại hoạt động
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.buttonColor.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.directions_run, size: 18, color: AppColors.buttonColor),
                  const SizedBox(width: 8),
                  const Text('Chạy bộ', style: TextStyle(color: AppColors.buttonColor, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Phần Tuần này
          _buildThisWeekSection(),
          
          const Divider(height: 40, thickness: 8, color: Color(0xFFF2F2F2)),
          
          // Phần Tháng 4 2026
          _buildMonthCalendarSection(),
          
          const SizedBox(height: 100), // Khoảng cách cuối trang
        ],
      ),
    );
  }

  Widget _buildThisWeekSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tuần này', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Quãng đường', '0 km'),
              _buildStatItem('Thời gian', '0phút'),
              _buildStatItem('Độ cao tăng', '0 m'),
            ],
          ),
          const SizedBox(height: 24),
          const Text('12 tuần qua', style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 16),
          // Giả lập biểu đồ
          SizedBox(
            height: 150,
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      // Các đường kẻ ngang
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(3, (index) => Divider(height: 1, color: Colors.grey.shade300)),
                      ),
                      // Đường biểu đồ (giả lập bằng một đường thẳng cam)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(12, (index) => Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.buttonColor, width: 2),
                            ),
                          )),
                        ),
                      ),
                      // Giá trị bên phải
                      Positioned(
                        right: 0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('0 km', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            SizedBox(height: 45),
                            Text('0 km', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            SizedBox(height: 45),
                            Text('0 km', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    Text('THG 2', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Text('THG 3', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Text('THG 4', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthCalendarSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tháng 4 2026', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.ios_share, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text('Chia sẻ', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildStatItem('Chuỗi liên tiếp của bạn', '0 Tuần', crossAxis: CrossAxisAlignment.start)),
              Expanded(child: _buildStatItem('Chuỗi hoạt động liên tiếp', '0', crossAxis: CrossAxisAlignment.start)),
            ],
          ),
          const SizedBox(height: 24),
          // Calendar Grid (Giả lập)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'].map((d) => Text(d, style: const TextStyle(color: Colors.grey, fontSize: 12))).toList(),
          ),
          const SizedBox(height: 16),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    // Giả lập lưới lịch
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: 21, // Hiển thị 3 hàng
      itemBuilder: (context, index) {
        int day = index + 1;
        bool isToday = day == 7;
        return Center(
          child: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: day < 1 ? Colors.transparent : (isToday ? Colors.transparent : Colors.grey.shade100),
              border: isToday ? Border.all(color: Colors.black, width: 1) : null,
            ),
            child: Center(
              child: Text(
                day < 1 ? '' : '$day',
                style: TextStyle(
                  color: day < 1 ? Colors.transparent : Colors.black,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, {CrossAxisAlignment crossAxis = CrossAxisAlignment.center}) {
    return Column(
      crossAxisAlignment: crossAxis,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

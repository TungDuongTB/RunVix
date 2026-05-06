import 'package:flutter/material.dart';
import 'package:runvix/export.dart';

class ClubTabContent extends StatelessWidget {
  const ClubTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image
          Image.network(
            'https://picsum.photos/id/10/600/300',
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
          
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tạo câu lạc bộ RunVix của\nriêng bạn',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, height: 1.2),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Mang đến cho cộng đồng của bạn một "điểm tựa" đầy động lực trên RunVix.',
                  style: TextStyle(color: Colors.black87, fontSize: 15),
                ),
                const SizedBox(height: 24),
                
                // Nút Bắt đầu
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Center(
                      child: Text(
                        'Bắt đầu',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Tìm hiểu thêm',
                    style: TextStyle(color: AppColors.buttonColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(thickness: 8, color: Color(0xFFF2F2F7)),
          
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Khám phá sự kiện địa phương',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tìm các buổi tập, sự kiện và câu lạc bộ gần bạn, rồi biến kế hoạch thành số dặm.',
                  style: TextStyle(color: Colors.black87, fontSize: 15),
                ),
                const SizedBox(height: 24),
                
                // Nút Tìm nhóm
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Center(
                      child: Text(
                        'Tìm nhóm của bạn',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

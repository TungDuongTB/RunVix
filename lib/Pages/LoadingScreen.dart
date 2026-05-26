import 'dart:async';
import 'package:flutter/material.dart';
import 'package:runvix/export.dart' hide Colors;

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _images = [
    'assets/Images/Runner.jpg',
    'assets/Images/bike.jpg',
    'assets/Images/Map.jpg',
    'assets/Images/Run.png',
  ];

  final List<String> _titles = [
    'Lấy động lực từ những người xung quanh bạn.',
    'Theo dõi hành trình luyện tập của bạn.',
    'Khám phá những cung đường mới.',
    'Bắt đầu chạy cùng RunVix ngay hôm nay!',
  ];

  final List<String> _subtitles = [
    'Kết nối với cộng đồng runner và chia sẻ những khoảnh khắc đặc biệt.',
    'Ghi lại mỗi bước chân, theo dõi tiến độ và đạt được mục tiêu của bạn.',
    'Tìm kiếm những tuyến đường mới, dễ, khó và thách thức.',
    'Tham gia cộng đồng RunVix ngay hôm nay và bắt đầu hành trình của bạn.',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack( // Sử dụng Stack để ảnh tràn toàn màn hình
        children: [
          // 1. Hình ảnh nền (PageView)
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _images.length,
            itemBuilder: (context, index) {
              return _buildCardSlide(index);
            },
          ),

          // 2. Các thành phần điều khiển (Dots và Buttons) nằm đè lên ảnh
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Indicators (dấu chấm)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _images.length,
                            (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: _currentPage == index
                                ? AppColors.buttonColor
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Hàng chứa các nút điều hướng
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Nút Quay lại
                        _currentPage > 0
                            ? GestureDetector(
                          onTap: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white24),
                            ),
                            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                          ),
                        )
                            : const SizedBox(width: 45),

                        // Nút Tiếp theo hoặc Bắt đầu
                        _currentPage < _images.length - 1
                            ? GestureDetector(
                          onTap: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: AppColors.buttonColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                          ),
                        )
                            : ButtonComponent(
                          height: 48,
                          width: 150,
                          borderRadius: 25,
                          textColor: AppColors.white,
                          color: AppColors.buttonColor,
                          text: 'Bắt đầu ngay',
                          textWeight: FontWeight.bold,
                          onPressed: () => Get.to(() => const Loginscreen()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardSlide(int index) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          _images[index],
          fit: BoxFit.fill,
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              stops: const [0.0, 0.5, 0.8],
              colors: [
                Colors.black.withOpacity(0.9),
                Colors.black.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),

        // Nội dung văn bản - Đẩy cao lên để không bị các nút che mất
        Positioned(
          bottom: 160, // Đẩy text lên trên khu vực nút bấm
          left: 24,
          right: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _titles[index],
                style: const TextStyle(
                  fontSize: 28, // Tăng kích thước chữ cho đẹp hơn trên nền full ảnh
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _subtitles[index],
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.85),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
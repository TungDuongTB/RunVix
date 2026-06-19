import 'package:runvix/Pages/Home/Widgets/Profile/profile_statistics_screen.dart';
import 'package:runvix/export.dart';

class ProfileDetailScreen extends StatelessWidget {
  const ProfileDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserController());
    final profileController = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: Colors.black),
            onPressed: () => _showLogoutConfirmDialog(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.buttonColor),
          );
        }

        final user = controller.user.value;
        return SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: user.profilePicture.isNotEmpty
                          ? NetworkImage(user.profilePicture)
                          : const AssetImage('assets/Images/user.png') as ImageProvider,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '@${user.username}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Stats Row (Followers, Following)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Obx(
                      () => Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.to(() => const FollowingListScreen()),
                        child: _buildFollowStat(
                          'Đang theo dõi',
                          controller.followingIds.length.toString(),
                        ),
                      ),
                      const SizedBox(width: 40),
                      GestureDetector(
                        onTap: () => Get.to(() => const FollowersListScreen()),
                        child: _buildFollowStat(
                          'Người theo dõi',
                          controller.followerIds.length.toString(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () => Get.snackbar(
                          'Thông báo',
                          'Chức năng đang được phát triển',
                        ),
                        icon: const Icon(Icons.qr_code_scanner, size: 18),
                        label: const Text(
                          'Chia sẻ mã QR của tôi',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.buttonColor,
                          side: BorderSide(
                            color: AppColors.buttonColor.withOpacity(0.5),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () => Get.to(() => const EditProfileScreen()),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text(
                          'Chỉnh sửa',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 40, thickness: 1, color: AppColors.dividerGrey),

              // Stats Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: const [
                              Icon(Icons.directions_run, size: 20),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Thống kê hoạt động',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Obx(() {
                          final current = profileController.selectedPeriod.value;
                          return Row(
                            children: [
                              _buildPeriodButton('Tuần', 'week', current == 'week', profileController),
                              const SizedBox(width: 4),
                              _buildPeriodButton('Tháng', 'month', current == 'month', profileController),
                              const SizedBox(width: 4),
                              _buildPeriodButton('Năm', 'year', current == 'year', profileController),
                            ],
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      final distanceKm = (profileController.periodDistance.value / 1000).toStringAsFixed(2);
                      final totalDurationSecs = profileController.periodDuration.value;
                      final hours = totalDurationSecs ~/ 3600;
                      final minutes = (totalDurationSecs % 3600) ~/ 60;
                      String timeStr = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
                      final count = profileController.periodWorkoutCount.value.toString();

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildMiniStat('Quãng đường', '$distanceKm km'),
                          _buildMiniStat('Thời gian', timeStr),
                          _buildMiniStat('Hoạt động', count),
                        ],
                      );
                    }),
                    const SizedBox(height: 24),
                    _buildDynamicBarChart(profileController),
                  ],
                ),
              ),

              const Divider(height: 40, thickness: 1, color: AppColors.dividerGrey),

              _buildListOption(Icons.grid_view, 'Hoạt động'),
              ListTile(
                leading: const Icon(Icons.bar_chart, color: Colors.black87, size: 24),
                title: const Text('Số liệu thống kê', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onTap: () => Get.to(() => const ProfileStatisticsScreen()),
              ),
              ListTile(
                leading: const Icon(Icons.email_outlined, color: Colors.black87, size: 24),
                title: const Text('Thay đổi email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onTap: () => _showChangeEmailDialog(context),
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline, color: Colors.black87, size: 24),
                title: const Text('Đổi mật khẩu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => const ChangePasswordDialog(),
                  );
                },
              ),

              const Divider(height: 40, thickness: 8, color: AppColors.dividerGrey),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tủ trưng bày thành tích', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildAchievementIcon('Hoạt động\nđầu tiên'),
                        _buildAchievementIcon('Hoạt động\nthứ 3'),
                        _buildAchievementIcon('Hoạt động\nthứ 5'),
                        _buildAchievementIcon('Hoạt động\nthứ 10'),
                      ],
                    ),
                  ],
                ),
              ),
              _buildListOption(null, 'Tất cả cúp thành tích', isSmall: true),
              const SizedBox(height: 60),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFollowStat(String label, String count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(count, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPeriodButton(String text, String period, bool isSelected, ProfileController controller) {
    return GestureDetector(
      onTap: () => controller.changePeriod(period),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.buttonColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDynamicBarChart(ProfileController controller) {
    return Obx(() {
      final data = controller.chartData;
      final labels = controller.chartLabels;

      if (data.isEmpty) {
        return const SizedBox(height: 150, child: Center(child: Text('Không có dữ liệu thống kê', style: TextStyle(color: Colors.grey))));
      }

      double maxVal = data.reduce((a, b) => a > b ? a : b);
      if (maxVal == 0) maxVal = 1.0;

      return Container(
        height: 180,
        width: double.infinity,
        padding: const EdgeInsets.only(top: 20),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(
                  height: 120,
                  width: data.length * 50.0,
                  child: CustomPaint(
                    painter: LineChartPainter(data: data, maxVal: maxVal, color: AppColors.buttonColor),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: data.length * 50.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(labels.length, (index) {
                      return SizedBox(width: 50, child: Center(child: Text(labels[index], style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w500))));
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildListOption(IconData? icon, String title, {String subtitle = '—', bool isSmall = false}) {
    return ListTile(
      leading: icon != null
          ? Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: Colors.black87, size: 24),
            )
          : null,
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isSmall ? 15 : 16)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () => Get.snackbar('Thông báo', 'Chức năng đang được phát triển'),
    );
  }

  Widget _buildAchievementIcon(String label) {
    return Column(
      children: [
        Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(color: Colors.grey.shade50, shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200, width: 1)),
          child: Center(child: Icon(Icons.lock_outline, color: Colors.grey.shade400, size: 20)),
        ),
        const SizedBox(height: 12),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, height: 1.2)),
      ],
    );
  }

  void _showChangeEmailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ChangeEmailDialog(),
    );
  }



  void _showLogoutConfirmDialog(BuildContext context) {
    Get.defaultDialog(
      title: 'Đăng xuất',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      content: const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text('Bạn có chắc chắn muốn đăng xuất không?', style: TextStyle(fontSize: 15)),
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        onPressed: () async {
          Get.back();
          await AuthenticationRepository.instance.logout();
          Get.snackbar(
            'Thành công',
            'Đăng xuất thành công!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        child: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Hủy'),
      ),
      radius: 12,
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<double> data;
  final double maxVal;
  final Color color;

  LineChartPainter({required this.data, required this.maxVal, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double stepX = size.width / (data.length > 1 ? data.length - 1 : 1);
    final List<Offset> points = [];

    for (int i = 0; i < data.length; i++) {
      points.add(Offset(i * stepX, size.height - (data[i] / maxVal * size.height)));
    }

    final Path linePath = Path();
    linePath.moveTo(points[0].dx, points[0].dy);

    if (points.length > 1) {
      for (int i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
        final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
        linePath.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, p1.dx, p1.dy);
      }
    }

    final Path areaPath = Path.from(linePath);
    areaPath.lineTo(points.last.dx, size.height);
    areaPath.lineTo(points[0].dx, size.height);
    areaPath.close();

    final Paint areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.25), color.withOpacity(0.005)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(areaPath, areaPaint);

    final Paint linePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);

    final Paint dotPaint = Paint()..color = Colors.white;
    final Paint dotOutlinePaint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.5;

    for (int i = 0; i < points.length; i++) {
      if (data[i] > 0) {
        final TextPainter tp = TextPainter(
          text: TextSpan(text: data[i].toStringAsFixed(1), style: TextStyle(color: color, fontSize: 8.5, fontWeight: FontWeight.bold)),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(points[i].dx - tp.width / 2, points[i].dy - 16));
      }
      canvas.drawCircle(points[i], 4, dotPaint);
      canvas.drawCircle(points[i], 4, dotOutlinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

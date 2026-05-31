import '../Model/admin_stats_model.dart';

class AdminRepository {
  Future<AdminStatsModel> getAdminStats() async {
    // Giả lập độ trễ mạng
    await Future.delayed(const Duration(milliseconds: 800));

    return AdminStatsModel(
      totalUsers: 1542,
      activityGrowth: "+18.5%",
      activeChallenges: 24,
      violationReports: 5,
      performanceData: [
        ChartData("Thứ 2", 40),
        ChartData("Thứ 3", 55),
        ChartData("Thứ 4", 45),
        ChartData("Thứ 5", 80),
        ChartData("Thứ 6", 65),
        ChartData("Thứ 7", 95),
        ChartData("Chủ nhật", 110),
      ],
      recentActivities: [
        CoordinationTask(coordinatorName: "Lê Quốc Anh", taskName: "Duyệt thử thách 'Hà Nội Run'", status: "Hoàn thành"),
        CoordinationTask(coordinatorName: "Phạm Hải Yến", taskName: "Xử lý báo cáo bài viết #882", status: "Đang xử lý"),
        CoordinationTask(coordinatorName: "Trần Minh Nam", taskName: "Kiểm tra tuyến đường Hồ Tây", status: "Đang xử lý"),
        CoordinationTask(coordinatorName: "Admin Hệ thống", taskName: "Bảo trì dữ liệu tháng 10", status: "Hoàn thành"),
      ],
      activityDistribution: {
        "Chạy bộ": 0.65,
        "Đạp xe": 0.25,
        "Đi bộ": 0.1,
      },
    );
  }
}

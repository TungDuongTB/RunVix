class GroupWorkoutStats {
  final double totalDistanceMeters;
  final double averagePace;

  GroupWorkoutStats({
    required this.totalDistanceMeters,
    required this.averagePace,
  });

  /// Trả về đối tượng trống khi không có dữ liệu
  factory GroupWorkoutStats.empty() {
    return GroupWorkoutStats(
      totalDistanceMeters: 0.0,
      averagePace: 0.0,
    );
  }

  /// Chuyển đổi mét sang kilomet để hiển thị
  double get totalDistanceKm => totalDistanceMeters / 1000;

  /// Định dạng quãng đường để hiển thị (ví dụ: 15.5 km)
  String get formattedTotalDistance {
    return totalDistanceKm.toStringAsFixed(1);
  }

  /// Định dạng pace để hiển thị (ví dụ: 5.5 -> 5:30)
  String get formattedAveragePace {
    if (averagePace <= 0 || averagePace.isInfinite || averagePace.isNaN) return "00:00";

    int minutes = averagePace.floor();
    int seconds = ((averagePace - minutes) * 60).round();

    // Xử lý trường hợp seconds làm tròn lên 60
    if (seconds == 60) {
      minutes++;
      seconds = 0;
    }

    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }
}

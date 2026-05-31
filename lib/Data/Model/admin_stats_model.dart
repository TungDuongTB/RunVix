class AdminStatsModel {
  final int totalUsers;
  final String activityGrowth;
  final int activeChallenges;
  final int violationReports;
  final List<ChartData> performanceData;
  final List<CoordinationTask> recentActivities;
  final Map<String, double> activityDistribution;

  AdminStatsModel({
    required this.totalUsers,
    required this.activityGrowth,
    required this.activeChallenges,
    required this.violationReports,
    required this.performanceData,
    required this.recentActivities,
    required this.activityDistribution,
  });
}

class ChartData {
  final String label;
  final double value;
  ChartData(this.label, this.value);
}

class CoordinationTask {
  final String coordinatorName;
  final String taskName;
  final String status;

  CoordinationTask({
    required this.coordinatorName,
    required this.taskName,
    required this.status,
  });
}

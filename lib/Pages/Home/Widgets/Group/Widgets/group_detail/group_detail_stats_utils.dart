class GroupDetailStats {
  GroupDetailStats._();

  static String memberSubtitle(int memberCount) {
    if (memberCount == 0) return 'Chưa có thành viên';
    return '$memberCount người';
  }
}

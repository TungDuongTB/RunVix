class GroupRequirementUtils {
  /// Chuyển đổi dữ liệu từ Firestore sang double an toàn
  static double? parseStoredDouble(dynamic value) {
    if (value == null || value == '') return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Chuyển đổi dữ liệu từ Firestore sang int an toàn
  static int? parseStoredInt(dynamic value) {
    if (value == null || value == '') return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

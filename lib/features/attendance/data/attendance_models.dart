class AttendanceLogItem {
  const AttendanceLogItem({
    required this.id,
    required this.createdAt,
    required this.status,
  });

  final String id;
  final DateTime? createdAt;
  final String status;
}

class AttendanceCheckInResult {
  const AttendanceCheckInResult({
    required this.raw,
    required this.summary,
  });

  final Map<String, dynamic> raw;
  final String summary;
}

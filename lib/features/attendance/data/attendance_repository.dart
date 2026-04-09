import 'package:uyoung_app/features/attendance/data/attendance_models.dart';
import 'package:uyoung_app/features/attendance/data/attendance_service.dart';

class AttendanceRepository {
  const AttendanceRepository(this.service);

  final AttendanceService service;

  Future<List<AttendanceLogItem>> fetchLogs() async {
    final rows = await service.fetchAttendanceLogs();

    return rows.map(_mapLogItem).toList();
  }

  Future<AttendanceCheckInResult> runCheckIn() async {
    final raw = await service.runDailyCheckInAndDraw();

    return AttendanceCheckInResult(
      raw: raw,
      summary: _buildSummary(raw),
    );
  }

  AttendanceLogItem _mapLogItem(Map<String, dynamic> row) {
    return AttendanceLogItem(
      id: (row['id'] ?? '').toString(),
      createdAt: DateTime.tryParse((row['created_at'] ?? '').toString()),
      status: (row['status'] ?? row['attendance_status'] ?? 'unknown')
          .toString(),
    );
  }

  String _buildSummary(Map<String, dynamic> raw) {
    final message = raw['message']?.toString();
    if (message != null && message.isNotEmpty) {
      return message;
    }

    final reward = raw['reward_name']?.toString() ?? raw['reward']?.toString();
    if (reward != null && reward.isNotEmpty) {
      return '보상 결과: $reward';
    }

    final status = raw['status']?.toString();
    if (status != null && status.isNotEmpty) {
      return '출석 처리 상태: $status';
    }

    return '출석 결과가 도착했습니다.';
  }
}

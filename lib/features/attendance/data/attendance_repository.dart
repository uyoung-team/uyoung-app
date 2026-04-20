import 'attendance_models.dart';
import 'attendance_service.dart';

class AttendanceRepository {
  AttendanceRepository({AttendanceService? service})
    : _service = service ?? const AttendanceService();

  final AttendanceService _service;

  Future<AttendanceResult> checkInAndDraw() async {
    try {
      return await _service.checkInAndDraw();
    } catch (error) {
      throw StateError('출석 체크에 실패했어요. $error');
    }
  }

  Future<int> fetchPearlCount() async {
    try {
      return await _service.fetchPearlCount();
    } catch (error) {
      throw StateError('진주 개수를 불러오지 못했어요. $error');
    }
  }

  Future<List<AttendanceLogEntry>> fetchAttendanceLogs() async {
    try {
      return await _service.fetchAttendanceLogs();
    } catch (error) {
      throw StateError('출석 보드를 불러오지 못했어요. $error');
    }
  }
}

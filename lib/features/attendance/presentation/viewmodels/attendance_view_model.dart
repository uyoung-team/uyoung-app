import 'package:flutter/foundation.dart';
import 'package:uyoung_app/features/attendance/data/attendance_models.dart';
import 'package:uyoung_app/features/attendance/data/attendance_repository.dart';

class AttendanceViewModel extends ChangeNotifier {
  AttendanceViewModel(this.repository);

  final AttendanceRepository repository;

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  AttendanceCheckInResult? _lastResult;
  List<AttendanceLogItem> _logs = const [];

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  AttendanceCheckInResult? get lastResult => _lastResult;
  List<AttendanceLogItem> get logs => _logs;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _logs = await repository.fetchLogs();
    } catch (_) {
      _errorMessage = '출석 로그를 불러오지 못했습니다.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> runCheckIn() async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _lastResult = await repository.runCheckIn();
      _logs = await repository.fetchLogs();
    } catch (_) {
      _errorMessage = '출석 처리 중 문제가 발생했습니다.';
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:uyoung_app/features/attendance/data/attendance_models.dart';
import 'package:uyoung_app/features/attendance/data/attendance_repository.dart';
import 'package:uyoung_app/shared/services/asset_paths.dart';

class AttendanceViewModel extends ChangeNotifier {
  AttendanceViewModel({AttendanceRepository? repository})
    : _repository = repository ?? AttendanceRepository();

  final AttendanceRepository _repository;

  AttendanceResult? _result;
  AttendanceFlowStep _step = AttendanceFlowStep.idle;
  String? _errorMessage;
  int _pearlCount = 0;
  List<AttendanceLogEntry> _logs = const [];
  bool _hasCheckedToday = false;

  AttendanceResult? get result => _result;
  AttendanceFlowStep get step => _step;
  bool get isLoading => _step == AttendanceFlowStep.loading;
  String? get errorMessage => _errorMessage;
  int get pearlCount => _pearlCount;
  List<AttendanceLogEntry> get logs => List.unmodifiable(_logs);
  bool get hasCheckedToday => _hasCheckedToday;

  bool get hasResult => _result != null;
  bool get isAlreadyChecked => _result?.isAlreadyChecked == true;
  int get streak => _result?.streak ?? _logs.length;
  int get checkedDays => _logs.length.clamp(0, 7);
  int get currentDay {
    if (_hasCheckedToday && checkedDays > 0) {
      return checkedDays.clamp(1, 7);
    }
    return (checkedDays + 1).clamp(1, 7);
  }

  bool get isRevealStep => _step == AttendanceFlowStep.reveal;

  AttendanceRewardKind get rewardKind {
    if (_result == null) {
      return AttendanceRewardKind.pearl;
    }

    final normalized = rewardLabel;
    if (_result!.isWin || normalized.contains('진주')) {
      return AttendanceRewardKind.pearl;
    }
    return AttendanceRewardKind.trash;
  }

  String get rewardLabel {
    final raw = (_result?.rewardLabel ?? '').replaceAll('등장!', '');
    return raw.replaceAll('등장', '').trim();
  }

  String get resultTitle =>
      rewardKind == AttendanceRewardKind.pearl ? '진주 등장!' : '바다쓰레기 등장!';

  String get resultBody {
    if (rewardKind == AttendanceRewardKind.pearl) {
      return '오늘은 해달이 진주를 들고 왔네요 :)\n내일도 출석체크 때 만나요 !';
    }
    return '오늘은 해달이 바다 쓰레기를 들고 왔네요 :(\n아쉽지만 내일 출석체크 때 만나요 !';
  }

  String get rewardImagePath {
    if (rewardKind == AttendanceRewardKind.pearl) {
      return AssetPaths.images.attendance.itemPearl;
    }
    final normalized = rewardLabel;
    if (normalized.contains('타이어')) {
      return AssetPaths.images.attendance.itemTrash02;
    }
    return AssetPaths.images.attendance.itemTrash01;
  }

  String get boardItemSummary => '오늘도 출석완료!\n아이템 확인해주세요';

  String get boardSubSummary => '연속 출석체크 스타트!';

  String get revealTitleTop => '어! 심해에서';

  String get revealTitleBottom => '해달이 무언갈 주웠나봐요,';

  Future<AttendanceFlowStep> checkIn() async {
    if (isLoading) {
      return _step;
    }

    _step = AttendanceFlowStep.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.checkInAndDraw();
      _result = result;

      if (result.isSuccess || result.isAlreadyChecked) {
        _pearlCount = await _repository.fetchPearlCount();
        _logs = await _repository.fetchAttendanceLogs();
        _hasCheckedToday = true;
      }

      if (result.isSuccess) {
        _step = AttendanceFlowStep.reveal;
      } else if (result.isAlreadyChecked) {
        _step = AttendanceFlowStep.board;
      } else {
        _step = AttendanceFlowStep.idle;
      }
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('StateError: ', '');
      _step = AttendanceFlowStep.idle;
    } finally {
      notifyListeners();
    }

    return _step;
  }

  Future<void> loadBoardData() async {
    try {
      _logs = await _repository.fetchAttendanceLogs();
      _pearlCount = await _repository.fetchPearlCount();
      _hasCheckedToday = _logs.isNotEmpty;
      notifyListeners();
    } catch (_) {
      // Entry/board UI should still render even if board history fails to load.
    }
  }

  void showResult() {
    _step = AttendanceFlowStep.result;
    notifyListeners();
  }

  void showBoard() {
    _step = AttendanceFlowStep.board;
    notifyListeners();
  }

  String entryBoardItemPath(int day) {
    if (day <= checkedDays) {
      return boardItemPathForDay(day);
    }
    return AssetPaths.images.attendance.itemSecret;
  }

  String boardItemPathForDay(int day) {
    if (day > checkedDays) {
      return AssetPaths.images.attendance.itemSecret;
    }

    final index = day - 1;
    if (index < 0 || index >= _logs.length) {
      return AssetPaths.images.attendance.itemSecret;
    }

    return _mapRewardItemToPath(
      rewardItem: _logs[index].rewardItem,
      day: day,
    );
  }

  String _mapRewardItemToPath({
    required String rewardItem,
    required int day,
  }) {
    if (day == 7) {
      return AssetPaths.images.attendance.itemPearlBundle;
    }

    final normalized = rewardItem.trim();
    if (normalized.contains('진주')) {
      return AssetPaths.images.attendance.itemPearl;
    }
    if (normalized.contains('타이어')) {
      return AssetPaths.images.attendance.itemTrash02;
    }
    if (normalized.contains('바다쓰레기') ||
        normalized.contains('부츠') ||
        normalized.contains('장화')) {
      return AssetPaths.images.attendance.itemTrash01;
    }
    return AssetPaths.images.attendance.itemSecret;
  }
}

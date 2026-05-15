import 'package:flutter/foundation.dart';
import 'package:uyoung_app/features/memory/data/memory_models.dart';
import 'package:uyoung_app/features/memory/data/memory_repository.dart';

class InviteIslandViewModel extends ChangeNotifier {
  InviteIslandViewModel({
    required this.inviteCode,
    required this.repository,
  });

  final String inviteCode;
  final MemoryRepository repository;

  IslandInviteDetail? detail;
  bool isLoading = false;
  bool isJoining = false;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      detail = await repository.fetchIslandInviteDetail(inviteCode);
      if (detail == null) {
        errorMessage = '유효하지 않은 초대 링크예요.';
      }
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<IslandInviteDetail> join() async {
    isJoining = true;
    errorMessage = null;
    notifyListeners();

    try {
      final joined = await repository.joinIslandByInviteCode(inviteCode);
      detail = joined;
      return joined;
    } catch (error) {
      errorMessage = error.toString();
      rethrow;
    } finally {
      isJoining = false;
      notifyListeners();
    }
  }
}

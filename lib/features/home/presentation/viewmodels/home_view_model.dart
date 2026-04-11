import 'package:flutter/foundation.dart';
import 'package:uyoung_app/features/home/data/home_models.dart';
import 'package:uyoung_app/features/home/data/home_repository.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this.repository);

  final HomeRepository repository;

  int _pearlCount = 0;
  List<HomeNotification> _notifications = const [];
  bool _isLoading = false;
  bool _isMarkingAll = false;
  String? _errorText;

  int get pearlCount => _pearlCount;
  bool get isLoading => _isLoading;
  bool get isMarkingAll => _isMarkingAll;
  String? get errorText => _errorText;
  String get pearlCountLabel => '$_pearlCount개';
  List<HomeNotification> get notifications => List.unmodifiable(_notifications);
  bool get hasUnread => _notifications.any((item) => !item.isRead);

  Future<void> load() async {
    _isLoading = true;
    _errorText = null;
    notifyListeners();

    try {
      final results = await Future.wait<dynamic>([
        repository.fetchPearlCount(),
        repository.fetchNotifications(),
      ]);

      _pearlCount = results[0] as int;
      _notifications = results[1] as List<HomeNotification>;
    } catch (error) {
      _errorText = error.toString();
      _pearlCount = 0;
      _notifications = const [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((item) => item.id == notificationId);
    if (index < 0 || _notifications[index].isRead) {
      return;
    }

    final original = _notifications[index];
    _notifications = List<HomeNotification>.from(_notifications)
      ..[index] = original.copyWith(isRead: true);
    notifyListeners();

    try {
      await repository.markNotificationAsRead(notificationId);
    } catch (error) {
      _notifications = List<HomeNotification>.from(_notifications)
        ..[index] = original;
      _errorText = error.toString();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    if (_isMarkingAll || !hasUnread) {
      return;
    }

    _isMarkingAll = true;
    _errorText = null;
    notifyListeners();

    final previous = _notifications;
    _notifications = _notifications
        .map((item) => item.isRead ? item : item.copyWith(isRead: true))
        .toList();
    notifyListeners();

    try {
      await repository.markAllNotificationsAsRead();
    } catch (error) {
      _notifications = previous;
      _errorText = error.toString();
    } finally {
      _isMarkingAll = false;
      notifyListeners();
    }
  }

  String formatTimeAgo(DateTime? createdAt) {
    if (createdAt == null) {
      return '';
    }

    final difference = DateTime.now().difference(createdAt);
    if (difference.inMinutes < 1) {
      return '방금 전';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    }
    return '${difference.inDays}일 전';
  }
}

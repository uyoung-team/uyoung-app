import 'package:uyoung_app/features/home/data/home_models.dart';
import 'package:uyoung_app/features/home/data/home_service.dart';

class HomeRepository {
  const HomeRepository(this.service);

  final HomeService service;

  Future<int> fetchPearlCount() async {
    try {
      return await service.fetchPearlCount();
    } catch (error) {
      throw StateError('진주 정보를 불러오지 못했어요. $error');
    }
  }

  Future<List<HomeNotification>> fetchNotifications() async {
    try {
      return await service.fetchNotifications();
    } catch (error) {
      throw StateError('알림을 불러오지 못했어요. $error');
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await service.markNotificationAsRead(notificationId);
    } catch (error) {
      throw StateError('알림을 읽음 처리하지 못했어요. $error');
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      await service.markAllNotificationsAsRead();
    } catch (error) {
      throw StateError('알림 전체 읽음 처리에 실패했어요. $error');
    }
  }
}

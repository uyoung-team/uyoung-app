import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/features/calendar/data/calendar_models.dart';

class CalendarDummyData {
  const CalendarDummyData._();

  static final List<CalendarIslandFilter> islandFilters = [
    CalendarIslandFilter(
      id: 'dummy-japan',
      name: '일본팸',
      color: AppColors.b01,
      isSelected: true,
      alertEnabled: true,
    ),
    CalendarIslandFilter(
      id: 'dummy-shangkong',
      name: '상콩즈',
      color: AppColors.subYellow01,
      isSelected: true,
      alertEnabled: true,
    ),
    CalendarIslandFilter(
      id: 'dummy-dolphin',
      name: '돌핀즈',
      color: AppColors.subGreen01,
      isSelected: true,
      alertEnabled: true,
    ),
    CalendarIslandFilter(
      id: 'dummy-couple',
      name: '커플',
      color: AppColors.subRed04,
      isSelected: true,
      alertEnabled: true,
    ),
    CalendarIslandFilter(
      id: 'dummy-europe',
      name: '유럽팸',
      color: AppColors.subPurple02,
      isSelected: true,
      alertEnabled: true,
    ),
  ];

  static List<CalendarEvent> memoriesForMonth(DateTime month) {
    final y = month.year;
    final m = month.month;

    return [
      CalendarEvent(
        id: 'jp-1',
        islandId: 'dummy-japan',
        title: '도쿄 첫날',
        date: DateTime(y, m, 5),
        imageUrl: 'assets/images/memory/japan/tokyo1.png',
      ),
      CalendarEvent(
        id: 'jp-2',
        islandId: 'dummy-japan',
        title: '도쿄 둘째날',
        date: DateTime(y, m, 5),
        imageUrl: 'assets/images/memory/japan/tokyo10.png',
      ),
      CalendarEvent(
        id: 'jp-3',
        islandId: 'dummy-japan',
        title: '삿포로',
        date: DateTime(y, m, 6),
        imageUrl: 'assets/images/memory/japan/Sapporo5.png',
      ),
      CalendarEvent(
        id: 'jp-4',
        islandId: 'dummy-japan',
        title: '후쿠오카',
        date: DateTime(y, m, 7),
        imageUrl: 'assets/images/memory/japan/hukuoka4.png',
      ),
      CalendarEvent(
        id: 'jp-5',
        islandId: 'dummy-japan',
        title: '도쿄 단체샷',
        date: DateTime(y, m, 7),
        imageUrl: 'assets/images/memory/japan/tokyo21.png',
      ),
      CalendarEvent(
        id: 'sh-1',
        islandId: 'dummy-shangkong',
        title: '상콩즈 첫날',
        date: DateTime(y, m, 11),
        imageUrl: 'assets/images/memory/shangkong/pic1.jpeg',
      ),
      CalendarEvent(
        id: 'sh-2',
        islandId: 'dummy-shangkong',
        title: '홍콩 야경',
        date: DateTime(y, m, 11),
        imageUrl: 'assets/images/memory/shangkong/hongkong7.jpeg',
      ),
      CalendarEvent(
        id: 'sh-3',
        islandId: 'dummy-shangkong',
        title: '상하이',
        date: DateTime(y, m, 12),
        imageUrl: 'assets/images/memory/shangkong/shanghi4.jpeg',
      ),
      CalendarEvent(
        id: 'sh-4',
        islandId: 'dummy-shangkong',
        title: '홍콩',
        date: DateTime(y, m, 13),
        imageUrl: 'assets/images/memory/shangkong/hongkong24.jpeg',
      ),
      CalendarEvent(
        id: 'dp-1',
        islandId: 'dummy-dolphin',
        title: '괌',
        date: DateTime(y, m, 16),
        imageUrl: 'assets/images/memory/dolphin/guam1.jpeg',
      ),
      CalendarEvent(
        id: 'dp-2',
        islandId: 'dummy-dolphin',
        title: '베트남',
        date: DateTime(y, m, 16),
        imageUrl: 'assets/images/memory/dolphin/vietnam1.jpeg',
      ),
      CalendarEvent(
        id: 'cp-1',
        islandId: 'dummy-couple',
        title: '커플샷',
        date: DateTime(y, m, 20),
        imageUrl: 'assets/images/memory/couple/couple1.jpeg',
      ),
      CalendarEvent(
        id: 'cp-2',
        islandId: 'dummy-couple',
        title: '데이트',
        date: DateTime(y, m, 20),
        imageUrl: 'assets/images/memory/couple/couple10.jpeg',
      ),
      CalendarEvent(
        id: 'eu-1',
        islandId: 'dummy-europe',
        title: '프라하',
        date: DateTime(y, m, 24),
        imageUrl: 'assets/images/memory/europe/prague1.jpeg',
      ),
      CalendarEvent(
        id: 'eu-2',
        islandId: 'dummy-europe',
        title: '유럽 단체',
        date: DateTime(y, m, 24),
        imageUrl: 'assets/images/memory/europe/c1.jpeg',
      ),
      CalendarEvent(
        id: 'eu-3',
        islandId: 'dummy-europe',
        title: '독일',
        date: DateTime(y, m, 25),
        imageUrl: 'assets/images/memory/europe/ger1.jpeg',
      ),
    ];
  }
}

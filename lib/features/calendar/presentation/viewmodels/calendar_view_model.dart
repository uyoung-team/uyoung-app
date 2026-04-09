import 'package:flutter/foundation.dart';
import 'package:uyoung_app/features/calendar/data/calendar_repository.dart';

class CalendarViewModel extends ChangeNotifier {
  CalendarViewModel(this.repository);

  final CalendarRepository repository;
}

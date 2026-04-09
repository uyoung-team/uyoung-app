import 'package:flutter/foundation.dart';
import 'package:uyoung_app/features/attendance/data/attendance_repository.dart';

class AttendanceViewModel extends ChangeNotifier {
  AttendanceViewModel(this.repository);

  final AttendanceRepository repository;
}

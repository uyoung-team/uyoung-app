import 'package:flutter/material.dart';

class CalendarIslandFilter {
  const CalendarIslandFilter({
    required this.id,
    required this.name,
    required this.color,
    required this.isSelected,
    required this.alertEnabled,
  });

  final String id;
  final String name;
  final Color color;
  final bool isSelected;
  final bool alertEnabled;

  CalendarIslandFilter copyWith({
    String? id,
    String? name,
    Color? color,
    bool? isSelected,
    bool? alertEnabled,
  }) {
    return CalendarIslandFilter(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      isSelected: isSelected ?? this.isSelected,
      alertEnabled: alertEnabled ?? this.alertEnabled,
    );
  }
}

class CalendarDayMemoryGroup {
  const CalendarDayMemoryGroup({
    required this.islandId,
    required this.islandName,
    required this.color,
    required this.thumbnailPaths,
  });

  final String islandId;
  final String islandName;
  final Color color;
  final List<String> thumbnailPaths;
}

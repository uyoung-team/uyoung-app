import 'package:flutter/material.dart';

class CalendarIslandFilter {
  const CalendarIslandFilter({
    required this.id,
    required this.name,
    required this.color,
    required this.isSelected,
  });

  final String id;
  final String name;
  final Color color;
  final bool isSelected;

  CalendarIslandFilter copyWith({
    String? id,
    String? name,
    Color? color,
    bool? isSelected,
  }) {
    return CalendarIslandFilter(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

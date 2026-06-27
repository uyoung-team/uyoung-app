import 'package:flutter/material.dart';

@immutable
class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.islandId,
    required this.title,
    required this.date,
    this.imageUrl,
    this.description,
    this.takenAt,
    this.createdAt,
    this.latitude,
    this.longitude,
    this.locationName,
    this.type = 'memory',
  });

  final String id;
  final String islandId;
  final String title;
  final DateTime date;
  final String? imageUrl;
  final String? description;
  final DateTime? takenAt;
  final DateTime? createdAt;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final String type;
}

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
    required this.photoIds,
    required this.events,
  });

  final String islandId;
  final String islandName;
  final Color color;
  final List<String> thumbnailPaths;
  final List<String> photoIds;
  final List<CalendarEvent> events;
}

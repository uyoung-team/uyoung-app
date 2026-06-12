import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/memory/data/memory_location_dummy.dart';
import 'package:uyoung_app/features/memory/presentation/pages/memory_local_photo.dart';
import 'package:uyoung_app/features/memory/presentation/pages/photo_detail_page.dart';
import 'package:uyoung_app/features/memory/presentation/widgets/memory_photo_thumbnail.dart';
import 'package:uyoung_app/shared/services/asset_paths.dart';

class TimelineMemoryPage extends StatefulWidget {
  const TimelineMemoryPage({
    super.key,
    required this.islandId,
    required this.photos,
  });

  final String islandId;
  final List<MemoryLocalPhoto> photos;

  @override
  State<TimelineMemoryPage> createState() => _TimelineMemoryPageState();
}

class _TimelineMemoryPageState extends State<TimelineMemoryPage> {
  DateTime? _selectedDate;
  final ScrollController _scrollController = ScrollController();
  final MapController _mapController = MapController();
  final Map<String, GlobalKey> _sectionKeys = <String, GlobalKey>{};
  String? _activeLocation;
  String? _lastFittedDateKey;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dates = widget.photos
        .map(
          (photo) => DateTime(
            (photo.takenAt ?? photo.createdAt).year,
            (photo.takenAt ?? photo.createdAt).month,
            (photo.takenAt ?? photo.createdAt).day,
          ),
        )
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    _selectedDate ??= dates.isNotEmpty ? dates.first : null;

    final filteredPhotos = _selectedDate == null
        ? const <MemoryLocalPhoto>[]
        : widget.photos.where((photo) {
            final date = photo.takenAt ?? photo.createdAt;
            return date.year == _selectedDate!.year &&
                date.month == _selectedDate!.month &&
                date.day == _selectedDate!.day;
          }).toList();

    final groupedByLocation = _groupByLocation(filteredPhotos);
    final locationKeys = groupedByLocation.keys.toList()
      ..sort((a, b) => _firstTakenAt(groupedByLocation[b]!).compareTo(_firstTakenAt(groupedByLocation[a]!)));

    if (_activeLocation != null && !locationKeys.contains(_activeLocation)) {
      _activeLocation = null;
    }
    _activeLocation ??= locationKeys.isNotEmpty ? locationKeys.first : null;
    final currentDateKey = _selectedDate == null
        ? null
        : '${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}';
    if (currentDateKey != _lastFittedDateKey) {
      _lastFittedDateKey = currentDateKey;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _fitMapToPhotos(filteredPhotos);
      });
    }

    for (final location in locationKeys) {
      _sectionKeys.putIfAbsent(location, GlobalKey.new);
    }

    return Column(
      children: [
        SizedBox(
          height: 300,
          width: double.infinity,
          child: _TimelineMap(
            mapController: _mapController,
            photos: filteredPhotos,
            activeLocation: _activeLocation,
            onLocationTap: _focusLocation,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: _dateDropdown(dates),
                ),
                const SizedBox(height: 14),
                if (_selectedDate == null || dates.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Text(
                      '선택할 날짜가 없어요.',
                      style: AppFont.b8_14,
                    ),
                  )
                else if (filteredPhotos.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Text(
                      '이 날짜에는 저장된 사진이 없어요.',
                      style: AppFont.b8_14,
                    ),
                  )
                else ...[
                  for (final location in locationKeys) ...[
                    const SizedBox(height: 10),
                    Container(
                      key: _sectionKeys[location],
                      child: _locationLabel(
                        location,
                        order: locationKeys.indexOf(location) + 1,
                        isActive: _activeLocation == location,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: groupedByLocation[location]!.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 1,
                          ),
                      itemBuilder: (_, i) {
                        final photo = groupedByLocation[location]![i];
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => PhotoDetailPage(
                                  islandId: widget.islandId,
                                  photoId: photo.id,
                                  imagePath: photo.path,
                                  uploaderName: photo.uploaderName,
                                  description: photo.description,
                                  uploaderProfile: photo.uploaderProfile,
                                  takenAt: photo.takenAt ?? photo.createdAt,
                                  latitude: photo.latitude,
                                  longitude: photo.longitude,
                                  locationName: photo.locationName,
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: MemoryPhotoThumbnail(photo: photo),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                  ],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _dateDropdown(List<DateTime> dates) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<DateTime>(
          value: _selectedDate,
          isExpanded: true,
          alignment: Alignment.center,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
          items: dates
              .map(
                (date) => DropdownMenuItem(
                  value: date,
                  child: Center(
                    child: Text(
                      _isToday(date) ? '오늘' : '${date.month}월 ${date.day}일',
                      style: AppFont.h4_22,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedDate = value;
              _activeLocation = null;
            });
          },
        ),
      ),
    );
  }

  Widget _locationLabel(
    String title, {
    required int order,
    required bool isActive,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              isActive
                  ? Image.asset(
                      AssetPaths.icons.photoDetail.imageLocationSpot,
                      width: 26,
                      height: 32,
                      fit: BoxFit.contain,
                    )
                  : Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppColors.bg03,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$order',
                        style: AppFont.b9_12.copyWith(color: AppColors.g02),
                      ),
                    ),
              Container(
                width: 1,
                height: 64,
                margin: const EdgeInsets.only(top: 6),
                color: AppColors.bg03,
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                title,
                style: AppFont.b7_16.copyWith(
                  color: isActive ? AppColors.black : AppColors.g02,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<MemoryLocalPhoto>> _groupByLocation(
    List<MemoryLocalPhoto> photos,
  ) {
    final grouped = <String, List<MemoryLocalPhoto>>{};

    for (final photo in photos) {
      final info = MemoryLocationDummy.get(photo.path);
      final label =
          photo.locationName ??
          info?.label ??
          info?.groupKey ??
          (photo.latitude != null && photo.longitude != null
              ? '${photo.latitude!.toStringAsFixed(4)}, ${photo.longitude!.toStringAsFixed(4)}'
              : '위치 미지정');
      (grouped[label] ??= []).add(photo);
    }

    for (final entry in grouped.entries) {
      entry.value.sort(
        (a, b) => (b.takenAt ?? b.createdAt).compareTo(a.takenAt ?? a.createdAt),
      );
    }

    return grouped;
  }

  DateTime _firstTakenAt(List<MemoryLocalPhoto> photos) {
    final sorted = [...photos]
      ..sort((a, b) => (a.takenAt ?? a.createdAt).compareTo(b.takenAt ?? b.createdAt));
    return sorted.first.takenAt ?? sorted.first.createdAt;
  }

  Future<void> _focusLocation(String location) async {
    final key = _sectionKeys[location];
    if (key?.currentContext == null) {
      return;
    }

    setState(() {
      _activeLocation = location;
    });

    await Scrollable.ensureVisible(
      key!.currentContext!,
      duration: const Duration(milliseconds: 300),
      alignment: 0.05,
      curve: Curves.easeInOut,
    );
  }

  void _fitMapToPhotos(List<MemoryLocalPhoto> photos) {
    final locatedPhotos = photos
        .where((photo) => photo.latitude != null && photo.longitude != null)
        .toList();
    if (locatedPhotos.isEmpty) {
      return;
    }

    if (locatedPhotos.length == 1) {
      final photo = locatedPhotos.first;
      _mapController.move(
        LatLng(photo.latitude!, photo.longitude!),
        14.5,
      );
      return;
    }

    final bounds = LatLngBounds.fromPoints([
      for (final photo in locatedPhotos)
        LatLng(photo.latitude!, photo.longitude!),
    ]);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(36),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;
  }
}

class _TimelineMap extends StatelessWidget {
  const _TimelineMap({
    required this.mapController,
    required this.photos,
    required this.activeLocation,
    required this.onLocationTap,
  });

  final MapController mapController;
  final List<MemoryLocalPhoto> photos;
  final String? activeLocation;
  final ValueChanged<String> onLocationTap;

  @override
  Widget build(BuildContext context) {
    final locatedPhotos = photos
        .where((photo) => photo.latitude != null && photo.longitude != null)
        .toList();

    if (locatedPhotos.isEmpty) {
      return Image.asset(
        'assets/images/map.png',
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const ColoredBox(color: AppColors.bg03),
      );
    }

    final grouped = _groupLocations(locatedPhotos);
    final orderedGroups = grouped.entries.toList()
      ..sort(
        (a, b) =>
            _firstTakenAt(a.value).compareTo(_firstTakenAt(b.value)),
      );
    final markers = _buildMarkers(orderedGroups);
    final center = _centerOf(locatedPhotos);

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 12.5,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.uyoung.app',
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: [
                for (final group in orderedGroups)
                  LatLng(group.value.first.latitude!, group.value.first.longitude!),
              ],
              color: AppColors.b02.withValues(alpha: 0.6),
              strokeWidth: 4,
            ),
          ],
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }

  LatLng _centerOf(List<MemoryLocalPhoto> photos) {
    final lat = photos.fold<double>(
          0,
          (sum, photo) => sum + (photo.latitude ?? 0),
        ) /
        photos.length;
    final lng = photos.fold<double>(
          0,
          (sum, photo) => sum + (photo.longitude ?? 0),
        ) /
        photos.length;
    return LatLng(lat, lng);
  }

  Map<String, List<MemoryLocalPhoto>> _groupLocations(List<MemoryLocalPhoto> photos) {
    final grouped = <String, List<MemoryLocalPhoto>>{};
    for (final photo in photos) {
      final lat = photo.latitude!;
      final lng = photo.longitude!;
      final key = photo.locationName?.trim().isNotEmpty == true
          ? photo.locationName!.trim()
          : '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
      (grouped[key] ??= []).add(photo);
    }
    return grouped;
  }

  List<Marker> _buildMarkers(List<MapEntry<String, List<MemoryLocalPhoto>>> orderedGroups) {
    return orderedGroups.asMap().entries.map((indexedEntry) {
      final order = indexedEntry.key + 1;
      final location = indexedEntry.value.key;
      final photosAtPoint = indexedEntry.value.value;
      final first = photosAtPoint.first;
      final latLng = LatLng(first.latitude!, first.longitude!);
      final isActive = activeLocation == location;

      return Marker(
        point: latLng,
        width: isActive ? 118 : 86,
        height: isActive ? 132 : 106,
        child: GestureDetector(
          onTap: () => onLocationTap(location),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: isActive ? 8 : 16,
                child: Container(
                  width: isActive ? 102 : 78,
                  height: isActive ? 102 : 78,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(isActive ? 22 : 18),
                    border: Border.all(
                      color: isActive ? AppColors.subYellow02 : AppColors.white,
                      width: isActive ? 5 : 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.22),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(isActive ? 16 : 14),
                    child: MemoryPhotoThumbnail(photo: first),
                  ),
                ),
              ),
              Positioned(
                top: isActive ? 0 : 10,
                right: isActive ? 6 : 2,
                child: isActive
                    ? Image.asset(
                        AssetPaths.icons.photoDetail.imageLocationSpot,
                        width: 30,
                        height: 36,
                        fit: BoxFit.contain,
                      )
                    : Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$order',
                          style: AppFont.b5_20.copyWith(color: AppColors.g01),
                        ),
                      ),
              ),
              Positioned(
                bottom: isActive ? 8 : 12,
                child: Container(
                  width: 0,
                  height: 0,
                  decoration: const BoxDecoration(),
                  child: CustomPaint(
                    size: const Size(18, 14),
                    painter: _MarkerTailPainter(
                      color: isActive ? AppColors.subYellow02 : AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  DateTime _firstTakenAt(List<MemoryLocalPhoto> photos) {
    final sorted = [...photos]
      ..sort(
        (a, b) => (a.takenAt ?? a.createdAt).compareTo(b.takenAt ?? b.createdAt),
      );
    return sorted.first.takenAt ?? sorted.first.createdAt;
  }
}

class _MarkerTailPainter extends CustomPainter {
  const _MarkerTailPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = ui.Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MarkerTailPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

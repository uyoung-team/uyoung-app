import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/memory/data/memory_location_dummy.dart';
import 'package:uyoung_app/features/memory/presentation/pages/memory_local_photo.dart';
import 'package:uyoung_app/features/memory/presentation/pages/photo_detail_page.dart';
import 'package:uyoung_app/features/memory/presentation/widgets/memory_photo_thumbnail.dart';

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
    final locationKeys = groupedByLocation.keys.toList()..sort();

    return Column(
      children: [
        SizedBox(
          height: 300,
          width: double.infinity,
          child: _TimelineMap(
            photos: filteredPhotos,
            onPhotoTap: (photo) {
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
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
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
                    _locationLabel(location),
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E5E5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<DateTime>(
          value: _selectedDate,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: dates
              .map(
                (date) => DropdownMenuItem(
                  value: date,
                  child: Text(
                    '${date.month}월 ${date.day}일',
                    style: AppFont.b8_14,
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() => _selectedDate = value);
          },
        ),
      ),
    );
  }

  Widget _locationLabel(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          const CircleAvatar(radius: 4, backgroundColor: Color(0xFFAFAFAF)),
          const SizedBox(width: 6),
          Text(title, style: AppFont.b8_14),
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
}

class _TimelineMap extends StatelessWidget {
  const _TimelineMap({
    required this.photos,
    required this.onPhotoTap,
  });

  final List<MemoryLocalPhoto> photos;
  final ValueChanged<MemoryLocalPhoto> onPhotoTap;

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

    final markers = _buildMarkers(locatedPhotos);
    final center = _centerOf(locatedPhotos);

    return FlutterMap(
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

  List<Marker> _buildMarkers(List<MemoryLocalPhoto> photos) {
    final grouped = <String, List<MemoryLocalPhoto>>{};
    for (final photo in photos) {
      final lat = photo.latitude!;
      final lng = photo.longitude!;
      final key = '${lat.toStringAsFixed(4)}:${lng.toStringAsFixed(4)}';
      (grouped[key] ??= []).add(photo);
    }

    return grouped.entries.map((entry) {
      final photosAtPoint = entry.value;
      final first = photosAtPoint.first;
      final latLng = LatLng(first.latitude!, first.longitude!);

      return Marker(
        point: latLng,
        width: 64,
        height: 64,
        child: GestureDetector(
          onTap: () => onPhotoTap(first),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.b02, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: photosAtPoint.length == 1
                ? ClipOval(
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: MemoryPhotoThumbnail(photo: first),
                    ),
                  )
                : Text(
                    '${photosAtPoint.length}',
                    style: AppFont.b7_16.copyWith(color: AppColors.b02),
                  ),
          ),
        ),
      );
    }).toList();
  }
}

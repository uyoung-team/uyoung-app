import 'package:flutter/material.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/memory/data/memory_location_dummy.dart';
import 'package:uyoung_app/features/memory/presentation/pages/memory_local_photo.dart';
import 'package:uyoung_app/features/memory/presentation/pages/photo_detail_page.dart';
import 'package:uyoung_app/features/memory/presentation/widgets/memory_photo_thumbnail.dart';

class TimelineMemoryPage extends StatefulWidget {
  const TimelineMemoryPage({
    super.key,
    required this.photos,
  });

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
            photo.createdAt.year,
            photo.createdAt.month,
            photo.createdAt.day,
          ),
        )
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    _selectedDate ??= dates.isNotEmpty ? dates.first : null;

    final filteredPhotos = _selectedDate == null
        ? const <MemoryLocalPhoto>[]
        : widget.photos.where((photo) {
            final date = photo.createdAt;
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
          child: Image.asset(
            'assets/images/map.png',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const ColoredBox(color: AppColors.bg03),
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
                                  imagePath: photo.path,
                                  uploaderName: photo.uploaderName,
                                  uploaderProfile: photo.uploaderProfile,
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
      final label = info?.label ?? info?.groupKey ?? '위치 미지정';
      (grouped[label] ??= []).add(photo);
    }

    return grouped;
  }
}

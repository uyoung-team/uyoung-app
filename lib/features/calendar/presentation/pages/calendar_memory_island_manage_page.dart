import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/calendar/data/calendar_models.dart';
import 'package:uyoung_app/features/calendar/presentation/pages/calendar_memory_island_settings_page.dart';
import 'package:uyoung_app/features/calendar/presentation/viewmodels/calendar_view_model.dart';
import 'package:uyoung_app/shared/services/asset_paths.dart';

class CalendarMemoryIslandManagePage extends StatefulWidget {
  const CalendarMemoryIslandManagePage({super.key});

  @override
  State<CalendarMemoryIslandManagePage> createState() =>
      _CalendarMemoryIslandManagePageState();
}

class _CalendarMemoryIslandManagePageState
    extends State<CalendarMemoryIslandManagePage> {
  bool _isSortMode = false;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CalendarViewModel>();
    final islands = viewModel.islandFilters;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 8, 5, 5),
              child: Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 26),
                  ),
                  const Spacer(),
                  Text(
                    '기억섬 관리',
                    style: AppFont.b5_20.copyWith(color: AppColors.black),
                  ),
                  const Spacer(),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      setState(() => _isSortMode = !_isSortMode);
                    },
                    icon: SvgPicture.asset(
                      AssetPaths.icons.common.reorder,
                      width: 40,
                      height: 40,
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: AppColors.g04),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Text(
                '내 기억섬',
                style: AppFont.b9_12.copyWith(color: const Color(0xFF707070)),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _isSortMode
                  ? _buildReorderableList(islands, viewModel)
                  : _buildNormalList(islands),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNormalList(List<CalendarIslandFilter> islands) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      itemCount: islands.length,
      separatorBuilder: (_, _) => const SizedBox(height: 24),
      itemBuilder: (context, index) {
        final island = islands[index];

        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    CalendarMemoryIslandSettingsPage(islandId: island.id),
              ),
            );
          },
          child: _buildIslandRow(
            island: island,
            trailing: Transform.rotate(
              angle: 3.141592,
              child: SvgPicture.asset(
                AssetPaths.icons.common.previous,
                width: 12,
                height: 12,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReorderableList(
    List<CalendarIslandFilter> islands,
    CalendarViewModel viewModel,
  ) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      itemCount: islands.length,
      buildDefaultDragHandles: false,
      itemBuilder: (context, index) {
        final island = islands[index];

        return Padding(
          key: ValueKey(island.id),
          padding: const EdgeInsets.only(bottom: 24),
          child: _buildIslandRow(
            island: island,
            trailing: ReorderableDragStartListener(
              index: index,
              child: SvgPicture.asset(
                AssetPaths.icons.common.hamburger,
                width: 22,
                height: 22,
              ),
            ),
          ),
        );
      },
      onReorder: viewModel.reorderIslands,
    );
  }

  Widget _buildIslandRow({
    required CalendarIslandFilter island,
    required Widget trailing,
  }) {
    return SizedBox(
              height: 25,
              child: Row(
                children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: island.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      island.name,
                      style: AppFont.b7_16.copyWith(color: AppColors.g01),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
          trailing,
        ],
      ),
    );
  }
}

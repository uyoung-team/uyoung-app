import 'package:flutter/material.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/shared/widgets/app_headline_text.dart';
import 'package:uyoung_app/shared/widgets/app_scaffold.dart';
import 'package:uyoung_app/shared/widgets/app_surface_card.dart';

class PearlChargePage extends StatelessWidget {
  const PearlChargePage({super.key});

  static const List<_PearlPackage> _packages = [
    _PearlPackage(title: '진주 한줌', countLabel: '10개', priceLabel: '1,000원'),
    _PearlPackage(title: '진주 꾸러미', countLabel: '50개', priceLabel: '4,800원'),
    _PearlPackage(title: '진주 상자', countLabel: '100개', priceLabel: '9,500원'),
    _PearlPackage(title: '진주 보물함', countLabel: '200개', priceLabel: '18,800원'),
    _PearlPackage(title: '진주 창고', countLabel: '300개', priceLabel: '26,900원'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '충전소',
      body: Container(
        color: AppColors.back,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final item = _packages[index];
            return _PearlPackageCard(item: item);
          },
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemCount: _packages.length,
        ),
      ),
    );
  }
}

class _PearlPackageCard extends StatelessWidget {
  const _PearlPackageCard({required this.item});

  final _PearlPackage item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('결제 기능은 준비 중이에요.')));
      },
      child: AppSurfaceCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.b03,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bubble_chart_rounded,
                color: AppColors.b01,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppFont.b8_14.copyWith(color: AppColors.g02),
                  ),
                  const SizedBox(height: 2),
                  AppHeadlineText(item.countLabel, style: AppFont.h7_16),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              item.priceLabel,
              style: AppFont.b6_18.copyWith(color: AppColors.g01),
            ),
          ],
        ),
      ),
    );
  }
}

class _PearlPackage {
  const _PearlPackage({
    required this.title,
    required this.countLabel,
    required this.priceLabel,
  });

  final String title;
  final String countLabel;
  final String priceLabel;
}

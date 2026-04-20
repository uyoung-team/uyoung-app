import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/core/theme/app_radius.dart';
import 'package:uyoung_app/core/theme/app_spacing.dart';
import 'package:uyoung_app/features/home/presentation/pages/notification_page.dart';
import 'package:uyoung_app/features/my_page/data/my_page_repository.dart';
import 'package:uyoung_app/features/my_page/data/my_page_service.dart';
import 'package:uyoung_app/features/my_page/presentation/pages/friends_page.dart';
import 'package:uyoung_app/features/my_page/presentation/pages/inquiries_page.dart';
import 'package:uyoung_app/features/my_page/presentation/pages/notices_page.dart';
import 'package:uyoung_app/features/my_page/presentation/viewmodels/my_page_view_model.dart';
import 'package:uyoung_app/shared/services/asset_paths.dart';
import 'package:uyoung_app/shared/widgets/app_headline_text.dart';

class MyPagePage extends StatelessWidget {
  const MyPagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          MyPageViewModel(const MyPageRepository(MyPageService()))..load(),
      child: const _MyPageView(),
    );
  }
}

class _MyPageView extends StatelessWidget {
  const _MyPageView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MyPageViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.back,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: context.read<MyPageViewModel>().load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 112),
            children: [
              const SizedBox(height: 18),
              _ProfileHero(viewModel: viewModel),
              const SizedBox(height: 18),
              _PearlCard(
                pearlCount: viewModel.profile.pearlCount,
                onTap: () => _showPreparingMessage(context, '진주 충전'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      label: '친구 목록',
                      child: _QuickActionAsset(
                        svgPath: AssetPaths.icons.smallMyPage.public,
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const FriendsPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _QuickActionCard(
                      label: '친구와 한 컷',
                      child: _QuickActionAsset(
                        svgPath: AssetPaths.icons.smallCommon.addPhotoPlus,
                      ),
                      onTap: () => _showPreparingMessage(context, '친구와 한 컷'),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _QuickActionCard(
                      label: '공지',
                      child: _QuickActionAsset(
                        svgPath: AssetPaths.icons.smallMyPage.notification,
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const NoticesPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const _SectionTitle('초대 및 공유'),
              const SizedBox(height: 10),
              _MenuRow(
                svgPath: AssetPaths.icons.smallMyPage.private,
                title: '프로필 URL 복사',
                onTap: () => _copyProfileCode(context, viewModel.userCode),
              ),
              _MenuRow(
                svgPath: AssetPaths.icons.smallMyPage.invite,
                title: '친구 초대 및 등록',
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: AppColors.black,
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const FriendsPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              const Divider(height: 1, color: AppColors.bg02),
              const SizedBox(height: 18),
              const _SectionTitle('고객지원'),
              const SizedBox(height: 10),
              _MenuRow(
                svgPath: AssetPaths.icons.smallMyPage.information,
                title: '버전정보',
                trailingText: MyPageViewModel.appVersion,
              ),
              _MenuRow(
                svgPath: AssetPaths.icons.smallMyPage.notification,
                title: '공지사항',
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: AppColors.black,
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const NoticesPage(),
                    ),
                  );
                },
              ),
              _MenuRow(
                svgPath: AssetPaths.icons.smallMyPage.question,
                title: '문의 내역',
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: AppColors.black,
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const InquiriesPage(),
                    ),
                  );
                },
              ),
              if (viewModel.errorMessage != null) ...[
                const SizedBox(height: 14),
                Text(
                  viewModel.errorMessage!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.subRed03,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 18),
              const Divider(height: 1, color: AppColors.bg02),
              const SizedBox(height: 18),
              _FooterActionText(
                title: '알림 보기',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const NotificationPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _FooterActionText(
                title: '로그아웃',
                onTap: () => _showPreparingMessage(context, '로그아웃'),
              ),
              const SizedBox(height: 20),
              _FooterActionText(
                title: '계정탈퇴',
                onTap: () => _showPreparingMessage(context, '계정탈퇴'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showPreparingMessage(BuildContext context, String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$label 기능은 준비 중이에요.')),
      );
  }

  static Future<void> _copyProfileCode(
    BuildContext context,
    String userCode,
  ) async {
    await Clipboard.setData(ClipboardData(text: userCode));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('초대 코드가 복사되었어요.')));
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.viewModel});

  final MyPageViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 228,
          child: Center(
            child: SizedBox(
              width: 210,
              height: 210,
              child: _ProfileAvatar(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.bg02),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (viewModel.isLoading)
                    const _LoadingTextGroup()
                  else ...[
                    AppHeadlineText(
                      viewModel.displayName,
                      style: AppFont.h5_20,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '초대 코드 ${viewModel.userCode}',
                      style: AppFont.b8_14.copyWith(color: AppColors.g02),
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              right: -10,
              top: -6,
              child: GestureDetector(
                onTap: () =>
                    _MyPageView._showPreparingMessage(context, '프로필 편집'),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.b02,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: AppColors.white,
                    size: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    final profileImageUrl = context.select<MyPageViewModel, String?>(
      (vm) => vm.profile.profileImageUrl,
    );

    return Container(
      width: 210,
      height: 210,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(105),
        border: Border.all(color: AppColors.bg02),
      ),
      clipBehavior: Clip.antiAlias,
      child: profileImageUrl != null && profileImageUrl.isNotEmpty
          ? Image.network(
              profileImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const _AvatarFallback(),
            )
          : const _AvatarFallback(),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.person_rounded, color: AppColors.b01, size: 84);
  }
}

class _LoadingTextGroup extends StatelessWidget {
  const _LoadingTextGroup();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.bg03,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: 88,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.bg02,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ],
    );
  }
}

class _PearlCard extends StatelessWidget {
  const _PearlCard({
    required this.pearlCount,
    required this.onTap,
  });

  final int pearlCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.bg02),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.subYellow05,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bubble_chart_outlined,
                  color: AppColors.subYellow01,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '진주',
                style: AppFont.h7_16.copyWith(color: AppColors.g02),
              ),
              const Spacer(),
              Text(
                '$pearlCount개',
                style: AppFont.h7_16.copyWith(color: AppColors.black),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.black,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.label,
    required this.child,
    this.onTap,
  });

  final String label;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 84,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.bg02),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 38,
                child: Center(
                  child: FittedBox(fit: BoxFit.scaleDown, child: child),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppFont.b8_14.copyWith(color: AppColors.g02),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionAsset extends StatelessWidget {
  const _QuickActionAsset({required this.svgPath});

  final String svgPath;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      svgPath,
      width: 36,
      height: 36,
      colorFilter: const ColorFilter.mode(
        AppColors.black,
        BlendMode.srcIn,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppFont.b8_14.copyWith(color: AppColors.g02),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.svgPath,
    required this.title,
    this.trailing,
    this.trailingText,
    this.onTap,
  });

  final String svgPath;
  final String title;
  final Widget? trailing;
  final String? trailingText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final trailingWidget =
        trailing ??
        (trailingText == null
            ? null
            : Text(
                trailingText!,
                style: AppFont.b9_12.copyWith(color: AppColors.black),
              ));
    final trailingChildren = trailingWidget == null
        ? const <Widget>[]
        : <Widget>[trailingWidget];

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: SvgPicture.asset(
                svgPath,
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  AppColors.black,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: AppFont.b7_16.copyWith(color: AppColors.black),
              ),
            ),
            ...trailingChildren,
          ],
        ),
      ),
    );
  }
}

class _FooterActionText extends StatelessWidget {
  const _FooterActionText({
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          title,
          style: AppFont.b7_16.copyWith(color: AppColors.black),
        ),
      ),
    );
  }
}

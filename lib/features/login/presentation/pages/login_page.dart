import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/login/data/login_repository.dart';
import 'package:uyoung_app/features/login/data/login_service.dart';
import 'package:uyoung_app/features/login/presentation/viewmodels/login_view_model.dart';
import 'package:uyoung_app/shared/widgets/app_headline_text.dart';
import 'package:uyoung_app/shared/services/asset_paths.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(const LoginRepository(LoginService())),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              AssetPaths.images.splash.background,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.white.withValues(alpha: 0.02),
                    AppColors.white.withValues(alpha: 0.36),
                    AppColors.white,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final scale = (width / 390).clamp(0.92, 1.08);

                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    24 * scale,
                    12 * scale,
                    24 * scale,
                    28 * scale,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16 * scale),
                      Align(
                        child: SizedBox(
                          width: 238 * scale,
                          height: 238 * scale,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned.fill(
                                child: Image.asset(
                                  AssetPaths.images.splash.character,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Positioned(
                                top: 4 * scale,
                                right: -8 * scale,
                                child: Image.asset(
                                  AssetPaths.images.splash.speechBubble,
                                  width: 122 * scale,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      AppHeadlineText.h1('기억이 머무는 곳,\n유영'),
                      SizedBox(height: 10 * scale),
                      Text(
                        '카카오 또는 구글 계정으로 로그인하고\n새 프로젝트에서 이어서 기억을 남겨보세요.',
                        style: AppFont.b7_16.copyWith(
                          color: AppColors.g02,
                          height: 1.35,
                        ),
                      ),
                      SizedBox(height: 24 * scale),
                      _SocialLoginButton(
                        label: '카카오로 시작하기',
                        backgroundColor: const Color(0xFFFEE500),
                        foregroundColor: AppColors.black,
                        onTap: viewModel.isLoading
                            ? null
                            : () => _signIn(context, OAuthProvider.kakao),
                      ),
                      SizedBox(height: 12 * scale),
                      _SocialLoginButton(
                        label: '구글로 시작하기',
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.black,
                        borderColor: AppColors.bg02,
                        onTap: viewModel.isLoading
                            ? null
                            : () => _signIn(context, OAuthProvider.google),
                      ),
                      SizedBox(height: 12 * scale),
                      _SocialLoginButton(
                        label: '애플 로그인 준비 중',
                        backgroundColor: AppColors.black,
                        foregroundColor: AppColors.white,
                        onTap: null,
                      ),
                      if (viewModel.isLoading) ...[
                        SizedBox(height: 18 * scale),
                        const Center(child: CircularProgressIndicator()),
                      ],
                      if (viewModel.errorText != null) ...[
                        SizedBox(height: 12 * scale),
                        Text(
                          viewModel.errorText!,
                          style: AppFont.b8_14.copyWith(
                            color: AppColors.subRed03,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signIn(BuildContext context, OAuthProvider provider) async {
    try {
      await context.read<LoginViewModel>().signInWithSocial(provider);
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('로그인 브라우저를 열지 못했어요.')),
        );
    }
  }
}

class _SocialLoginButton extends StatelessWidget {
  const _SocialLoginButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
    this.onTap,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: onTap == null ? 0.5 : 1,
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: borderColor == null
                ? null
                : Border.all(color: borderColor!, width: 1),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppFont.b6_18.copyWith(color: foregroundColor),
          ),
        ),
      ),
    );
  }
}

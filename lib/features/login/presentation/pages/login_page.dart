import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/login/data/login_repository.dart';
import 'package:uyoung_app/features/login/data/login_service.dart';
import 'package:uyoung_app/features/login/presentation/viewmodels/login_view_model.dart';
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
            child: Image.asset(AssetPaths.images.login.background, fit: BoxFit.cover),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xCCFFFFFF)],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Text(
                    '기억이 머무는 곳,\nUYOUNG',
                    style: AppFont.h3_24.copyWith(
                      color: const Color(0xFF202020),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '카카오 또는 구글 계정으로 로그인하고\n기억섬 초대를 바로 이어서 진행할 수 있어요.',
                    style: AppFont.b7_16.copyWith(
                      color: const Color(0xFF6E6E73),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _SocialLoginButton(
                    label: '카카오로 시작하기',
                    assetPath: AssetPaths.images.login.kakao,
                    backgroundColor: const Color(0xFFFEE500),
                    foregroundColor: const Color(0xFF191919),
                    onTap: viewModel.isLoading
                        ? null
                        : () => _signIn(context, OAuthProvider.kakao),
                  ),
                  const SizedBox(height: 12),
                  _SocialLoginButton(
                    label: '구글로 시작하기',
                    assetPath: AssetPaths.images.login.google,
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF202020),
                    borderColor: const Color(0xFFE1E3E8),
                    onTap: viewModel.isLoading
                        ? null
                        : () => _signIn(context, OAuthProvider.google),
                  ),
                  const SizedBox(height: 12),
                  _SocialLoginButton(
                    label: '애플 로그인 준비 중',
                    assetPath: AssetPaths.images.login.apple,
                    backgroundColor: Color(0xFF111111),
                    foregroundColor: Colors.white70,
                    onTap: null,
                  ),
                  const SizedBox(height: 12),
                  if (viewModel.isLoading)
                    const Center(child: CircularProgressIndicator()),
                  if (viewModel.errorText != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      viewModel.errorText!,
                      style: AppFont.b8_14.copyWith(
                        color: AppColors.subRed03,
                      ),
                    ),
                  ],
                ],
              ),
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
    required this.assetPath,
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
    this.onTap,
  });

  final String label;
  final String assetPath;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1.0,
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: borderColor == null
                ? null
                : Border.all(color: borderColor!, width: 1),
          ),
          child: Row(
            children: [
              const SizedBox(width: 18),
              Image.asset(assetPath, width: 26, height: 26),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: AppFont.b6_18.copyWith(color: foregroundColor),
                ),
              ),
              const SizedBox(width: 18),
            ],
          ),
        ),
      ),
    );
  }
}

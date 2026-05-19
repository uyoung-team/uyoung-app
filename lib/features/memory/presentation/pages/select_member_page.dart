import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/memory/data/memory_models.dart';
import 'package:uyoung_app/features/memory/data/memory_repository.dart';
import 'package:uyoung_app/features/memory/data/memory_service.dart';
import 'package:uyoung_app/features/memory/presentation/viewmodels/create_memory_view_model.dart';
import 'package:uyoung_app/features/memory/presentation/viewmodels/select_member_view_model.dart';
import 'package:uyoung_app/shared/widgets/app_headline_text.dart';

class SelectMemberPage extends StatelessWidget {
  const SelectMemberPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SelectMemberViewModel(
        repository: const MemoryRepository(MemoryService()),
      )..search(''),
      child: const _SelectMemberStepView(),
    );
  }
}

class _SelectMemberStepView extends StatefulWidget {
  const _SelectMemberStepView();

  @override
  State<_SelectMemberStepView> createState() => _SelectMemberStepViewState();
}

class _SelectMemberStepViewState extends State<_SelectMemberStepView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final createVm = context.read<CreateMemoryViewModel>();

    try {
      final createdItem = await createVm.createIsland();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('기억섬이 생성됐어요. ${createdItem.title}')),
        );
      Navigator.pop(context, createdItem);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final createVm = context.watch<CreateMemoryViewModel>();
    final selectVm = context.watch<SelectMemberViewModel>();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: AppHeadlineText('대화 상대', style: AppFont.h5_20),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (createVm.selectedMembers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
              child: SizedBox(
                height: 92,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: createVm.selectedMembers.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final user = createVm.selectedMembers[index];
                    return _SelectedUserChip(
                      user: user,
                      onRemove: () => createVm.removeInvitee(user.id),
                    );
                  },
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: TextField(
              controller: _searchController,
              onChanged: selectVm.scheduleSearch,
              decoration: InputDecoration(
                hintText: '이름 또는 초성 검색',
                hintStyle: AppFont.b7_16.copyWith(color: AppColors.g03),
                suffixIcon: const Icon(Icons.search, color: AppColors.black),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.g03),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.b02, width: 2),
                ),
              ),
              style: AppFont.b7_16,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _UserSearchResultList(
              users: selectVm.searchResults,
              selectedUserIds:
                  createVm.selectedMembers.map((user) => user.id).toSet(),
              isLoading: selectVm.isLoading,
              errorText: selectVm.errorText,
              query: selectVm.query,
              onTapUser: createVm.toggleInvitee,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      onPressed: createVm.isSubmitting
                          ? null
                          : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.bg02),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        '이전',
                        style: AppFont.b6_18.copyWith(color: AppColors.black),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: TextButton(
                      onPressed:
                          createVm.canSubmit && !createVm.isSubmitting ? _submit : null,
                      style: TextButton.styleFrom(
                        backgroundColor: createVm.canSubmit
                            ? AppColors.b02
                            : AppColors.bg02,
                        disabledBackgroundColor: AppColors.bg02,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: createVm.isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: AppColors.white,
                              ),
                            )
                          : Text(
                              '확인',
                              style: AppFont.b6_18.copyWith(
                                color: createVm.canSubmit
                                    ? AppColors.white
                                    : AppColors.g03,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedUserChip extends StatelessWidget {
  const _SelectedUserChip({
    required this.user,
    required this.onRemove,
  });

  final InviteeUser user;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            _UserAvatar(user: user, radius: 32),
            Positioned(
              top: -2,
              right: -2,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.b02,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 14,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(user.displayName, style: AppFont.b8_14),
      ],
    );
  }
}

class _UserSearchResultList extends StatelessWidget {
  const _UserSearchResultList({
    required this.users,
    required this.selectedUserIds,
    required this.isLoading,
    required this.errorText,
    required this.query,
    required this.onTapUser,
  });

  final List<InviteeUser> users;
  final Set<String> selectedUserIds;
  final bool isLoading;
  final String? errorText;
  final String query;
  final ValueChanged<InviteeUser> onTapUser;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorText != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            errorText!,
            style: AppFont.b8_14.copyWith(color: AppColors.subRed03),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (users.isEmpty) {
      return Center(
        child: Text(
          query.trim().isEmpty ? '닉네임 또는 유저 코드를 검색해보세요.' : '검색 결과가 없어요.',
          style: AppFont.b7_16.copyWith(color: AppColors.g03),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      itemCount: users.length,
      itemBuilder: (_, index) {
        final user = users[index];
        final isSelected = selectedUserIds.contains(user.id);
        return GestureDetector(
          onTap: () => onTapUser(user),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                _UserAvatar(user: user),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.displayName, style: AppFont.b7_16),
                      const SizedBox(height: 4),
                      Text(
                        user.userCode,
                        style: AppFont.b8_14.copyWith(color: AppColors.g03),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.b02 : AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.transparent : AppColors.g03,
                      width: 1.3,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: AppColors.white, size: 16)
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({
    required this.user,
    this.radius = 28,
  });

  final InviteeUser user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.bg02,
      backgroundImage:
          user.avatarUrl?.isNotEmpty == true ? NetworkImage(user.avatarUrl!) : null,
      child: user.avatarUrl?.isNotEmpty == true
          ? null
          : Text(
              user.displayName.isEmpty ? '?' : user.displayName[0],
              style: AppFont.b6_18.copyWith(color: AppColors.g02),
            ),
    );
  }
}

import 'dart:math';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uyoung_app/core/network/supabase_client_provider.dart';

class MyPageService {
  const MyPageService({SupabaseClientProvider? clientProvider})
    : _clientProvider = clientProvider ?? SupabaseClientProvider.instance;

  final SupabaseClientProvider _clientProvider;

  Future<Map<String, dynamic>?> fetchProfile() async {
    final client = _clientProvider.client;
    final userId = client?.auth.currentUser?.id;

    if (client == null || userId == null) {
      return null;
    }

    final response = await client
        .from('profiles')
        .select('nickname, user_code, avatar_url')
        .eq('id', userId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return Map<String, dynamic>.from(response);
  }

  Future<void> updateProfile({
    required String nickname,
    String? profileImageUrl,
  }) async {
    final client = _clientProvider.client;
    final userId = client?.auth.currentUser?.id;

    if (client == null || userId == null) {
      throw StateError('로그인이 필요합니다.');
    }

    final userCode = await _resolveUserCode(client, userId);

    await client.from('profiles').upsert({
      'id': userId,
      'user_code': userCode,
      'nickname': nickname.trim(),
      'avatar_url': profileImageUrl?.trim().isEmpty == true
          ? null
          : profileImageUrl?.trim(),
    }, onConflict: 'id');

    await _ensureUserAssetsRow(client, userId);
  }

  Future<String> uploadProfileImage(XFile imageFile) async {
    final client = _clientProvider.client;
    final userId = client?.auth.currentUser?.id;

    if (client == null || userId == null) {
      throw StateError('로그인이 필요합니다.');
    }

    final bytes = await imageFile.readAsBytes();
    final originalName = imageFile.name.isEmpty ? 'profile.jpg' : imageFile.name;
    final sanitizedName = originalName.replaceAll(
      RegExp(r'[^a-zA-Z0-9._-]'),
      '_',
    );
    final path =
        'profiles/$userId/${DateTime.now().microsecondsSinceEpoch}_$sanitizedName';

    await client.storage.from('profile_images').uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(
        upsert: true,
        contentType: _contentTypeFor(sanitizedName),
      ),
    );

    return client.storage.from('profile_images').getPublicUrl(path);
  }

  Future<List<Map<String, dynamic>>> fetchUserAssets() async {
    final client = _clientProvider.client;
    final userId = client?.auth.currentUser?.id;

    if (client == null || userId == null) {
      return const [];
    }

    final response = await client
        .from('user_assets')
        .select('user_id, pearl_count, updated_at')
        .eq('user_id', userId);

    if ((response as List).isEmpty) {
      await _ensureUserAssetsRow(client, userId);
      return const [];
    }

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchNotices() async {
    final client = _clientProvider.client;
    if (client == null) {
      return const [];
    }

    final response = await client
        .from('notices')
        .select('id, title, content, is_important, created_at')
        .order('is_important', ascending: false)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> fetchNoticeDetail(String id) async {
    final client = _clientProvider.client;
    if (client == null || id.isEmpty) {
      return null;
    }

    final response = await client
        .from('notices')
        .select('id, title, content, is_important, created_at')
        .eq('id', id)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return Map<String, dynamic>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchFriendRows() async {
    final client = _clientProvider.client;
    final userId = client?.auth.currentUser?.id;

    if (client == null || userId == null) {
      return const [];
    }

    try {
      final response = await client
          .from('friends')
          .select('id, friend_id, created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      return const [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchProfilesByIds(
    List<String> ids,
  ) async {
    final client = _clientProvider.client;
    if (client == null || ids.isEmpty) {
      return const [];
    }

    final response = await client
        .from('profiles')
        .select('id, nickname, user_code, avatar_url')
        .inFilter('id', ids);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> fetchProfileByUserCode(String userCode) async {
    final client = _clientProvider.client;
    final currentUserId = client?.auth.currentUser?.id;

    if (client == null || userCode.isEmpty) {
      return null;
    }

    final response = await client
        .from('profiles')
        .select('id, nickname, user_code, avatar_url')
        .eq('user_code', userCode)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    final profile = Map<String, dynamic>.from(response);
    if (profile['id']?.toString() == currentUserId) {
      return null;
    }

    return profile;
  }

  Future<void> addFriendByCode(String userCode) async {
    final client = _clientProvider.client;
    if (client == null || userCode.trim().isEmpty) {
      throw StateError('친구 코드를 입력해주세요.');
    }

    await client.rpc(
      'add_friend_by_code',
      params: {'input_code': userCode.trim()},
    );
  }

  Future<void> deleteFriend(String friendId) async {
    final client = _clientProvider.client;
    final userId = client?.auth.currentUser?.id;

    if (client == null || userId == null) {
      throw StateError('로그인이 필요합니다.');
    }

    await client
        .from('friends')
        .delete()
        .eq('user_id', userId)
        .eq('friend_id', friendId);
  }

  Future<List<Map<String, dynamic>>> fetchInquiries() async {
    final client = _clientProvider.client;
    final userId = client?.auth.currentUser?.id;

    if (client == null || userId == null) {
      return const [];
    }

    final response = await client
        .from('inquiries')
        .select('id, title, created_at, status, answer')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  String _contentTypeFor(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  Future<String> _resolveUserCode(SupabaseClient client, String userId) async {
    final existing = await client
        .from('profiles')
        .select('user_code')
        .eq('id', userId)
        .maybeSingle();

    final existingCode = existing?['user_code']?.toString().trim() ?? '';
    if (existingCode.isNotEmpty) {
      return existingCode;
    }

    for (var attempt = 0; attempt < 8; attempt++) {
      final candidate = _generateUserCode();
      final duplicated = await client
          .from('profiles')
          .select('id')
          .eq('user_code', candidate)
          .maybeSingle();

      if (duplicated == null) {
        return candidate;
      }
    }

    return _generateUserCode();
  }

  String _generateUserCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return List.generate(
      8,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  Future<void> _ensureUserAssetsRow(
    SupabaseClient client,
    String userId,
  ) async {
    await client.from('user_assets').upsert({
      'user_id': userId,
      'pearl_count': 0,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id');
  }
}

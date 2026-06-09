import 'dart:typed_data';

import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:native_exif/native_exif.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uyoung_app/core/network/supabase_client_provider.dart';

class MemoryService {
  const MemoryService({SupabaseClientProvider? clientProvider})
    : _clientProvider = clientProvider ?? SupabaseClientProvider.instance;

  final SupabaseClientProvider _clientProvider;
  static const String _friendPhotosBucket = 'friend_photos';

  Future<List<Map<String, dynamic>>> fetchIslandRows() async {
    final client = _clientProvider.client;
    final userId = client?.auth.currentUser?.id;

    if (client == null || userId == null) {
      return const [];
    }

    final response = await client
        .from('island_members')
        .select(
          'island_id, is_favorite, is_muted, islands(id, name, bg_image_url, theme_color, invite_code, updated_at)',
        )
        .eq('user_id', userId)
        .order('is_favorite', ascending: false)
        .order('updated_at', ascending: false, referencedTable: 'islands');

    return List<Map<String, dynamic>>.from(
      (response as List<dynamic>).map(
        (row) => Map<String, dynamic>.from(row as Map),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchIslandMemberRows(
    List<String> islandIds,
  ) async {
    final client = _clientProvider.client;
    if (client == null || islandIds.isEmpty) {
      return const [];
    }

    final response = await client
        .from('island_members')
        .select('island_id, user_id')
        .inFilter('island_id', islandIds);

    return List<Map<String, dynamic>>.from(
      (response as List<dynamic>).map(
        (row) => Map<String, dynamic>.from(row as Map),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchProfilesByIds(
    List<String> userIds,
  ) async {
    final client = _clientProvider.client;
    if (client == null || userIds.isEmpty) {
      return const [];
    }

    final response = await client
        .from('profiles')
        .select('id, nickname, avatar_url, user_code')
        .inFilter('id', userIds);

    return List<Map<String, dynamic>>.from(
      (response as List<dynamic>).map(
        (row) => Map<String, dynamic>.from(row as Map),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchFriendPhotos(String islandId) async {
    final client = _clientProvider.client;
    if (client == null || islandId.isEmpty) {
      return const [];
    }

    final response = await _selectFriendPhotos(client, islandId);

    return List<Map<String, dynamic>>.from(
      (response as List<dynamic>).map(
        (row) => Map<String, dynamic>.from(row as Map),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> searchUsers(String keyword) async {
    final client = _clientProvider.client;
    if (client == null) {
      return const [];
    }

    final response = await client.rpc(
      'search_users',
      params: {'search_term': keyword},
    );

    return List<Map<String, dynamic>>.from(
      (response as List<dynamic>).map(
        (row) => Map<String, dynamic>.from(row as Map),
      ),
    );
  }

  Future<String> createIslandWithMembers({
    required String islandName,
    required String color,
    String? bgUrl,
    List<String> inviteeIds = const [],
  }) async {
    final client = _clientProvider.client;
    if (client == null) {
      throw StateError('로그인이 필요합니다.');
    }

    final response = await client.rpc(
      'create_island_with_members',
      params: {
        'island_name': islandName,
        'color': color,
        'bg_url': bgUrl,
        'invitee_ids': inviteeIds,
      },
    );

    return response as String;
  }

  Future<String> uploadIslandBackground(XFile imageFile) async {
    final client = _clientProvider.client;
    if (client == null) {
      throw StateError('로그인이 필요합니다.');
    }

    final Uint8List bytes = await imageFile.readAsBytes();
    final originalName =
        imageFile.name.isEmpty ? 'background.jpg' : imageFile.name;
    final sanitizedName = originalName.replaceAll(
      RegExp(r'[^a-zA-Z0-9._-]'),
      '_',
    );
    final path =
        'memory_islands/${DateTime.now().microsecondsSinceEpoch}_$sanitizedName';

    await client.storage.from('island_backgrounds').uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(
        upsert: true,
        contentType: _contentTypeFor(sanitizedName),
      ),
    );

    return client.storage.from('island_backgrounds').getPublicUrl(path);
  }

  Future<Map<String, dynamic>> uploadFriendPhoto({
    required String islandId,
    required XFile imageFile,
    String? description,
  }) async {
    final client = _clientProvider.client;
    final userId = client?.auth.currentUser?.id;
    if (client == null || userId == null) {
      throw StateError('로그인이 필요합니다.');
    }

    final Uint8List bytes = await imageFile.readAsBytes();
    final originalName =
        imageFile.name.isEmpty ? 'memory.jpg' : imageFile.name;
    final sanitizedName = originalName.replaceAll(
      RegExp(r'[^a-zA-Z0-9._-]'),
      '_',
    );
    final path =
        'islands/$islandId/${DateTime.now().microsecondsSinceEpoch}_$sanitizedName';

    await client.storage.from(_friendPhotosBucket).uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(
        upsert: true,
        contentType: _contentTypeFor(sanitizedName),
      ),
    );

    final imageUrl = client.storage.from(_friendPhotosBucket).getPublicUrl(path);
    final metadata = await _extractPhotoMetadata(imageFile);
    final basicPayload = {
      'uploader_id': userId,
      'island_id': islandId,
      'image_url': imageUrl,
      'description': description,
    };
    final metadataPayload = {
      ...basicPayload,
      if (metadata['taken_at'] != null) 'taken_at': metadata['taken_at'],
      if (metadata['latitude'] != null) 'latitude': metadata['latitude'],
      if (metadata['longitude'] != null) 'longitude': metadata['longitude'],
      if (metadata['location_name'] != null)
        'location_name': metadata['location_name'],
    };

    Map<String, dynamic> response;
    try {
      final raw = await client
          .from('friend_photos')
          .insert(metadataPayload)
          .select(
            'id, uploader_id, island_id, image_url, description, created_at, taken_at, latitude, longitude, location_name',
          )
          .single();
      response = Map<String, dynamic>.from(raw);
    } catch (_) {
      final raw = await client
          .from('friend_photos')
          .insert(basicPayload)
          .select('id, uploader_id, island_id, image_url, description, created_at')
          .single();
      response = Map<String, dynamic>.from(raw)
        ..addAll({
          'taken_at': metadata['taken_at'],
          'latitude': metadata['latitude'],
          'longitude': metadata['longitude'],
          'location_name': metadata['location_name'],
        });
    }

    return response;
  }

  Future<dynamic> _selectFriendPhotos(
    SupabaseClient client,
    String islandId,
  ) async {
    try {
      return await client
          .from('friend_photos')
          .select(
            'id, uploader_id, island_id, image_url, description, created_at, taken_at, latitude, longitude, location_name',
          )
          .eq('island_id', islandId)
          .order('taken_at', ascending: false, nullsFirst: false)
          .order('created_at', ascending: false);
    } catch (_) {
      return await client
          .from('friend_photos')
          .select('id, uploader_id, island_id, image_url, description, created_at')
          .eq('island_id', islandId)
          .order('created_at', ascending: false);
    }
  }

  Future<Map<String, Object?>> _extractPhotoMetadata(XFile imageFile) async {
    final path = imageFile.path;
    if (path.isEmpty) {
      return const {};
    }

    final exif = await Exif.fromPath(path);
    try {
      final takenAt = await exif.getOriginalDate();
      final latLong = await exif.getLatLong();
      String? locationName;

      if (latLong != null) {
        try {
          final placemarks = await placemarkFromCoordinates(
            latLong.latitude,
            latLong.longitude,
          );
          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            locationName = [
              place.administrativeArea,
              place.locality,
              place.subLocality,
              place.thoroughfare,
            ].whereType<String>().where((part) => part.trim().isNotEmpty).join(' ');
            if (locationName.trim().isEmpty) {
              locationName = null;
            }
          }
        } catch (_) {
          locationName = null;
        }
      }

      return {
        'taken_at': takenAt?.toIso8601String(),
        'latitude': latLong?.latitude,
        'longitude': latLong?.longitude,
        'location_name': locationName,
      };
    } finally {
      await exif.close();
    }
  }

  Future<String?> fetchInviteCode(String islandId) async {
    final client = _clientProvider.client;
    if (client == null || islandId.isEmpty) {
      return null;
    }

    final response = await client
        .from('islands')
        .select('invite_code')
        .eq('id', islandId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return response['invite_code']?.toString();
  }

  Future<void> updateIslandMemberSettings({
    required String islandId,
    bool? isFavorite,
    bool? isMuted,
  }) async {
    final client = _clientProvider.client;
    final userId = client?.auth.currentUser?.id;
    if (client == null || userId == null) {
      throw StateError('로그인이 필요합니다.');
    }

    final updates = <String, dynamic>{};
    if (isFavorite != null) {
      updates['is_favorite'] = isFavorite;
    }
    if (isMuted != null) {
      updates['is_muted'] = isMuted;
    }

    if (updates.isEmpty) {
      return;
    }

    await client
        .from('island_members')
        .update(updates)
        .eq('island_id', islandId)
        .eq('user_id', userId);
  }

  Future<void> updateIslandName({
    required String islandId,
    required String name,
  }) async {
    final client = _clientProvider.client;
    if (client == null) {
      throw StateError('로그인이 필요합니다.');
    }

    await client.from('islands').update({'name': name}).eq('id', islandId);
  }

  Future<void> leaveIsland(String islandId) async {
    final client = _clientProvider.client;
    if (client == null) {
      throw StateError('로그인이 필요합니다.');
    }

    await client.rpc(
      'leave_island',
      params: {'target_island_id': islandId},
    );
  }

  Future<List<Map<String, dynamic>>> fetchIslandByIds(List<String> islandIds) async {
    final client = _clientProvider.client;
    if (client == null || islandIds.isEmpty) {
      return const [];
    }

    final response = await client
        .from('islands')
        .select('id, name, bg_image_url, invite_code, updated_at')
        .inFilter('id', islandIds);

    return List<Map<String, dynamic>>.from(
      (response as List<dynamic>).map(
        (row) => Map<String, dynamic>.from(row as Map),
      ),
    );
  }

  Future<Map<String, dynamic>?> fetchIsland(String islandId) async {
    final rows = await fetchIslandByIds([islandId]);
    return rows.isEmpty ? null : rows.first;
  }

  Future<Map<String, dynamic>?> fetchIslandByInviteCode(String inviteCode) async {
    final client = _clientProvider.client;
    if (client == null || inviteCode.isEmpty) {
      return null;
    }

    final response = await client
        .from('islands')
        .select('id, name, bg_image_url, invite_code, updated_at')
        .eq('invite_code', inviteCode)
        .maybeSingle();

    return response == null ? null : Map<String, dynamic>.from(response);
  }

  Future<void> joinIslandByInviteCode(String inviteCode) async {
    final client = _clientProvider.client;
    final userId = client?.auth.currentUser?.id;
    if (client == null || userId == null) {
      throw StateError('로그인 후 입장할 수 있어요.');
    }

    final island = await fetchIslandByInviteCode(inviteCode);
    if (island == null) {
      throw StateError('유효하지 않은 초대 링크예요.');
    }

    final islandId = island['id']?.toString();
    if (islandId == null || islandId.isEmpty) {
      throw StateError('기억섬 정보를 찾을 수 없어요.');
    }

    final existingMembership = await client
        .from('island_members')
        .select('id')
        .eq('island_id', islandId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existingMembership == null) {
      await client.from('island_members').insert({
        'island_id': islandId,
        'user_id': userId,
        'role': 'member',
        'is_favorite': false,
        'is_muted': false,
      });
    }
  }

  Future<void> inviteMembersToIsland({
    required String islandId,
    required List<String> selectedUserIds,
  }) async {
    final client = _clientProvider.client;
    if (client == null) {
      throw StateError('로그인이 필요합니다.');
    }

    if (selectedUserIds.isEmpty) {
      return;
    }

    await client.rpc(
      'invite_members_to_island',
      params: {
        'target_island_id': islandId,
        'target_user_ids': selectedUserIds,
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchFavoritePhotos(String islandId) async {
    final client = _clientProvider.client;
    if (client == null) {
      throw StateError('로그인이 필요합니다.');
    }

    final response = await client.rpc(
      'get_my_favorite_photos',
      params: {'target_island_id': islandId},
    );

    return List<Map<String, dynamic>>.from(
      (response as List<dynamic>).map(
        (row) => Map<String, dynamic>.from(row as Map),
      ),
    );
  }

  Future<bool> toggleFavoritePhoto({
    required String islandId,
    required String photoKey,
  }) async {
    final client = _clientProvider.client;
    if (client == null) {
      throw StateError('로그인이 필요합니다.');
    }

    final response = await client.rpc(
      'toggle_favorite_photo',
      params: {
        'target_island_id': islandId,
        'target_photo_key': photoKey,
      },
    );

    return response == true;
  }

  Future<void> updateFriendPhotoDescriptions({
    required List<String> photoIds,
    required String? description,
  }) async {
    final client = _clientProvider.client;
    if (client == null || photoIds.isEmpty) {
      throw StateError('로그인이 필요합니다.');
    }

    await client
        .from('friend_photos')
        .update({
          'description': description?.trim().isEmpty == true ? null : description?.trim(),
        })
        .inFilter('id', photoIds);
  }

  Future<void> deleteFriendPhotos({
    required List<String> photoIds,
    required List<String> imageUrls,
  }) async {
    final client = _clientProvider.client;
    if (client == null || photoIds.isEmpty) {
      throw StateError('로그인이 필요합니다.');
    }

    await client.from('friend_photos').delete().inFilter('id', photoIds);

    final storagePaths = imageUrls
        .map(_storagePathFromFriendPhotoUrl)
        .whereType<String>()
        .toList();

    if (storagePaths.isNotEmpty) {
      try {
        await client.storage.from(_friendPhotosBucket).remove(storagePaths);
      } catch (_) {
        // Keep DB deletion even if storage cleanup partially fails.
      }
    }
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
        return 'image/jpeg';
      default:
        return 'application/octet-stream';
    }
  }

  String? _storagePathFromFriendPhotoUrl(String imageUrl) {
    if (imageUrl.isEmpty) {
      return null;
    }

    const marker = '/storage/v1/object/public/$_friendPhotosBucket/';
    final index = imageUrl.indexOf(marker);
    if (index == -1) {
      return null;
    }

    return imageUrl.substring(index + marker.length);
  }
}

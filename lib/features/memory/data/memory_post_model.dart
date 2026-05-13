class MemoryPostModel {
  MemoryPostModel({
    required this.name,
    required this.profileImage,
    required this.createdAt,
    required this.images,
  });

  final String name;
  final String profileImage;
  final String createdAt;
  final List<String> images;
}

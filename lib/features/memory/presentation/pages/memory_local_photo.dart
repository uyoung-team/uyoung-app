class MemoryLocalPhoto {
  const MemoryLocalPhoto({
    this.id,
    required this.path,
    required this.createdAt,
    required this.uploaderName,
    required this.isLocalFile,
    this.description,
    this.uploaderProfile,
    this.takenAt,
    this.latitude,
    this.longitude,
    this.locationName,
  });

  final String? id;
  final String path;
  final DateTime createdAt;
  final String uploaderName;
  final bool isLocalFile;
  final String? description;
  final String? uploaderProfile;
  final DateTime? takenAt;
  final double? latitude;
  final double? longitude;
  final String? locationName;
}

class MemoryLocalPhoto {
  const MemoryLocalPhoto({
    required this.path,
    required this.createdAt,
    required this.uploaderName,
    required this.isLocalFile,
    this.uploaderProfile,
    this.takenAt,
    this.latitude,
    this.longitude,
    this.locationName,
  });

  final String path;
  final DateTime createdAt;
  final String uploaderName;
  final bool isLocalFile;
  final String? uploaderProfile;
  final DateTime? takenAt;
  final double? latitude;
  final double? longitude;
  final String? locationName;
}

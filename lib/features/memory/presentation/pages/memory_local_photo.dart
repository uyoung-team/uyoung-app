class MemoryLocalPhoto {
  const MemoryLocalPhoto({
    required this.path,
    required this.createdAt,
    required this.uploaderName,
    required this.isLocalFile,
  });

  final String path;
  final DateTime createdAt;
  final String uploaderName;
  final bool isLocalFile;
}

enum AlbumMediaKind { photo, video }

class AlbumItem {
  const AlbumItem({
    required this.id,
    required this.relativePath,
    required this.kind,
    required this.createdAt,
    this.sourcePath,
  });
  final String id;
  final String relativePath;
  final AlbumMediaKind kind;
  final DateTime createdAt;

  /// Non-null for a seeded profile photo. Locally imported media keeps its
  /// relative path and is resolved from the application documents directory.
  final String? sourcePath;
}

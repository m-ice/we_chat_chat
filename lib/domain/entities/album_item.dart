enum AlbumMediaKind { photo, video }

class AlbumItem {
  const AlbumItem({
    required this.id,
    required this.relativePath,
    required this.kind,
    required this.createdAt,
  });
  final String id;
  final String relativePath;
  final AlbumMediaKind kind;
  final DateTime createdAt;
}

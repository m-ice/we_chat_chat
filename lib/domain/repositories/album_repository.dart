import '../entities/album_item.dart';

abstract interface class AlbumRepository {
  List<AlbumItem> get photos;
  List<AlbumItem> get videos;
  Future<int> importFiles(List<String> sourcePaths, AlbumMediaKind kind);
  Future<void> remove(Set<String> ids, AlbumMediaKind kind);
  Future<String> fullPath(AlbumItem item);
}

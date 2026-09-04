import '../entities/album_item.dart';

abstract interface class AlbumRepository {
  List<AlbumItem> get photos;
  List<AlbumItem> get videos;
  bool get hasProfilePhotoOverrides;

  /// Returns the one photo collection used by the current user's public
  /// profile and the My Album screen.
  Future<List<AlbumItem>> profilePhotos({
    required int userId,
    required List<String> seedPhotoPaths,
    required String avatarPath,
  });

  Future<int> importFiles(List<String> sourcePaths, AlbumMediaKind kind);
  Future<void> remove(Set<String> ids, AlbumMediaKind kind);
  Future<void> removeProfilePhotos({
    required int userId,
    required Set<String> ids,
  });
  Future<String> fullPath(AlbumItem item);
}

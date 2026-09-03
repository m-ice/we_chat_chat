import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/album_item.dart';
import '../../domain/repositories/album_repository.dart';

class AlbumRepositoryImpl implements AlbumRepository {
  AlbumRepositoryImpl(this._preferences);
  static const storageKey = 'mt_album_store_model';
  final SharedPreferences _preferences;

  Map<String, dynamic> get _store {
    final raw = _preferences.getString(storageKey);
    if (raw == null) return {'mtPhotos': <dynamic>[], 'mtVideos': <dynamic>[]};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } on Object {
      return {'mtPhotos': <dynamic>[], 'mtVideos': <dynamic>[]};
    }
  }

  List<AlbumItem> _items(String key) => (_store[key] as List? ?? const [])
      .whereType<Map<String, dynamic>>()
      .map(
        (json) => AlbumItem(
          id: json['mtId'] as String,
          relativePath: json['mtRelativePath'] as String,
          kind: json['mtKind'] == 'mtVideo'
              ? AlbumMediaKind.video
              : AlbumMediaKind.photo,
          createdAt: DateTime.fromMillisecondsSinceEpoch(
            ((json['mtCreatedAt'] as num) * 1000).round(),
          ),
        ),
      )
      .toList();

  @override
  List<AlbumItem> get photos => _items('mtPhotos');
  @override
  List<AlbumItem> get videos => _items('mtVideos');

  @override
  Future<int> importFiles(List<String> sourcePaths, AlbumMediaKind kind) async {
    if (sourcePaths.isEmpty) return 0;
    final documents = await getApplicationDocumentsDirectory();
    final store = _store;
    final key = kind == AlbumMediaKind.photo ? 'mtPhotos' : 'mtVideos';
    final current = List<dynamic>.from(store[key] as List? ?? const []);
    var count = 0;
    for (final source in sourcePaths) {
      final id = '${DateTime.now().microsecondsSinceEpoch}_$count';
      final relative = kind == AlbumMediaKind.photo
          ? 'album/photos/photo_$id.jpg'
          : 'album/videos/video_$id.mp4';
      try {
        final target = File('${documents.path}/$relative');
        await target.parent.create(recursive: true);
        await File(source).copy(target.path);
        current.add({
          'mtId': id,
          'mtRelativePath': relative,
          'mtKind': kind == AlbumMediaKind.photo ? 'mtPhoto' : 'mtVideo',
          'mtCreatedAt': DateTime.now().millisecondsSinceEpoch / 1000,
        });
        count++;
      } on FileSystemException {
        continue;
      }
    }
    if (count > 0) {
      store[key] = current;
      await _preferences.setString(storageKey, jsonEncode(store));
    }
    return count;
  }

  @override
  Future<void> remove(Set<String> ids, AlbumMediaKind kind) async {
    if (ids.isEmpty) return;
    final store = _store;
    final key = kind == AlbumMediaKind.photo ? 'mtPhotos' : 'mtVideos';
    final current = List<Map<String, dynamic>>.from(
      (store[key] as List? ?? const []).map(
        (item) => Map<String, dynamic>.from(item as Map),
      ),
    );
    final documents = await getApplicationDocumentsDirectory();
    for (final item in current.where((item) => ids.contains(item['mtId']))) {
      final file = File('${documents.path}/${item['mtRelativePath']}');
      if (file.existsSync()) await file.delete();
    }
    current.removeWhere((item) => ids.contains(item['mtId']));
    store[key] = current;
    await _preferences.setString(storageKey, jsonEncode(store));
  }

  @override
  Future<String> fullPath(AlbumItem item) async =>
      '${(await getApplicationDocumentsDirectory()).path}/${item.relativePath}';
}

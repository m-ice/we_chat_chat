import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_chat_chat/data/repositories/album_repository_impl.dart';
import 'package:we_chat_chat/domain/entities/album_item.dart';

void main() {
  test('restores the exact iOS album store schema', () async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({
      'mt_album_store_model': jsonEncode({
        'mtPhotos': [
          {
            'mtId': 'photo-1',
            'mtRelativePath': 'album/photos/photo_photo-1.jpg',
            'mtKind': 'mtPhoto',
            'mtCreatedAt': 1788364800.0,
          },
        ],
        'mtVideos': [
          {
            'mtId': 'video-1',
            'mtRelativePath': 'album/videos/video_video-1.mp4',
            'mtKind': 'mtVideo',
            'mtCreatedAt': 1788364801.0,
          },
        ],
      }),
    });
    final album = AlbumRepositoryImpl(await SharedPreferences.getInstance());

    expect(album.photos.single.kind, AlbumMediaKind.photo);
    expect(album.photos.single.id, 'photo-1');
    expect(album.videos.single.kind, AlbumMediaKind.video);
    expect(album.videos.single.id, 'video-1');
  });
}

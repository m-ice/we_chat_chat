import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/square_feed.dart';
import '../../domain/repositories/my_world_repository.dart';
import '../../domain/repositories/social_state_repository.dart';
import '../../domain/repositories/square_repository.dart';
import '../../domain/repositories/user_repository.dart';

class SquareRepositoryImpl implements SquareRepository {
  SquareRepositoryImpl(
    this._users,
    this._world,
    this._social,
    this._preferences,
  );
  static const likedKey = 'mt_square_liked_post_ids';
  final UserRepository _users;
  final MyWorldRepository _world;
  final SocialStateRepository _social;
  final SharedPreferences _preferences;

  @override
  Set<String> get likedPostIds =>
      (_preferences.getStringList(likedKey) ?? const []).toSet();
  @override
  Future<void> setLiked(String postId, bool value) async {
    final ids = likedPostIds;
    value ? ids.add(postId) : ids.remove(postId);
    await _preferences.setStringList(likedKey, ids.toList()..sort());
  }

  Future<List<SquareFeedItem>> _all() async {
    final users = await _users.getUsers();
    final current = await _users.getCurrentUser();
    await _world.refreshReviewStatuses();
    final items = <SquareFeedItem>[
      for (final user in users)
        if (user.id != current.id)
          if (user.moment case final moment?)
            if (moment.content.trim().isNotEmpty)
              SquareFeedItem(
                postId: 'moment_${user.id}',
                user: user,
                content: moment.content,
                imagePaths: moment.imagePaths,
                time: _format(moment.createdAt),
                usesSandboxImages: false,
              ),
    ];
    items.sort((a, b) => b.time.compareTo(a.time));
    return items;
  }

  @override
  Future<List<SquareFeedItem>> recommended() async {
    final excluded = {..._social.blockedIds, ..._social.shieldedIds};
    return (await _all())
        .where((item) => !excluded.contains(item.user.id))
        .toList();
  }

  @override
  Future<List<SquareFeedItem>> following() async => (await recommended())
      .where((item) => _social.followedIds.contains(item.user.id))
      .toList();

  @override
  Future<List<TopicItem>> topics() async {
    final map = <String, TopicItem>{};
    final current = await _users.getCurrentUser();
    final shieldedActivities = _social.shieldedActivityIds;
    for (final user in await _users.getUsers()) {
      final post = user.teamPost;
      if (post == null ||
          user.id == current.id ||
          shieldedActivities.contains(post.id) ||
          post.isExpired(DateTime.now()) ||
          map.containsKey(post.activity)) {
        continue;
      }
      map[post.activity] = TopicItem(
        id: post.activity,
        title: '#${post.activity}',
        subtitle: post.location,
        coverPath: post.imagePaths.firstOrNull ?? user.avatarPath,
        category: _category(post.activity, user.hobbies),
      );
    }
    final result = map.values.toList()
      ..sort((a, b) => a.title.compareTo(b.title));
    return result;
  }

  @override
  Future<List<String>> resolvedImages(SquareFeedItem item) async {
    if (!item.usesSandboxImages) return item.imagePaths;
    final documents = await getApplicationDocumentsDirectory();
    return item.imagePaths.map((path) => '${documents.path}/$path').toList();
  }

  String _format(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  String _category(String activity, List<String> hobbies) {
    if (activity.contains('骑行') ||
        activity.contains('爬山') ||
        hobbies.any((v) => v.contains('户外'))) {
      return '户外';
    }
    if (activity.contains('密室') || activity.contains('吃饭')) {
      return '休闲';
    }
    return '推荐';
  }
}

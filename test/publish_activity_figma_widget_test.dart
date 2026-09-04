import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_chat_chat/core/widgets/app_image.dart';
import 'package:we_chat_chat/domain/entities/my_world_post.dart';
import 'package:we_chat_chat/domain/entities/published_team_post.dart';
import 'package:we_chat_chat/domain/entities/user.dart';
import 'package:we_chat_chat/domain/entities/city_user.dart';
import 'package:we_chat_chat/domain/policies/feature_access_gate.dart';
import 'package:we_chat_chat/domain/repositories/my_world_repository.dart';
import 'package:we_chat_chat/domain/repositories/social_state_repository.dart';
import 'package:we_chat_chat/domain/repositories/team_publish_repository.dart';
import 'package:we_chat_chat/domain/repositories/team_detail_repository.dart';
import 'package:we_chat_chat/domain/repositories/user_repository.dart';
import 'package:we_chat_chat/domain/entities/team_detail_comment.dart';
import 'package:we_chat_chat/domain/entities/team_activity_join_result.dart';
import 'package:we_chat_chat/domain/entities/team_detail_seed_state.dart';
import 'package:we_chat_chat/modules/home/team_detail/team_detail_controller.dart';
import 'package:we_chat_chat/modules/home/team_detail/team_detail_page.dart';
import 'package:we_chat_chat/modules/home/team_publish/team_flow_assets.dart';
import 'package:we_chat_chat/modules/home/team_publish/team_publish_controller.dart';
import 'package:we_chat_chat/modules/home/team_publish/team_publish_page.dart';
import 'package:we_chat_chat/modules/profile/controllers/my_world_controller.dart';
import 'package:we_chat_chat/modules/profile/views/my_world_publish_page.dart';

import 'helpers/test_app.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(Get.reset);

  testWidgets('team publish starts with user-selectable image slots only', (
    tester,
  ) async {
    _setFigmaViewport(tester);
    final preferences = await SharedPreferences.getInstance();
    Get.put(
      TeamPublishController(
        _FakeTeamPublishRepository(),
        const FreeFeatureAccessGate(),
        preferences,
      ),
    );

    await tester.pumpWidget(_app(const TeamPublishPage()));
    await tester.pumpAndSettle();

    expect(find.text('创建搭子'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('team-publish-main-card'))),
      const Size(343, 327),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('team-publish-detail-card'))),
      const Size(343, 170),
    );
    expect(_asset(TeamFlowAssets.publishSampleBadminton), findsNothing);
    expect(_asset(TeamFlowAssets.publishSampleCourt), findsNothing);
    expect(find.text('选择照片'), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('activity detail scrolls its Figma action after three comments', (
    tester,
  ) async {
    _setFigmaViewport(tester);
    final user = User(
      id: 7,
      nickname: '用户昵称',
      age: 24,
      gender: '女',
      hobbies: const ['美食'],
      avatarPath: TeamFlowAssets.detailCommentAvatar,
      intro: '休闲娱乐，放松一下',
      isVerified: true,
      isSeedData: true,
      teamPost: TeamPost(
        imagePaths: const [],
        activity: '约咖啡',
        location: '深圳市｜宝安区',
        date: DateTime(2026, 12, 12, 12),
        content: '美食探店\n休闲娱乐，放松一下',
      ),
    );
    Get.put(
      TeamDetailController(
        user,
        user.teamPost!,
        _FakeSocialStateRepository(),
        const FreeFeatureAccessGate(),
        _FakeTeamDetailRepository(),
        _FakeUserRepository(),
      ),
    );

    await tester.pumpWidget(_app(const TeamDetailPage()));
    await tester.pumpAndSettle();

    expect(find.text('我要报名，我也想去！！！'), findsNWidgets(3));
    expect(find.text('打招呼'), findsNothing);
    expect(find.text('活动攻略与教程'), findsNothing);
    final chat = find.byKey(const ValueKey('team-detail-chat'));
    expect(tester.getTopLeft(chat).dy, greaterThan(812));

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(chat).dy, lessThan(812));
    expect(tester.takeException(), isNull);
  });

  testWidgets('dynamic publishing starts without unselected sample photos', (
    tester,
  ) async {
    _setFigmaViewport(tester);
    final controller = MyWorldPublishController(_FakeMyWorldRepository());
    Get.put(controller);

    await tester.pumpWidget(_app(const MyWorldPublishPage()));
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byKey(const ValueKey('my-world-publish-panel'))),
      const Size(343, 327),
    );
    expect(_asset(TeamFlowAssets.publishSampleBadminton), findsNothing);
    expect(_asset(TeamFlowAssets.publishSampleCourt), findsNothing);
    expect(find.text('选择照片'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('my-world-publish-content')),
      '今天也要记录有趣的生活',
    );
    expect(controller.content.text, '今天也要记录有趣的生活');
    expect(tester.takeException(), isNull);
  });
}

class _FakeTeamDetailRepository implements TeamDetailRepository {
  @override
  Future<void> addComment(String activityId, TeamDetailComment comment) async {}

  @override
  Future<TeamActivityJoinResult> joinActivity(
    String activityId,
    int userId,
  ) async => TeamActivityJoinResult.joined;

  @override
  Future<List<TeamDetailComment>> getComments(
    String activityId, {
    int? legacyOwnerId,
  }) async => List.filled(
    3,
    const TeamDetailComment(
      authorId: 1,
      nickname: '用户昵称',
      avatarPath: '',
      content: '我要报名，我也想去！！！',
    ),
  );

  @override
  Future<TeamDetailSeedState> getSeedState(
    String activityId, {
    int? legacyOwnerId,
  }) async => const TeamDetailSeedState(
    participantTotal: 4,
    participantCount: 3,
    participantAvatarPaths: [
      TeamFlowAssets.detailParticipant1,
      TeamFlowAssets.detailParticipant2,
    ],
  );
}

Widget _app(Widget home) => buildTestApp(home);

void _setFigmaViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1125, 2436);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Finder _asset(String source) => find.byWidgetPredicate(
  (widget) => widget is AppImage && widget.source == source,
);

class _FakeTeamPublishRepository implements TeamPublishRepository {
  @override
  List<PublishedTeamPost> get approvedPosts => const [];

  @override
  List<PublishedTeamPost> get pendingPosts => const [];

  @override
  List<PublishedTeamPost> get posts => const [];

  @override
  Future<bool> publish({
    required String activity,
    required String location,
    required String date,
    required String content,
    required String contact,
    required List<String> imageSourcePaths,
  }) async => true;
}

class _FakeSocialStateRepository implements SocialStateRepository {
  @override
  Set<int> get blockedIds => const {};

  @override
  Stream<void> get changes => Stream<void>.empty();

  @override
  Set<int> get followedIds => const {};

  @override
  Set<int> get invitedIds => const {};

  @override
  Set<int> get pendingJoinIds => const {};

  @override
  Set<int> get shieldedIds => const {};

  @override
  Set<String> get shieldedActivityIds => const {};

  @override
  Future<void> block(int userId) async {}

  @override
  Future<void> setFollowed(int userId, bool value) async {}

  @override
  Future<void> setInvited(int userId, bool value) async {}

  @override
  Future<void> setPendingJoin(int userId, bool value) async {}

  @override
  Future<void> shield(int userId) async {}

  @override
  Future<void> shieldActivity(String activityId) async {}

  @override
  Future<void> unblock(int userId) async {}
}

class _FakeUserRepository implements UserRepository {
  @override
  Future<List<CityUser>> getCityUsers() async => const [];

  @override
  Future<User> getCurrentUser() async => const User(
    id: 1,
    nickname: '当前用户',
    age: 24,
    gender: '女',
    hobbies: [],
    avatarPath: '',
    intro: '',
    isVerified: false,
  );

  @override
  Future<List<User>> getUsers() async => const [];

  @override
  Future<List<CityUser>> getVerifiedUsers() async => const [];
}

class _FakeMyWorldRepository implements MyWorldRepository {
  @override
  List<MyWorldPost> get posts => const [];

  @override
  Future<void> refreshReviewStatuses() async {}

  @override
  Future<List<String>> fullImagePaths(MyWorldPost post) async => const [];

  @override
  Future<void> addComment(String id, String content) async {}

  @override
  Future<bool> publish({
    required String content,
    required List<String> imageSourcePaths,
    required List<String> topics,
  }) async => true;

  @override
  Future<void> remove(String id) async {}

  @override
  Future<void> setLiked(String id, bool liked) async {}
}

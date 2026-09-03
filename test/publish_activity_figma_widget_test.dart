import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_chat_chat/core/widgets/app_image.dart';
import 'package:we_chat_chat/domain/entities/membership.dart';
import 'package:we_chat_chat/domain/entities/my_world_post.dart';
import 'package:we_chat_chat/domain/entities/published_team_post.dart';
import 'package:we_chat_chat/domain/entities/user.dart';
import 'package:we_chat_chat/domain/repositories/membership_wallet_repository.dart';
import 'package:we_chat_chat/domain/repositories/my_world_repository.dart';
import 'package:we_chat_chat/domain/repositories/social_state_repository.dart';
import 'package:we_chat_chat/domain/repositories/team_publish_repository.dart';
import 'package:we_chat_chat/l10n/app_translations.dart';
import 'package:we_chat_chat/modules/home/team_detail/team_detail_controller.dart';
import 'package:we_chat_chat/modules/home/team_detail/team_detail_page.dart';
import 'package:we_chat_chat/modules/home/team_publish/team_flow_assets.dart';
import 'package:we_chat_chat/modules/home/team_publish/team_publish_controller.dart';
import 'package:we_chat_chat/modules/home/team_publish/team_publish_page.dart';
import 'package:we_chat_chat/modules/profile/controllers/my_world_controller.dart';
import 'package:we_chat_chat/modules/profile/views/my_world_publish_page.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(Get.reset);

  testWidgets('team publish keeps the two Figma cards and image strip sizes', (
    tester,
  ) async {
    _setFigmaViewport(tester);
    final preferences = await SharedPreferences.getInstance();
    Get.put(
      TeamPublishController(
        _FakeTeamPublishRepository(),
        _FakeWalletRepository(),
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
    expect(_asset(TeamFlowAssets.publishSampleBadminton), findsOneWidget);
    expect(_asset(TeamFlowAssets.publishSampleCourt), findsOneWidget);
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
        _FakeSocialStateRepository(),
        _FakeWalletRepository(),
      ),
    );

    await tester.pumpWidget(_app(const TeamDetailPage()));
    await tester.pumpAndSettle();

    expect(find.text('我要报名，我也想去！！！'), findsNWidgets(3));
    expect(find.text('活动攻略与教程'), findsNothing);
    final chat = find.byKey(const ValueKey('team-detail-chat'));
    expect(tester.getTopLeft(chat).dy, greaterThan(812));

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(chat).dy, lessThan(812));
    expect(tester.takeException(), isNull);
  });

  testWidgets('publish post starts with the Figma photo composition', (
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
    expect(_asset(TeamFlowAssets.publishSampleBadminton), findsOneWidget);
    expect(_asset(TeamFlowAssets.publishSampleCourt), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('my-world-publish-content')),
      '今天也要记录有趣的生活',
    );
    expect(controller.content.text, '今天也要记录有趣的生活');
    expect(tester.takeException(), isNull);
  });
}

Widget _app(Widget home) => GetMaterialApp(
  translations: AppTranslations(),
  locale: const Locale('zh', 'CN'),
  home: home,
);

void _setFigmaViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1125, 2436);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Finder _asset(String source) => find.byWidgetPredicate(
  (widget) => widget is AppImage && widget.source == source,
);

class _FakeWalletRepository implements MembershipWalletRepository {
  @override
  int get coinBalance => 0;

  @override
  bool get isVipActive => true;

  @override
  Membership? get membership => null;

  @override
  String get vipStatusText => '';

  @override
  Future<void> activateVip({
    required String productId,
    required int durationDays,
  }) async {}

  @override
  Future<void> addCoins(int amount) async {}

  @override
  Future<bool> spendCoins(int amount) async => true;
}

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
  Set<int> get followedIds => const {};

  @override
  Set<int> get invitedIds => const {};

  @override
  Set<int> get pendingJoinIds => const {};

  @override
  Set<int> get shieldedIds => const {};

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
}

class _FakeMyWorldRepository implements MyWorldRepository {
  @override
  List<MyWorldPost> get posts => const [];

  @override
  Future<List<String>> fullImagePaths(MyWorldPost post) async => const [];

  @override
  Future<bool> publish({
    required String content,
    required List<String> imageSourcePaths,
    required List<String> topics,
  }) async => true;

  @override
  Future<void> remove(String id) async {}
}

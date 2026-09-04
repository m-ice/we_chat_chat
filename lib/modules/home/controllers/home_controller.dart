import 'dart:async';

import 'package:draggable_float_widget/draggable_float_widget.dart';
import 'package:get/get.dart';

import '../../../app/routes/routes.dart';
import '../../../core/widgets/app_activity_join_confirmation.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../domain/entities/city_user.dart';
import '../../../domain/entities/city_user_mapper.dart';
import '../../../domain/entities/team_activity_join_result.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/home_city_repository.dart';
import '../../../domain/policies/feature_access_gate.dart';
import '../../../domain/repositories/social_state_repository.dart';
import '../../../domain/repositories/team_detail_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../team_detail/team_detail_controller.dart';

enum HomeFeedTab { nearby }

class HomeController extends GetxController {
  HomeController(
    this._users,
    this._cities,
    this._social,
    this._access,
    this._details,
  );

  final UserRepository _users;
  final HomeCityRepository _cities;
  final SocialStateRepository _social;
  final FeatureAccessGate _access;
  final TeamDetailRepository _details;

  final selectedCity = '全部'.obs;
  final activityUsers = <User>[].obs;
  final nearbyUsers = <CityUser>[].obs;
  final newcomerUsers = <CityUser>[].obs;
  final followedIds = <int>{}.obs;
  final activityParticipantAvatarPaths = <String, List<String>>{}.obs;
  final hasError = false.obs;

  late StreamController<OperateEvent> eventStreamController;
  StreamSubscription<void>? _socialChangesSubscription;
  int _loadRevision = 0;

  @override
  void onInit() {
    super.onInit();
    eventStreamController = StreamController.broadcast();
    selectedCity.value = _cities.selectedCity;
    followedIds.assignAll(_social.followedIds);
    _socialChangesSubscription = _social.changes.listen((_) {
      unawaited(load());
    });
    load();
  }

  @override
  void onClose() {
    _socialChangesSubscription?.cancel();
    eventStreamController.close();
    super.onClose();
  }

  Future<void> load() async {
    final revision = ++_loadRevision;
    hasError.value = false;
    try {
      final results = await Future.wait([
        _users.getUsers(),
        _users.getCityUsers(),
        _users.getVerifiedUsers(),
        _users.getCurrentUser(),
      ]);
      final city = selectedCity.value;
      final allRegions = city == '全部';
      final excluded = {..._social.blockedIds, ..._social.shieldedIds};
      final shieldedActivities = _social.shieldedActivityIds;
      final currentUserId = (results[3] as User).id;
      final allUsers = results[0] as List<User>;
      final matchingActivities = allUsers
          .where(
            (user) =>
                !excluded.contains(user.id) &&
                user.id != currentUserId &&
                user.teamPost != null &&
                !shieldedActivities.contains(user.teamPost!.id) &&
                (allRegions ||
                    user.teamPost!.location.contains(city) ||
                    user.teamPost!.content.contains(city)),
          )
          .toList();
      final upcomingActivities = matchingActivities
          .where((user) => !user.teamPost!.isExpired(DateTime.now()))
          .toList();
      final participantAvatars = await _loadActivityParticipantAvatars(
        upcomingActivities,
        allUsers,
      );
      if (revision != _loadRevision) return;
      activityUsers.assignAll(upcomingActivities);
      activityParticipantAvatarPaths.assignAll(participantAvatars);
      nearbyUsers.assignAll(
        (results[1] as List<CityUser>).where(
          (user) =>
              !excluded.contains(user.id) &&
              user.id != currentUserId &&
              (allRegions || user.city == city),
        ),
      );
      newcomerUsers.assignAll(
        (results[2] as List<CityUser>).where(
          (user) =>
              !excluded.contains(user.id) &&
              user.id != currentUserId &&
              (allRegions || user.city == city),
        ),
      );
    } on Object {
      if (revision != _loadRevision) return;
      hasError.value = true;
    }
  }

  Future<Map<String, List<String>>> _loadActivityParticipantAvatars(
    List<User> activityOwners,
    List<User> allUsers,
  ) async {
    final usersById = {for (final user in allUsers) user.id: user};
    final entries = await Future.wait<MapEntry<String, List<String>>>(
      activityOwners.map<Future<MapEntry<String, List<String>>>>((owner) async {
        final post = owner.teamPost;
        if (post == null) return MapEntry<String, List<String>>('', const []);
        try {
          final state = await _details.getSeedState(
            post.id,
            legacyOwnerId: post.ownerId,
          );
          final paths = <String>[];
          for (final userId in state.participantUserIds) {
            final path = usersById[userId]?.avatarPath;
            if (path != null && path.isNotEmpty && !paths.contains(path)) {
              paths.add(path);
            }
          }
          return MapEntry(post.id, List.unmodifiable(paths));
        } on Object {
          return MapEntry(post.id, const <String>[]);
        }
      }),
    );
    return Map.unmodifiable(
      Map<String, List<String>>.fromEntries(
        entries.where((entry) => entry.key.isNotEmpty),
      ),
    );
  }

  Future<void> applySelectedCity(String city) async {
    selectedCity.value = city;
    await load();
  }

  Future<User> resolveUser(CityUser cityUser) async {
    final cached = activityUsers.where((user) => user.id == cityUser.id);
    if (cached.isNotEmpty) return cached.first;
    final users = await _users.getUsers();
    final matches = users.where((user) => user.id == cityUser.id);
    return matches.isEmpty ? cityUser.toUser() : matches.first;
  }

  Future<void> openUser(CityUser cityUser) async {
    final user = await resolveUser(cityUser);
    await Get.toNamed(
      Routes.userDetail,
      arguments: <String, Object>{'userId': user.id, 'user': user},
    );
  }

  Future<Object?> openActivity(User user) async {
    final post = user.teamPost;
    if (post == null) return null;
    final result = await Get.toNamed(
      Routes.teamDetail,
      arguments: TeamDetailArguments(user: user, post: post),
    );
    return result is HomeFeedTab ? result : null;
  }

  Future<void> toggleFollow(int userId) async {
    final next = Set<int>.from(followedIds);
    next.contains(userId) ? next.remove(userId) : next.add(userId);
    followedIds.assignAll(next);
    final followed = next.contains(userId);
    await _social.setFollowed(userId, followed);
    AppToast.show(followed ? 'social_followed'.tr : 'social_unfollowed'.tr);
  }

  Future<void> join(User user) async {
    if (user.teamPost?.isExpired(DateTime.now()) ?? true) {
      AppToast.show('team_activity_ended'.tr);
      await load();
      return;
    }
    final post = user.teamPost;
    if (post == null) return;
    if (!await AppActivityJoinConfirmation.show(post.activity)) return;
    if (!await _access.request(FeatureAccess.activityJoin)) return;
    final currentUser = await _users.getCurrentUser();
    final result = await _details.joinActivity(post.id, currentUser.id);
    switch (result) {
      case TeamActivityJoinResult.joined:
        await load();
        AppToast.show('team_joined'.trParams({'name': post.activity}));
        return;
      case TeamActivityJoinResult.alreadyJoined:
        await load();
        return;
      case TeamActivityJoinResult.full:
        AppToast.show('team_join_full'.tr);
        return;
      case TeamActivityJoinResult.unavailable:
        AppToast.show('common_save_failed'.tr);
        return;
    }
  }
}

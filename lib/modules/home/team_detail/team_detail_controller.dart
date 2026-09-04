import 'package:get/get.dart';

import '../../../domain/entities/user.dart';
import '../../../domain/entities/team_activity_join_result.dart';
import '../../../domain/entities/team_detail_comment.dart';
import '../../../domain/entities/team_detail_seed_state.dart';
import '../../../domain/policies/feature_access_gate.dart';
import '../../../domain/repositories/social_state_repository.dart';
import '../../../domain/repositories/team_detail_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../app/routes/routes.dart';
import '../../../core/widgets/app_activity_join_confirmation.dart';
import '../../../core/widgets/app_toast.dart';
import '../../shared/actions/user_actions_sheet.dart';
import '../../shared/report/report_controller.dart';

class TeamDetailArguments {
  const TeamDetailArguments({required this.user, required this.post});

  final User user;
  final TeamPost post;
}

class TeamMembersArguments {
  TeamMembersArguments({required List<User> users})
    : users = List.unmodifiable(users);

  final List<User> users;
}

enum TeamDetailResult { activityShielded }

class TeamDetailController extends GetxController {
  TeamDetailController(
    this.user,
    this.post,
    this._social,
    this._access,
    this._details,
    this._users,
  );

  final User user;
  final TeamPost post;
  final SocialStateRepository _social;
  final FeatureAccessGate _access;
  final TeamDetailRepository _details;
  final UserRepository _users;
  final comments = <TeamDetailComment>[].obs;
  final participantTotal = 0.obs;
  final baseParticipantCount = 0.obs;
  final participantAvatarPaths = <String>[].obs;
  final participantUsers = <User>[].obs;
  final isCurrentUserParticipant = false.obs;
  final currentUserId = RxnInt();

  bool get expired => post.isExpired(DateTime.now());
  int get participantCount =>
      baseParticipantCount.value.clamp(0, participantTotal.value).toInt();

  @override
  void onInit() {
    super.onInit();
    reload();
  }

  Future<void> reload() async {
    await Future.wait([_loadComments(), _loadSeedState()]);
  }

  Future<void> _loadComments() async {
    try {
      comments.assignAll(
        await _details.getComments(post.id, legacyOwnerId: _ownerId),
      );
    } on Object {
      comments.clear();
    }
  }

  Future<void> _loadSeedState() async {
    try {
      final result = await Future.wait([
        _details.getSeedState(post.id, legacyOwnerId: _ownerId),
        _users.getUsers(),
        _users.getCurrentUser(),
      ]);
      final state = result[0] as TeamDetailSeedState;
      final users = result[1] as List<User>;
      final currentUser = result[2] as User;
      final usersById = {for (final user in users) user.id: user};
      final members = <User>[];
      for (final userId in state.participantUserIds) {
        final member = usersById[userId];
        if (member != null && !members.any((user) => user.id == member.id)) {
          members.add(member);
        }
      }
      participantTotal.value = state.participantTotal;
      baseParticipantCount.value = state.participantCount;
      currentUserId.value = currentUser.id;
      participantUsers.assignAll(members);
      isCurrentUserParticipant.value = members.any(
        (user) => user.id == currentUser.id,
      );
      participantAvatarPaths.assignAll(
        members.isEmpty
            ? state.participantAvatarPaths
            : members.map((user) => user.avatarPath),
      );
    } on Object {
      participantTotal.value = 0;
      baseParticipantCount.value = 0;
      participantAvatarPaths.clear();
      participantUsers.clear();
      isCurrentUserParticipant.value = false;
      currentUserId.value = null;
    }
  }

  Future<void> join() async {
    if (isCurrentUserParticipant.value) {
      await _openMembers();
      return;
    }
    if (expired) {
      AppToast.show('team_activity_ended'.tr);
      return;
    }
    if (!await AppActivityJoinConfirmation.show(post.activity)) return;
    if (!await _access.request(FeatureAccess.activityJoin)) return;
    final currentUser = await _users.getCurrentUser();
    final result = await _details.joinActivity(post.id, currentUser.id);
    switch (result) {
      case TeamActivityJoinResult.joined:
        await _loadSeedState();
        AppToast.show('team_joined'.trParams({'name': post.activity}));
        return;
      case TeamActivityJoinResult.alreadyJoined:
        await _loadSeedState();
        await _openMembers();
        return;
      case TeamActivityJoinResult.full:
        AppToast.show('team_join_full'.tr);
        return;
      case TeamActivityJoinResult.unavailable:
        AppToast.show('common_save_failed'.tr);
        return;
    }
  }

  Future<void> addComment(String content) async {
    final value = content.trim();
    if (value.isEmpty) return;
    final author = await _users.getCurrentUser();
    final comment = TeamDetailComment(
      authorId: author.id,
      nickname: author.nickname,
      avatarPath: author.avatarPath,
      content: value,
    );
    await _details.addComment(post.id, comment);
    comments.insert(0, comment);
    AppToast.show('team_comment_posted'.tr);
  }

  Future<void> openChat() async {
    if (await _isCurrentUser()) return;
    await Get.toNamed(Routes.chat, arguments: user);
  }

  bool canChatWithCommentAuthor(TeamDetailComment comment) {
    final authorId = comment.authorId;
    return authorId != null && authorId != currentUserId.value;
  }

  Future<void> openCommentAuthorChat(TeamDetailComment comment) async {
    final authorId = comment.authorId;
    if (authorId == null || authorId == currentUserId.value) return;
    final currentUser = await _users.getCurrentUser();
    if (currentUser.id == authorId) return;
    final users = await _users.getUsers();
    final matches = users.where((user) => user.id == authorId);
    if (matches.isEmpty) return;
    await Get.toNamed(Routes.chat, arguments: matches.first);
  }

  Future<void> openActions() => showUserActionsSheet(
    primaryLabel: 'common_shield'.tr,
    onBlock: () async {
      await _social.shieldActivity(post.id);
      AppToast.show('social_shielded'.trParams({'name': post.activity}));
      Get.back<TeamDetailResult>(result: TeamDetailResult.activityShielded);
    },
    onReport: () => Get.toNamed(
      Routes.report,
      arguments: ReportArguments(target: user, targetActivityId: post.id),
    ),
  );

  int get _ownerId => post.ownerId == 0 ? user.id : post.ownerId;

  Future<void> _openMembers() async {
    await Get.toNamed<void>(
      Routes.teamMembers,
      arguments: TeamMembersArguments(users: participantUsers),
    );
  }

  Future<bool> _isCurrentUser() async {
    try {
      return (await _users.getCurrentUser()).id == user.id;
    } on Object {
      return true;
    }
  }
}

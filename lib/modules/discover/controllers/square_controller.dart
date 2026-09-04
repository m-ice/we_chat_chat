import 'dart:async';

import 'package:draggable_float_widget/draggable_float_widget.dart';
import 'package:get/get.dart';

import '../../../app/routes/routes.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../domain/entities/square_feed.dart';
import '../../../domain/repositories/social_state_repository.dart';
import '../../../domain/repositories/square_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../shared/actions/user_actions_sheet.dart';
import '../../shared/report/report_controller.dart';

enum SquareTab { following, discover, video }

class SquareController extends GetxController {
  SquareController(this.repository, this.social, this._users);
  final SquareRepository repository;
  final SocialStateRepository social;
  final UserRepository _users;
  final tab = SquareTab.discover.obs;
  final items = <SquareFeedItem>[].obs;
  final likedIds = <String>{}.obs;
  final currentUserId = RxnInt();
  final floatingActionEvents = StreamController<OperateEvent>.broadcast();
  Timer? _reviewTimer;
  StreamSubscription<void>? _socialChangesSubscription;
  int _reloadRevision = 0;

  @override
  void onInit() {
    super.onInit();
    reload();
    _reviewTimer = Timer.periodic(const Duration(minutes: 1), (_) => reload());
    _socialChangesSubscription = social.changes.listen((_) {
      unawaited(reload());
    });
  }

  @override
  void onClose() {
    _socialChangesSubscription?.cancel();
    _reviewTimer?.cancel();
    floatingActionEvents.close();
    super.onClose();
  }

  Future<void> reload() async {
    final revision = ++_reloadRevision;
    final selectedTab = tab.value;
    int? nextCurrentUserId;
    try {
      nextCurrentUserId = (await _users.getCurrentUser()).id;
    } on Object {
      nextCurrentUserId = null;
    }
    final nextItems = selectedTab == SquareTab.following
        ? await repository.following()
        : await repository.recommended();
    if (revision != _reloadRevision) return;
    currentUserId.value = nextCurrentUserId;
    items.assignAll(nextItems);
    likedIds.assignAll(repository.likedPostIds);
  }

  Future<void> selectTab(SquareTab value) async {
    tab.value = value;
    if (value != SquareTab.video) await reload();
  }

  Future<void> toggleFollow(SquareFeedItem item) async {
    final value = !social.followedIds.contains(item.user.id);
    await social.setFollowed(item.user.id, value);
    await reload();
    AppToast.show(value ? 'social_followed'.tr : 'social_unfollowed'.tr);
  }

  Future<void> openUser(SquareFeedItem item) async {
    await Get.toNamed(
      Routes.userDetail,
      arguments: <String, Object>{'userId': item.user.id, 'user': item.user},
    );
  }

  Future<void> toggleLike(SquareFeedItem item) async {
    final liked = !likedIds.contains(item.postId);
    await repository.setLiked(item.postId, liked);
    likedIds.assignAll(repository.likedPostIds);
    AppToast.show(liked ? 'video_liked'.tr : 'video_unliked'.tr);
  }

  Future<void> preview(SquareFeedItem item, int index) async {
    final images = await repository.resolvedImages(item);
    if (images.isNotEmpty) {
      await Get.toNamed(
        Routes.imagePreview,
        arguments: {'images': images, 'index': index},
      );
    }
  }

  Future<void> previewAssets(List<String> images, int index) async {
    if (images.isEmpty) return;
    await Get.toNamed(
      Routes.imagePreview,
      arguments: {'images': images, 'index': index},
    );
  }

  Future<void> publish() async {
    await Get.toNamed(Routes.myWorldPublish);
    await reload();
  }

  Future<void> more(SquareFeedItem item) async {
    if (await _isCurrentUser(item.user.id)) return;
    await showUserActionsSheet(
      onBlock: () async {
        await social.block(item.user.id);
        await reload();
        AppToast.show('social_blocked'.trParams({'name': item.user.nickname}));
      },
      onReport: () => Get.toNamed(
        Routes.report,
        arguments: ReportArguments(
          target: item.user,
          targetDynamicId: item.postId,
        ),
      ),
    );
  }

  bool isCurrentUser(int userId) => currentUserId.value == userId;

  Future<bool> _isCurrentUser(int userId) async {
    try {
      return (await _users.getCurrentUser()).id == userId;
    } on Object {
      return true;
    }
  }
}

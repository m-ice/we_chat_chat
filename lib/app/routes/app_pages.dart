import 'package:get/get.dart';

import '../../modules/main/bindings/main_binding.dart';
import '../../modules/main/views/main_page.dart';
import '../../domain/repositories/home_city_repository.dart';
import '../../modules/home/city_picker/controllers/home_city_picker_controller.dart';
import '../../modules/home/city_picker/views/home_city_picker_page.dart';
import '../../modules/home/activity_filter/controllers/activity_filter_controller.dart';
import '../../modules/home/activity_filter/views/activity_filter_page.dart';
import '../../domain/repositories/social_state_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/user_detail_repository.dart';
import '../../domain/repositories/ai_repository.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/repositories/message_center_repository.dart';
import '../../domain/entities/user.dart';
import '../../modules/chat/controllers/conversation_controller.dart';
import '../../modules/chat/controllers/chat_thread_controller.dart';
import '../../modules/chat/views/chat_page.dart';
import '../../modules/chat/views/message_feature_pages.dart';
import '../../modules/chat/views/system_messages_page.dart';
import '../../domain/repositories/membership_wallet_repository.dart';
import '../../modules/profile/controllers/vip_controller.dart';
import '../../modules/profile/controllers/wallet_controller.dart';
import '../../modules/profile/views/coins_page.dart';
import '../../modules/profile/views/vip_page.dart';
import '../../data/providers/store_purchase_service.dart';
import '../../modules/user_detail/controllers/user_detail_controller.dart';
import '../../modules/user_detail/views/user_detail_page.dart';
import '../../modules/shared/report/report_page.dart';
import '../../modules/shared/report/report_controller.dart';
import '../../domain/repositories/report_repository.dart';
import '../../modules/shared/media/image_preview_page.dart';
import '../../modules/chat/controllers/voice_call_controller.dart';
import '../../modules/chat/views/voice_call_page.dart';
import '../../modules/home/team_detail/team_detail_controller.dart';
import '../../modules/home/team_detail/team_detail_page.dart';
import '../../modules/home/team_detail/guide_article_page.dart';
import '../../domain/entities/guide_article.dart';
import '../../domain/repositories/team_publish_repository.dart';
import '../../domain/repositories/team_detail_repository.dart';
import '../../modules/home/team_publish/team_publish_controller.dart';
import '../../modules/home/team_publish/team_publish_page.dart';
import '../../modules/home/team_publish/team_activity_picker_page.dart';
import '../../modules/home/team_publish/team_publish_review_page.dart';
import '../../modules/shared/legal/legal_web_page.dart';
import '../../domain/repositories/profile_edit_repository.dart';
import '../../modules/profile/controllers/edit_profile_controller.dart';
import '../../modules/profile/views/edit_profile_page.dart';
import '../../modules/profile/views/profile_tags_page.dart';
import '../../modules/profile/views/profile_text_edit_page.dart';
import '../../modules/profile/views/customer_service_page.dart';
import '../../domain/entities/album_item.dart';
import '../../domain/repositories/album_repository.dart';
import '../../modules/profile/controllers/album_controller.dart';
import '../../modules/profile/views/album_page.dart';
import '../../modules/profile/views/album_preview_page.dart';
import '../../domain/repositories/my_world_repository.dart';
import '../../modules/profile/controllers/my_world_controller.dart';
import '../../modules/profile/views/my_world_page.dart';
import '../../modules/profile/views/my_world_publish_page.dart';
import '../../domain/entities/square_feed.dart';
import '../../modules/discover/controllers/topic_detail_controller.dart';
import '../../modules/discover/views/topic_detail_page.dart';
import '../../domain/entities/city_user.dart';
import '../../modules/discover/controllers/video_feed_controller.dart';
import '../../modules/discover/views/center_search_page.dart';
import '../../modules/discover/views/video_feed_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'routes.dart';

abstract final class AppPages {
  static BindingsBuilder get _conversationFeatureBinding => BindingsBuilder(() {
    if (!Get.isRegistered<ConversationController>()) {
      Get.lazyPut(
        () => ConversationController(
          Get.find<ChatRepository>(),
          Get.find<MessageCenterRepository>(),
          Get.find<SocialStateRepository>(),
        ),
      );
    }
  });

  static BindingsBuilder get _profileEditBinding => BindingsBuilder(() {
    if (!Get.isRegistered<EditProfileController>()) {
      Get.lazyPut(
        () => EditProfileController(Get.find<ProfileEditRepository>()),
      );
    }
  });

  static final pages = <GetPage<dynamic>>[
    GetPage(name: Routes.root, page: MainPage.new, binding: MainBinding()),
    GetPage(
      name: Routes.homeCityPicker,
      page: HomeCityPickerPage.new,
      binding: BindingsBuilder(
        () => Get.lazyPut(
          () => HomeCityPickerController(Get.find<HomeCityRepository>()),
        ),
      ),
    ),
    GetPage(
      name: Routes.chat,
      page: ChatPage.new,
      binding: BindingsBuilder(() {
        final peer = Get.arguments;
        if (peer is! User) {
          throw ArgumentError('Chat requires a User peer');
        }
        Get.lazyPut(
          () => ChatThreadController(
            peer,
            Get.find<ChatRepository>(),
            Get.find<AiRepository>(),
          ),
        );
      }),
    ),
    GetPage(
      name: Routes.systemMessages,
      binding: _conversationFeatureBinding,
      page: () {
        final controller = Get.find<ConversationController>();
        final assistant = controller.assistant;
        return SystemMessagesPage(
          repository: controller.messageCenter,
          assistant: assistant,
          onOpenChat: assistant == null
              ? null
              : () => controller.openChat(assistant),
        );
      },
    ),
    GetPage(
      name: Routes.closeRelationships,
      binding: _conversationFeatureBinding,
      page: () {
        final controller = Get.find<ConversationController>();
        return MessageContactPage(
          title: 'message_relationship_title'.tr,
          kind: MessageContactPageKind.relationship,
          repository: controller.messageCenter,
          onOpenChat: controller.openChat,
        );
      },
    ),
    GetPage(
      name: Routes.visitors,
      binding: _conversationFeatureBinding,
      page: () {
        final controller = Get.find<ConversationController>();
        return MessageContactPage(
          title: 'message_visitors_title'.tr,
          kind: MessageContactPageKind.visitors,
          repository: controller.messageCenter,
          onOpenChat: controller.openChat,
        );
      },
    ),
    GetPage(
      name: Routes.callHistory,
      binding: _conversationFeatureBinding,
      page: () {
        final controller = Get.find<ConversationController>();
        return MessageContactPage(
          title: 'message_calls_title'.tr,
          kind: MessageContactPageKind.calls,
          repository: controller.messageCenter,
          onOpenChat: controller.openChat,
          onCall: controller.startVoiceCall,
        );
      },
    ),
    GetPage(
      name: Routes.homeActivityFilter,
      page: ActivityFilterPage.new,
      binding: BindingsBuilder(
        () => Get.lazyPut(
          () => ActivityFilterController(
            Get.find<UserRepository>(),
            Get.find<HomeCityRepository>(),
            Get.find<SocialStateRepository>(),
            Get.find<MembershipWalletRepository>(),
          ),
        ),
      ),
    ),
    GetPage(
      name: Routes.coins,
      page: CoinsPage.new,
      binding: BindingsBuilder(
        () => Get.lazyPut(
          () => WalletController(
            Get.find<MembershipWalletRepository>(),
            Get.find<StorePurchaseService>(),
          ),
        ),
      ),
    ),
    GetPage(
      name: Routes.vip,
      page: VipPage.new,
      binding: BindingsBuilder(
        () => Get.lazyPut(
          () => VipController(
            Get.find<MembershipWalletRepository>(),
            Get.find<StorePurchaseService>(),
          ),
        ),
      ),
    ),
    GetPage(
      name: Routes.userDetail,
      page: UserDetailPage.new,
      binding: BindingsBuilder(() {
        final user = Get.arguments;
        if (user is! User) throw ArgumentError('User detail requires a User');
        Get.lazyPut(
          () => UserDetailController(
            user,
            Get.find<SocialStateRepository>(),
            Get.find<ChatRepository>(),
            Get.find<MembershipWalletRepository>(),
            Get.find<UserRepository>(),
            Get.find<UserDetailRepository>(),
          ),
        );
      }),
    ),
    GetPage(
      name: Routes.report,
      page: ReportPage.new,
      binding: BindingsBuilder(() {
        final user = Get.arguments;
        if (user is! User) throw ArgumentError('Report requires a User');
        Get.lazyPut(() => ReportController(user, Get.find<ReportRepository>()));
      }),
    ),
    GetPage(
      name: Routes.imagePreview,
      page: () {
        final arguments = Get.arguments;
        if (arguments is! Map) {
          throw ArgumentError('Image preview requires arguments');
        }
        return ImagePreviewPage(
          images: List<String>.from(arguments['images'] as List),
          index: arguments['index'] as int,
        );
      },
    ),
    GetPage(
      name: Routes.voiceCall,
      page: VoiceCallPage.new,
      binding: BindingsBuilder(() {
        final user = Get.arguments;
        if (user is! User) throw ArgumentError('Voice call requires a User');
        Get.lazyPut(
          () =>
              VoiceCallController(user, Get.find<MembershipWalletRepository>()),
        );
      }),
    ),
    GetPage(
      name: Routes.teamDetail,
      page: TeamDetailPage.new,
      binding: BindingsBuilder(() {
        final arguments = Get.arguments;
        final User user;
        final TeamPost post;
        if (arguments is TeamDetailArguments) {
          user = arguments.user;
          post = arguments.post;
        } else if (arguments is User && arguments.teamPost != null) {
          user = arguments;
          post = arguments.teamPost!;
        } else {
          throw ArgumentError('Team detail requires a user with a team post');
        }
        Get.lazyPut(
          () => TeamDetailController(
            user,
            post,
            Get.find<SocialStateRepository>(),
            Get.find<MembershipWalletRepository>(),
            Get.find<TeamDetailRepository>(),
          ),
        );
      }),
    ),
    GetPage(
      name: Routes.guideArticle,
      page: () {
        final article = Get.arguments;
        if (article is! GuideArticle) {
          throw ArgumentError('Guide article required');
        }
        return GuideArticlePage(article: article);
      },
    ),
    GetPage(
      name: Routes.teamPublish,
      page: TeamPublishPage.new,
      binding: BindingsBuilder(
        () => Get.lazyPut(
          () => TeamPublishController(
            Get.find<TeamPublishRepository>(),
            Get.find<MembershipWalletRepository>(),
            Get.find<SharedPreferences>(),
          ),
        ),
      ),
    ),
    GetPage(
      name: Routes.teamActivityPicker,
      page: () =>
          TeamActivityPickerPage(initialValue: Get.arguments as String?),
    ),
    GetPage(name: Routes.teamPublishReview, page: TeamPublishReviewPage.new),
    GetPage(
      name: Routes.legal,
      page: () {
        final arguments = Get.arguments;
        if (arguments is! Map) {
          throw ArgumentError('Legal page requires arguments');
        }
        return LegalWebPage(
          title: arguments['title'] as String,
          url: arguments['url'] as String?,
          assetPath: arguments['assetPath'] as String?,
        );
      },
    ),
    GetPage(
      name: Routes.profileEdit,
      page: EditProfilePage.new,
      binding: BindingsBuilder(
        () => Get.lazyPut(
          () => EditProfileController(Get.find<ProfileEditRepository>()),
        ),
      ),
    ),
    GetPage(
      name: Routes.profileInterests,
      page: () => const ProfileTagsPage(personality: false),
    ),
    GetPage(
      name: Routes.profilePersonality,
      page: () => const ProfileTagsPage(personality: true),
    ),
    GetPage(
      name: Routes.profileNickname,
      binding: _profileEditBinding,
      page: () => ProfileTextEditPage(
        nickname: true,
        initialValue: Get.arguments as String? ?? '',
      ),
    ),
    GetPage(
      name: Routes.profileBio,
      binding: _profileEditBinding,
      page: () => ProfileTextEditPage(
        nickname: false,
        initialValue: Get.arguments as String? ?? '',
      ),
    ),
    GetPage(name: Routes.customerService, page: CustomerServicePage.new),
    GetPage(
      name: Routes.album,
      page: AlbumPage.new,
      binding: BindingsBuilder(
        () => Get.lazyPut(() => AlbumController(Get.find<AlbumRepository>())),
      ),
    ),
    GetPage(
      name: Routes.albumPreview,
      page: () {
        final item = Get.arguments;
        if (item is! AlbumItem) {
          throw ArgumentError('Album preview requires an item');
        }
        return AlbumPreviewPage(item: item);
      },
    ),
    GetPage(
      name: Routes.myWorld,
      page: MyWorldPage.new,
      binding: BindingsBuilder(
        () =>
            Get.lazyPut(() => MyWorldController(Get.find<MyWorldRepository>())),
      ),
    ),
    GetPage(
      name: Routes.myWorldPublish,
      page: MyWorldPublishPage.new,
      binding: BindingsBuilder(
        () => Get.lazyPut(
          () => MyWorldPublishController(Get.find<MyWorldRepository>()),
        ),
      ),
    ),
    GetPage(
      name: Routes.topicDetail,
      page: TopicDetailPage.new,
      binding: BindingsBuilder(() {
        final topic = Get.arguments;
        if (topic is! TopicItem) {
          throw ArgumentError('Topic detail requires a topic');
        }
        Get.lazyPut(
          () => TopicDetailController(
            topic,
            Get.find<UserRepository>(),
            Get.find<SocialStateRepository>(),
            Get.find<MembershipWalletRepository>(),
          ),
        );
      }),
    ),
    GetPage(
      name: Routes.centerSearch,
      page: CenterSearchPage.new,
      binding: BindingsBuilder(
        () => Get.lazyPut(
          () => CenterSearchController(Get.find<VideoFeedController>()),
        ),
      ),
    ),
    GetPage(
      name: Routes.videoFeed,
      page: () {
        final arguments = Get.arguments;
        if (arguments is! Map) {
          throw ArgumentError('Video feed requires arguments');
        }
        return StandaloneVideoFeedPage(
          users: List<CityUser>.from(arguments['users'] as List),
          startIndex: arguments['index'] as int,
        );
      },
    ),
  ];
}

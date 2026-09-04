class AppImageString {
  static const tabBarIcons = <String>[
    'assets/icons/tabbar/ic_tab_home.png',
    'assets/icons/tabbar/ic_tab_video.png',
    'assets/icons/tabbar/ic_tab_square.png',
    'assets/icons/tabbar/ic_tab_message.png',
    'assets/icons/tabbar/ic_tab_profile.png',
  ];
  static const tabBarSelectedIcons = <String>[
    'assets/icons/tabbar/ic_tab_home_selected.png',
    'assets/icons/tabbar/ic_tab_video_selected.png',
    'assets/icons/tabbar/ic_tab_square_selected.png',
    'assets/icons/tabbar/ic_tab_message_selected.png',
    'assets/icons/tabbar/ic_tab_profile_selected.png',
  ];

  static const String homeTopNearbyButton =
      "assets/images/home/home_top_nearby_button.png";

  static const String homeTopNearbyCard =
      "assets/images/home/home_top_nearby_card.png";

  static const String homeTopNearbyTag =
      "assets/images/home/home_top_nearby_tag.png";

  static const homeRecommendationAvatars = <String>[
    'assets/images/content/figma_home_avatar_1.png',
    'assets/images/content/figma_home_avatar_2.jpg',
    'assets/images/content/figma_home_avatar_3.png',
    'assets/images/content/figma_home_avatar_4.png',
    'assets/images/content/figma_home_avatar_5.png',
  ];
  static const homeHeroDecor =
      'assets/images/content/figma_home_hero_decor.png';
  static const homeTitleUnderline =
      'assets/images/content/figma_home_title_underline.png';
  static const homeRecommendationRibbon =
      'assets/images/content/figma_home_recommend_ribbon.png';
  static const homeCtaLeft = 'assets/images/content/figma_home_cta_left.png';
  static const homeCtaRight = 'assets/images/content/figma_home_cta_right.png';
  static const homePublish = 'assets/images/content/figma_home_publish.png';
  static const homeClock = 'assets/images/content/figma_home_clock.png';
  static const homeMap = 'assets/images/content/figma_home_map.png';

  static const profileFigmaHeader =
      'assets/images/content/figma_profile_header.png';
  static const profileFigmaAvatar =
      'assets/images/content/figma_profile_avatar.png';
  static const profileFigmaCard =
      'assets/images/content/figma_profile_card.png';
  static const profileFigmaQuickCoin =
      'assets/images/content/figma_profile_quick_coin.png';
  static const profileFigmaQuickVip =
      'assets/images/content/figma_profile_quick_vip.png';
  static const profileFigmaQuickAlbum =
      'assets/images/content/figma_profile_quick_album.png';
  static const profileFigmaEdit =
      'assets/images/content/figma_profile_icon_edit.png';
  static const profileFigmaWorld =
      'assets/images/content/figma_profile_icon_world.png';
  static const profileFigmaSupport =
      'assets/images/content/figma_profile_icon_support.png';
  static const profileFigmaPrivacy =
      'assets/images/content/figma_profile_icon_privacy.png';
  static const profileFigmaAgreement =
      'assets/images/content/figma_profile_icon_agreement.png';
  static const profileFigmaArrow =
      'assets/images/content/figma_profile_arrow.png';

  static const discoverHeaderBackground =
      'assets/images/content/figma_discover_header_bg.png';
  static const discoverSearch =
      'assets/images/content/figma_discover_icon_search.png';
  static const discoverTabUnderline =
      'assets/images/content/figma_discover_tab_underline.png';
  static const discoverLocation =
      'assets/images/content/figma_discover_icon_location.png';
  static const discoverMore =
      'assets/images/content/figma_discover_icon_more.png';
  static const discoverLike =
      'assets/images/content/figma_discover_icon_like.png';

  static const discoverLiked =
      'assets/images/content/figma_discover_icon_liked.png';
  static const discoverComment =
      'assets/images/content/figma_discover_icon_comment.png';
  static const discoverSquareAvatar1 =
      'assets/images/content/figma_discover_square_avatar_01.png';
  static const discoverSquareAvatar2 =
      'assets/images/content/figma_discover_square_avatar_02.png';
  static const discoverSquareAvatar3 =
      'assets/images/content/figma_discover_square_avatar_03.png';
  static const discoverSquareAvatar4 =
      'assets/images/content/figma_discover_square_avatar_04.png';
  static const discoverSquareAvatar5 =
      'assets/images/content/figma_discover_square_avatar_05.png';
  static const discoverSquareAvatar6 =
      'assets/images/content/figma_discover_square_avatar_06.png';
  static const discoverSquarePost0101 =
      'assets/images/content/figma_discover_square_post_01_01.png';
  static const discoverSquarePost0201 =
      'assets/images/content/figma_discover_square_post_02_01.png';
  static const discoverSquarePost0202 =
      'assets/images/content/figma_discover_square_post_02_02.png';
  static const discoverSquarePost0301 =
      'assets/images/content/figma_discover_square_post_03_01.png';
  static const discoverSquarePost0302 =
      'assets/images/content/figma_discover_square_post_03_02.png';
  static const discoverSquarePost0401 =
      'assets/images/content/figma_discover_square_post_04_01.png';
  static const discoverSquarePost0402 =
      'assets/images/content/figma_discover_square_post_04_02.png';
  static const discoverSquarePost0403 =
      'assets/images/content/figma_discover_square_post_04_03.png';
  static const discoverSquarePost0501 =
      'assets/images/content/figma_discover_square_post_05_01.png';
  static const discoverSquarePost0502 =
      'assets/images/content/figma_discover_square_post_05_02.png';
  static const discoverSquarePost0503 =
      'assets/images/content/figma_discover_square_post_05_03.png';
  static const discoverSquarePost0504 =
      'assets/images/content/figma_discover_square_post_05_04.png';
  static const discoverSquarePost0601 =
      'assets/images/content/figma_discover_square_post_06_01.png';
  static const discoverSquarePost0602 =
      'assets/images/content/figma_discover_square_post_06_02.png';

  static String discoverPartnerCover(int index) {
    final number = (index % 6) + 1;
    return 'assets/images/content/figma_discover_partner_${number.toString().padLeft(2, '0')}.png';
  }

  static const profileEditSearch = 'assets/icons/profile_edit/search.svg';
  static const profileEditAlbumAdd = 'assets/icons/profile_edit/album_add.svg';

  static const profileHeaderBackground =
      'assets/images/profile_detail/header_bg.svg';
  static const profileEditAvatar =
      'assets/images/profile_detail/edit_avatar.jpeg';
  static const profileCoin = 'assets/images/profile_detail/coin.png';
  static const profileWorldAvatar =
      'assets/images/profile_detail/world_avatar.png';
  static const profileWorldPost =
      'assets/images/profile_detail/world_post.jpeg';
  static const profileAlbumPhoto1 =
      'assets/images/profile_detail/album_photo_1.png';
  static const profileAlbumPhoto2 =
      'assets/images/profile_detail/album_photo_2.png';
  static const profileChevronRight =
      'assets/icons/profile_detail/chevron_right.svg';
  static const profileRechargeHelp =
      'assets/icons/profile_detail/recharge_help.svg';
  static const profileWorldMore = 'assets/icons/profile_detail/world_more.svg';
  static const profileWorldLike = 'assets/icons/profile_detail/world_like.svg';
  static const profileWorldComment =
      'assets/icons/profile_detail/world_comment.svg';

  static const teamPublishHeaderDecor =
      'assets/icons/team_flow/publish_header_decor.svg';
  static const teamPublishSampleBadminton =
      'assets/images/team_flow/publish_sample_badminton.png';
  static const teamPublishSampleCourt =
      'assets/images/team_flow/publish_sample_court.png';
  static const teamActivityIcon = 'assets/icons/team_flow/icon_activity.svg';
  static const teamTimeIcon = 'assets/icons/team_flow/icon_time.svg';
  static const teamLocationIcon = 'assets/icons/team_flow/icon_location.svg';
  static const teamAddPhotoIcon = 'assets/icons/team_flow/icon_add.svg';
  static const teamArrowIcon = 'assets/icons/team_flow/icon_arrow.svg';
  static const teamDetailCover = 'assets/images/team_flow/detail_cover.png';
  static const teamDetailBackIcon = 'assets/icons/team_flow/detail_back.svg';
  static const teamDetailMoreIcon = 'assets/icons/team_flow/detail_more.svg';
  static const teamDetailLocationIcon =
      'assets/icons/team_flow/detail_location.svg';
  static const teamDetailTimeIcon = 'assets/icons/team_flow/detail_time.svg';
  static const teamDetailEditIcon = 'assets/icons/team_flow/detail_edit.svg';
  static const teamDetailParticipantAdd =
      'assets/icons/team_flow/detail_participant_add.svg';
  static const teamDetailCommentAvatar =
      'assets/images/team_flow/detail_comment_avatar.png';
  static const teamDetailParticipant1 =
      'assets/images/team_flow/detail_participant_1.png';
  static const teamDetailParticipant2 =
      'assets/images/team_flow/detail_participant_2.png';
  static const teamDetailBanner1 =
      'assets/images/team_flow/detail_banner_1.png';
  static const teamDetailBanner2 =
      'assets/images/team_flow/detail_banner_2.png';
  static const teamDetailBanner3 =
      'assets/images/team_flow/detail_banner_3.png';
  static const teamDetailBanner4 =
      'assets/images/team_flow/detail_banner_4.png';
  static const teamDetailBannerCenter =
      'assets/images/team_flow/detail_banner_center.png';

  static const chatHeaderBackground =
      'assets/images/chat_system/header_background.svg';
  static const chatCurrentUserAvatar =
      'assets/images/chat_system/chat_current_avatar.png';
  static const chatPeerAvatar =
      'assets/images/chat_system/chat_peer_avatar.png';
  static const chatSystemAvatar = 'assets/images/chat_system/system_avatar.png';
  static const chatAssistantAvatar =
      'assets/images/avatar/img_avatar_assistant.png';
  static const chatLegacySystemAssistantAvatar =
      'assets/images/chat_detail/system_assistant.png';
  static const chatBack = 'assets/icons/chat_system/back.svg';
  static const chatMore = 'assets/icons/chat_system/more.svg';
  static const chatSendButton = 'assets/icons/chat_system/send_button.svg';

  static const chatConversationTitleUnderline =
      'assets/images/content/figma_chat_title_underline.png';
  static const chatConversationQuickSystem =
      'assets/images/content/figma_chat_quick_system.png';
  static const chatConversationQuickRelationship =
      'assets/images/content/figma_chat_quick_relationship.png';
  static const chatConversationQuickVisitors =
      'assets/images/content/figma_chat_quick_visitors.png';
  static const chatConversationQuickCalls =
      'assets/images/content/figma_chat_quick_calls.png';
  static const chatConversationAvatar1 =
      'assets/images/content/figma_chat_avatar_1.png';
  static const chatConversationAvatar2 =
      'assets/images/content/figma_chat_avatar_2.png';
  static const chatConversationAvatar3 =
      'assets/images/content/figma_chat_avatar_3.png';
  static const chatConversationAvatar4 =
      'assets/images/content/figma_chat_avatar_4.png';

  static const videoUserMoreSheet = 'assets/icons/video_user/more_sheet.svg';
  static const videoUserProfileBack =
      'assets/icons/video_user/profile_back.svg';
  static const videoUserProfileChat =
      'assets/icons/video_user/profile_chat.svg';
  static const videoUserProfileGender =
      'assets/icons/video_user/profile_gender.svg';
  static const videoUserProfileLike =
      'assets/icons/video_user/profile_like.svg';
  static const videoUserProfileMore =
      'assets/icons/video_user/profile_more.svg';
  static const videoUserProfileOverflow =
      'assets/icons/video_user/profile_overflow.svg';
  static const videoUserReportHeader =
      'assets/icons/video_user/report_header.svg';
  static const videoUserFavoriteSelected =
      'assets/icons/video_user/video_favorite_selected.svg';
  static const videoUserFavoriteUnselected =
      'assets/icons/video_user/video_favorite_unselected.svg';
  static const videoUserLikeSelected =
      'assets/icons/video_user/video_like_selected.svg';
  static const videoUserLikeUnselected =
      'assets/icons/video_user/video_like_unselected.svg';
  static const videoUserMore = 'assets/icons/video_user/video_more.svg';
  static const videoUserSearch = 'assets/icons/video_user/video_search.svg';
  static const videoUserTabUnderline =
      'assets/icons/video_user/video_tab_underline.svg';
  static const videoUserActivity =
      'assets/images/video_user/profile_activity.png';
  static const videoUserHero = 'assets/images/video_user/profile_hero.png';
  static const videoUserMoment1 =
      'assets/images/video_user/profile_moment_1.png';
  static const videoUserMoment2 =
      'assets/images/video_user/profile_moment_2.png';
  static const videoUserPreview1 =
      'assets/images/video_user/profile_preview_1.png';
  static const videoUserPreview2 =
      'assets/images/video_user/profile_preview_2.png';
  static const videoUserPreview3 =
      'assets/images/video_user/profile_preview_3.png';
  static const videoUserAvatar = 'assets/images/video_user/video_avatar.png';
  static const videoUserCover = 'assets/images/video_user/video_cover.png';

  static const demoUserAvatarUrls = <String, String>{
    'user_001':
        'https://images.unsplash.com/photo-1541182388496-ac92a3230e4c?auto=format&fit=crop&w=320&h=320&q=82',
    'user_002':
        'https://plus.unsplash.com/premium_photo-1677368597077-009727e906db?auto=format&fit=crop&w=320&h=320&q=82',
    'user_003':
        'https://images.unsplash.com/photo-1616639943825-e0fbad20a3d3?auto=format&fit=crop&w=320&h=320&q=82',
    'user_004':
        'https://images.unsplash.com/photo-1623039497511-ff6a22f2aa86?auto=format&fit=crop&w=320&h=320&q=82',
    'user_005':
        'https://images.unsplash.com/photo-1611417352875-b015dc152660?auto=format&fit=crop&w=320&h=320&q=82',
    'user_006':
        'https://images.unsplash.com/photo-1490088715170-e367d03a58f7?auto=format&fit=crop&w=320&h=320&q=82',
    'user_007':
        'https://images.unsplash.com/photo-1724690336308-02af024b76ab?auto=format&fit=crop&w=320&h=320&q=82',
    'user_008':
        'https://images.unsplash.com/photo-1562671292-ce06ae7a9324?auto=format&fit=crop&w=320&h=320&q=82',
    'user_009':
        'https://images.unsplash.com/photo-1660152988640-99bcdecf2bc5?auto=format&fit=crop&w=320&h=320&q=82',
    'user_010':
        'https://images.unsplash.com/photo-1659438053033-1775473ad163?auto=format&fit=crop&w=320&h=320&q=82',
    'user_011':
        'https://images.unsplash.com/photo-1659438038602-6b3cf3e8e77b?auto=format&fit=crop&w=320&h=320&q=82',
  };

  static const demoSceneUrls = <String>[
    'https://plus.unsplash.com/premium_photo-1675721844807-a3760e14353b?auto=format&fit=crop&w=1200&h=900&q=82',
    'https://images.unsplash.com/photo-1544376798-89aa6b82c6cd?auto=format&fit=crop&w=1200&h=900&q=82',
    'https://images.unsplash.com/photo-1502675135487-e971002a6adb?auto=format&fit=crop&w=1200&h=900&q=82',
    'https://images.unsplash.com/photo-1534142499731-a32a99935397?auto=format&fit=crop&w=1200&h=900&q=82',
    'https://images.unsplash.com/photo-1518410240146-36aeeed0e4f9?auto=format&fit=crop&w=1200&h=900&q=82',
    'https://images.unsplash.com/photo-1576068036336-328de1be1f2f?auto=format&fit=crop&w=1200&h=900&q=82',
    'https://images.unsplash.com/photo-1531932594968-e5e5e9dee95a?auto=format&fit=crop&w=1200&h=900&q=82',
    'https://plus.unsplash.com/premium_photo-1661962946869-4cf54aa4c778?auto=format&fit=crop&w=1200&h=900&q=82',
    'https://images.unsplash.com/photo-1670261152337-53f033b68448?auto=format&fit=crop&w=1200&h=900&q=82',
    'https://images.unsplash.com/photo-1564546139483-c4396542aa59?auto=format&fit=crop&w=1200&h=900&q=82',
    'https://images.unsplash.com/photo-1640696808792-073c6a492422?auto=format&fit=crop&w=1200&h=900&q=82',
    'https://images.unsplash.com/photo-1610892069029-f76f8b9c811f?auto=format&fit=crop&w=1200&h=900&q=82',
    'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=1200&h=900&q=82',
    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&h=900&q=82',
    'https://images.unsplash.com/photo-1490730141103-6cac27aaab94?auto=format&fit=crop&w=1200&h=900&q=82',
    'https://images.unsplash.com/photo-1470770841072-f978cf4d019e?auto=format&fit=crop&w=1200&h=900&q=82',
    'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&h=900&q=82',
    'https://images.unsplash.com/photo-1501785888041-af3ef285b470?auto=format&fit=crop&w=1200&h=900&q=82',
    'https://images.unsplash.com/photo-1488646953014-85cb44e25828?auto=format&fit=crop&w=1200&h=900&q=82',
    'https://images.unsplash.com/photo-1470252649378-9c29740c9fa8?auto=format&fit=crop&w=1200&h=900&q=82',
  ];
}

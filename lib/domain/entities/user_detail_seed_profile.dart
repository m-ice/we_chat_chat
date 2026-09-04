class UserDetailSeedProfile {
  const UserDetailSeedProfile({
    required this.userId,
    required this.heroImagePath,
    required this.galleryPreviewPaths,
    required this.personalityTags,
    required this.facts,
    required this.activities,
    required this.moments,
  });

  final int userId;
  final String heroImagePath;
  final List<String> galleryPreviewPaths;
  final List<String> personalityTags;
  final List<UserDetailSeedFact> facts;
  final List<UserDetailSeedActivity> activities;
  final List<UserDetailSeedMoment> moments;
}

class UserDetailSeedFact {
  const UserDetailSeedFact({
    required this.labelKey,
    required this.value,
    required this.valueIsTranslationKey,
  });

  final String labelKey;
  final String value;
  final bool valueIsTranslationKey;
}

class UserDetailSeedActivity {
  const UserDetailSeedActivity({
    required this.id,
    required this.ownerId,
    required this.titleKey,
    required this.coverPath,
    required this.locationKey,
    required this.date,
    required this.interestedCount,
  });

  final String id;
  final int ownerId;
  final String titleKey;
  final String coverPath;
  final String locationKey;
  final DateTime date;
  final int interestedCount;
}

class UserDetailSeedMoment {
  const UserDetailSeedMoment({
    required this.id,
    required this.contentKey,
    required this.imagePath,
    required this.createdAt,
    required this.initialLikeCount,
  });

  final String id;
  final String contentKey;
  final String imagePath;
  final DateTime createdAt;
  final int initialLikeCount;
}

class UserDetailMomentEngagement {
  const UserDetailMomentEngagement({
    required this.isLiked,
    required this.likeCount,
  });

  final bool isLiked;
  final int likeCount;
}

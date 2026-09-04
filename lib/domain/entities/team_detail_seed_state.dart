class TeamDetailSeedState {
  const TeamDetailSeedState({
    required this.participantTotal,
    required this.participantCount,
    this.participantUserIds = const [],
    this.participantAvatarPaths = const [],
  });

  final int participantTotal;
  final int participantCount;

  /// Canonical ids of users who have already joined this activity.
  final List<int> participantUserIds;

  /// Kept only to display legacy locally cached state. Bundled activity state
  /// uses [participantUserIds], which is resolved through UserRepository.
  final List<String> participantAvatarPaths;
}

class TeamDetailSeedState {
  const TeamDetailSeedState({
    required this.participantTotal,
    required this.participantCount,
    required this.participantAvatarPaths,
  });

  final int participantTotal;
  final int participantCount;
  final List<String> participantAvatarPaths;
}

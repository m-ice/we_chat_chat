class TeamDetailComment {
  const TeamDetailComment({
    required this.authorId,
    required this.nickname,
    required this.avatarPath,
    required this.content,
  });

  /// The canonical user record that authored the comment.
  ///
  /// A null value is reserved for a legacy local comment saved before the
  /// author identity was persisted. New comments and all bundled seed content
  /// must provide an id from the user repository.
  final int? authorId;
  final String nickname;
  final String avatarPath;
  final String content;
}

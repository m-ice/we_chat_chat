class EditableProfile {
  const EditableProfile({
    required this.nickname,
    required this.bio,
    required this.avatarReference,
    required this.interests,
    required this.personalityTags,
  });

  final String nickname;
  final String bio;
  final String avatarReference;
  final List<String> interests;
  final List<String> personalityTags;

  EditableProfile copyWith({
    String? nickname,
    String? bio,
    String? avatarReference,
    List<String>? interests,
    List<String>? personalityTags,
  }) => EditableProfile(
    nickname: nickname ?? this.nickname,
    bio: bio ?? this.bio,
    avatarReference: avatarReference ?? this.avatarReference,
    interests: interests ?? this.interests,
    personalityTags: personalityTags ?? this.personalityTags,
  );
}

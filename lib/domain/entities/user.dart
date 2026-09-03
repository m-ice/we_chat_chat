class User {
  const User({
    required this.id,
    required this.nickname,
    required this.age,
    required this.gender,
    required this.hobbies,
    required this.avatarPath,
    required this.intro,
    required this.isVerified,
    this.moment,
    this.teamPost,
    this.galleryImagePaths = const [],
    this.verificationVideoPath = '',
    this.isSeedData = false,
  });

  final int id;
  final String nickname;
  final int age;
  final String gender;
  final List<String> hobbies;
  final String avatarPath;
  final String intro;
  final bool isVerified;
  final UserMoment? moment;
  final TeamPost? teamPost;
  final List<String> galleryImagePaths;
  final String verificationVideoPath;
  final bool isSeedData;
}

class UserMoment {
  const UserMoment({
    required this.imagePaths,
    required this.content,
    required this.createdAt,
  });

  final List<String> imagePaths;
  final String content;
  final DateTime createdAt;
}

class TeamPost {
  const TeamPost({
    required this.imagePaths,
    required this.activity,
    required this.location,
    required this.date,
    required this.content,
  });

  final List<String> imagePaths;
  final String activity;
  final String location;
  final DateTime date;
  final String content;

  bool isExpired(DateTime today) {
    final startOfToday = DateTime(today.year, today.month, today.day);
    return date.isBefore(startOfToday);
  }
}

class CityUser {
  const CityUser({
    required this.id,
    required this.nickname,
    required this.avatarPath,
    required this.city,
    required this.age,
    required this.intent,
    required this.occupation,
    required this.intro,
    required this.hobbies,
    required this.galleryImagePaths,
    required this.isVideoVerified,
    required this.isRealPersonVerified,
    required this.videoPath,
    required this.isOnline,
    this.videoCoverPath = '',
    this.videoAvatarPath = '',
    this.isSeedData = false,
  });

  final int id;
  final String nickname;
  final String avatarPath;
  final String city;
  final int age;
  final String intent;
  final String occupation;
  final String intro;
  final List<String> hobbies;
  final List<String> galleryImagePaths;
  final bool isVideoVerified;
  final bool isRealPersonVerified;
  final String videoPath;
  final bool isOnline;
  final String videoCoverPath;
  final String videoAvatarPath;
  final bool isSeedData;
}

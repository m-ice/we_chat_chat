import '../../domain/entities/city_user.dart';

class CityUserDto {
  const CityUserDto({
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
    this.isSeedData = false,
  });

  factory CityUserDto.fromJson(Map<String, dynamic> json) => CityUserDto(
    id: json['id'] as int? ?? 0,
    nickname: json['nickname'] as String? ?? '',
    avatarPath: json['avatarPath'] as String? ?? '',
    city: json['city'] as String? ?? '',
    age: json['age'] as int? ?? 0,
    intent: json['intent'] as String? ?? '',
    occupation: json['occupation'] as String? ?? '',
    intro: json['intro'] as String? ?? '',
    hobbies: List<String>.from(json['hobbies'] as List? ?? const []),
    galleryImagePaths: List<String>.from(
      json['galleryImagePaths'] as List? ?? const [],
    ),
    isVideoVerified: json['isVideoVerified'] as bool? ?? false,
    isRealPersonVerified: json['isRealPersonVerified'] as bool? ?? false,
    videoPath: json['videoPath'] as String? ?? '',
    isOnline: json['isOnline'] as bool? ?? false,
    isSeedData: json['isSeedData'] as bool? ?? false,
  );

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
  final bool isSeedData;

  CityUser toEntity() => CityUser(
    id: id,
    nickname: nickname,
    avatarPath: avatarPath,
    city: city,
    age: age,
    intent: intent,
    occupation: occupation,
    intro: intro,
    hobbies: List.unmodifiable(hobbies),
    galleryImagePaths: List.unmodifiable(galleryImagePaths),
    isVideoVerified: isVideoVerified,
    isRealPersonVerified: isRealPersonVerified,
    videoPath: videoPath,
    isOnline: isOnline,
    isSeedData: isSeedData,
  );
}

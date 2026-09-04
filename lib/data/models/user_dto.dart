import '../../domain/entities/user.dart';

class UserDto {
  const UserDto({
    required this.id,
    required this.nickname,
    required this.age,
    required this.gender,
    required this.hobbies,
    required this.avatarPath,
    required this.intro,
    required this.isVerified,
    required this.galleryImagePaths,
    this.isSeedData = false,
    this.moment,
    this.teamPost,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
    id: json['id'] as int? ?? 0,
    nickname: json['nickname'] as String? ?? '',
    age: json['age'] as int? ?? 0,
    gender: json['gender'] as String? ?? '',
    hobbies: List<String>.from(json['hobbies'] as List? ?? const []),
    avatarPath: json['avatarPath'] as String? ?? '',
    intro: json['intro'] as String? ?? '',
    isVerified: json['isVerified'] as bool? ?? false,
    galleryImagePaths: List<String>.from(
      json['galleryImagePaths'] as List? ?? const [],
    ),
    isSeedData: json['isSeedData'] as bool? ?? false,
    moment: _isApprovedContent(json['moment'])
        ? MomentDto.fromJson(json['moment'] as Map<String, dynamic>)
        : null,
    teamPost: _isApprovedContent(json['teamPost'])
        ? TeamPostDto.fromJson(json['teamPost'] as Map<String, dynamic>)
        : null,
  );

  final int id;
  final String nickname;
  final int age;
  final String gender;
  final List<String> hobbies;
  final String avatarPath;
  final String intro;
  final bool isVerified;
  final List<String> galleryImagePaths;
  final bool isSeedData;
  final MomentDto? moment;
  final TeamPostDto? teamPost;

  User toEntity() => User(
    id: id,
    nickname: nickname,
    age: age,
    gender: gender,
    hobbies: List.unmodifiable(hobbies),
    avatarPath: avatarPath,
    intro: intro,
    isVerified: isVerified,
    galleryImagePaths: List.unmodifiable(galleryImagePaths),
    isSeedData: isSeedData,
    moment: moment?.toEntity(),
    teamPost: teamPost?.toEntity(),
  );
}

bool _isApprovedContent(Object? value) =>
    value is Map<String, dynamic> && value['moderationStatus'] == 'approved';

class MomentDto {
  const MomentDto({
    required this.imagePaths,
    required this.content,
    required this.createdAt,
  });

  factory MomentDto.fromJson(Map<String, dynamic> json) => MomentDto(
    imagePaths: List<String>.from(json['imagePaths'] as List? ?? const []),
    content: json['content'] as String? ?? '',
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  final List<String> imagePaths;
  final String content;
  final DateTime createdAt;

  UserMoment toEntity() => UserMoment(
    imagePaths: List.unmodifiable(imagePaths),
    content: content,
    createdAt: createdAt,
  );
}

class TeamPostDto {
  const TeamPostDto({
    required this.id,
    required this.ownerId,
    required this.imagePaths,
    required this.activity,
    required this.location,
    required this.date,
    required this.content,
  });

  factory TeamPostDto.fromJson(Map<String, dynamic> json) => TeamPostDto(
    id: json['id'] as String? ?? '',
    ownerId: json['ownerId'] as int? ?? 0,
    imagePaths: List<String>.from(json['imagePaths'] as List? ?? const []),
    activity: json['activity'] as String? ?? '',
    location: json['location'] as String? ?? '',
    date: DateTime.parse(json['date'] as String),
    content: json['content'] as String? ?? '',
  );

  final String id;
  final int ownerId;
  final List<String> imagePaths;
  final String activity;
  final String location;
  final DateTime date;
  final String content;

  TeamPost toEntity() => TeamPost(
    id: id,
    ownerId: ownerId,
    imagePaths: List.unmodifiable(imagePaths),
    activity: activity,
    location: location,
    date: date,
    content: content,
  );
}

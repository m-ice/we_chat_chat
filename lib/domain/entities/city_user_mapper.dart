import 'city_user.dart';
import 'user.dart';

extension CityUserMapper on CityUser {
  User toUser() => User(
    id: id,
    nickname: nickname,
    age: age,
    gender: '',
    hobbies: hobbies,
    avatarPath: avatarPath,
    intro: intro,
    isVerified: isRealPersonVerified,
    galleryImagePaths: galleryImagePaths,
    verificationVideoPath: isVideoVerified ? videoPath : '',
    isSeedData: isSeedData,
  );
}

import 'package:intl/intl.dart';

class UserPrimaryFields {
  static const String username = "username";
  static const String email = "email";

  static const String bio = "bio";

  static const String token = "token";
  static const String profileImagePath = "profile_image_path";
  static const String profileImageURL = "profile_image_url";
  static const String wallpaper = "wallpaper";
  static const String notifications = "notifications";
  static const String mobileNumber = "mobile_number";

  static const String accountCreationDate = "creation_date";

  static const String accountCreationTime = "creation_time";

  static final List<String> values = [
    username,
    bio,
    token,
    profileImagePath,
    profileImageURL,
    wallpaper,
    notifications,
    email
  ];
}

class UserPrimaryModel {
  final String? userName;
  final String email;
  final String? bio;
  String? token;
  final String profileImagePath;
  final String profileImageURL;
  final String notifications;
  final String wallpaper;
  final String mobileNumber;

  String? accountCreationDate;

  String? accountCreationTime;

  UserPrimaryModel({
    this.bio,
    required this.email,
    required this.notifications,
    required this.profileImagePath,
    required this.profileImageURL,
    this.token,
    this.userName,
    required this.wallpaper,
    this.accountCreationDate,
    this.accountCreationTime,
    required this.mobileNumber,
  });

  Map<String, Object?> toJson() => {
        UserPrimaryFields.username: userName,
        UserPrimaryFields.bio: bio,
        UserPrimaryFields.email: email,
        UserPrimaryFields.notifications: notifications,
        UserPrimaryFields.profileImageURL: profileImageURL,
        UserPrimaryFields.profileImagePath: profileImagePath,
        UserPrimaryFields.wallpaper: wallpaper,
        UserPrimaryFields.token: token,
        UserPrimaryFields.accountCreationDate: accountCreationDate,
        UserPrimaryFields.accountCreationTime: accountCreationTime,
        UserPrimaryFields.mobileNumber: mobileNumber,
      };

  static UserPrimaryModel fromJson(Map<String, Object?> json) =>
      UserPrimaryModel(
          userName: json[UserPrimaryFields.username] as String?,
          bio: json[UserPrimaryFields.bio] as String,
          email: json[UserPrimaryFields.email] as String,
          notifications: json[UserPrimaryFields.notifications] as String,
          profileImagePath: json[UserPrimaryFields.profileImagePath] as String,
          profileImageURL: json[UserPrimaryFields.profileImageURL] as String,
          token: json[UserPrimaryFields.token] as String,
          wallpaper: json[UserPrimaryFields.wallpaper] as String,
          accountCreationDate:
              json[UserPrimaryFields.accountCreationDate] as String,
          accountCreationTime:
              json[UserPrimaryFields.accountCreationTime] as String,
          mobileNumber: json[UserPrimaryFields.mobileNumber] as String);

  UserPrimaryModel copy({String? userName}) => UserPrimaryModel(
        userName: userName ?? this.userName,
        email: email,
        notifications: notifications,
        profileImagePath: profileImagePath,
        profileImageURL: profileImageURL,
        token: token,
        wallpaper: wallpaper,
        bio: bio,
        accountCreationDate: accountCreationDate,
        accountCreationTime: accountCreationTime,
        mobileNumber: mobileNumber,
      );
}

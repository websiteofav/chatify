class UserSecondaryFields {
  static const String activityPath = "activity_path";
  static const String activityTime = "activity_time";

  static const String mediaType = "media_type";

  static const String extraTime = "extra_time";
  static const String backgroundInformation = "background_information";
  static const String specialOptions = "profile_image_url";

  static final List<String> values = [
    activityPath,
    activityTime,
    extraTime,
    backgroundInformation,
    specialOptions,
    mediaType
  ];
}

class UserSecondaryModel {
  final String? activityPath;
  final String mediaType;
  final String? activityTime;
  final String extraTime;
  final String backgroundInformation;
  final String specialOptions;

  const UserSecondaryModel({
    this.activityTime,
    required this.mediaType,
    required this.backgroundInformation,
    required this.specialOptions,
    required this.extraTime,
    this.activityPath,
  });

  Map<String, Object?> toJson() => {
        UserSecondaryFields.activityPath: activityPath,
        UserSecondaryFields.activityTime: activityTime,
        UserSecondaryFields.mediaType: mediaType,
        UserSecondaryFields.specialOptions: specialOptions,
        UserSecondaryFields.backgroundInformation: backgroundInformation,
        UserSecondaryFields.extraTime: extraTime,
      };

  static UserSecondaryModel fromJson(Map<String, Object?> json) =>
      UserSecondaryModel(
        activityPath: json[UserSecondaryFields.activityPath] as String?,
        activityTime: json[UserSecondaryFields.activityTime] as String,
        mediaType: json[UserSecondaryFields.mediaType] as String,
        backgroundInformation:
            json[UserSecondaryFields.backgroundInformation] as String,
        specialOptions: json[UserSecondaryFields.specialOptions] as String,
        extraTime: json[UserSecondaryFields.extraTime] as String,
      );

  UserSecondaryModel copy({String? activityPath}) => UserSecondaryModel(
        activityPath: activityPath ?? this.activityPath,
        mediaType: mediaType,
        backgroundInformation: backgroundInformation,
        specialOptions: specialOptions,
        extraTime: extraTime,
        activityTime: activityTime,
      );
}

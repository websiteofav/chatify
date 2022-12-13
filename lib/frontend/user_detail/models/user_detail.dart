import 'package:intl/intl.dart';

class UserDetailsFields {
  static const String username = "username";
  static const String activities = "activities";

  static const String bio = "bio";

  static const String token = "token";
  static const String partners = "partners";
  static const String profilePic = "profile_pic";
  static const String totalPartners = "total_partners";
  static const String mobileNumber = "mobile_number";

  static const String accountCreationDate = "creation_date";

  static const String accountCreationTime = "creation_time";
  static const String partnerRequests = "partner_requests";
  static const String email = "email";

  //  "bio": bio,
  //       "activities": [],
  //       "partners": [],
  //       'creation_date': currentDate,
  //       'creation_time': currentTime,
  //       'mobile_number': '',
  //       'profile_pic': '',
  //       'token': token,
  //       'total_partners': '',
  //       'username': username

  static final List<String> values = [
    username,
    bio,
    token,
    accountCreationDate,
    accountCreationDate,
    activities,
    mobileNumber,
    totalPartners,
    partners,
    profilePic,
    email,
  ];
}

class UserDetailsModel {
  final String? userName;
  final List activities;
  final String? bio;
  String? token;
  final String totalPartners;
  final List partners;
  final String profilePic;
  final String mobileNumber;
  final String? email;

  String? accountCreationDate;

  String? accountCreationTime;

  final List partnerRequests;
  UserDetailsModel({
    this.bio,
    required this.activities,
    required this.partners,
    required this.profilePic,
    required this.totalPartners,
    this.token,
    this.userName,
    this.accountCreationDate,
    this.accountCreationTime,
    required this.mobileNumber,
    required this.partnerRequests,
    this.email,
  });

  Map<String, Object?> toJson() => {
        UserDetailsFields.username: userName,
        UserDetailsFields.bio: bio,
        UserDetailsFields.activities: activities,
        UserDetailsFields.partners: partners,
        UserDetailsFields.totalPartners: totalPartners,
        UserDetailsFields.profilePic: profilePic,
        UserDetailsFields.token: token,
        UserDetailsFields.accountCreationDate: accountCreationDate,
        UserDetailsFields.accountCreationTime: accountCreationTime,
        UserDetailsFields.mobileNumber: mobileNumber,
        UserDetailsFields.partnerRequests: partnerRequests,
        UserDetailsFields.email: email,
      };

  static UserDetailsModel fromJson(Map<String, Object?> json) =>
      UserDetailsModel(
          userName: json[UserDetailsFields.username] as String?,
          bio: json[UserDetailsFields.bio] as String,
          activities: json[UserDetailsFields.activities] as List,
          partners: json[UserDetailsFields.partners] as List,
          profilePic: json[UserDetailsFields.profilePic] as String,
          totalPartners: json[UserDetailsFields.totalPartners] as String,
          token: json[UserDetailsFields.token] as String,
          accountCreationDate:
              json[UserDetailsFields.accountCreationDate] as String,
          accountCreationTime:
              json[UserDetailsFields.accountCreationTime] as String,
          mobileNumber: json[UserDetailsFields.mobileNumber] as String,
          partnerRequests: json[UserDetailsFields.partnerRequests] as List,
          email: json[UserDetailsFields.email] as String);

  UserDetailsModel copy({String? userName}) => UserDetailsModel(
        userName: userName ?? this.userName,
        activities: activities,
        partners: partners,
        profilePic: profilePic,
        totalPartners: totalPartners,
        token: token,
        bio: bio,
        accountCreationDate: accountCreationDate,
        accountCreationTime: accountCreationTime,
        mobileNumber: mobileNumber,
        partnerRequests: partnerRequests,
        email: email,
      );
}

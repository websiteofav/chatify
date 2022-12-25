part of 'user_detail_bloc.dart';

abstract class UserDetailEvent extends Equatable {
  const UserDetailEvent();

  @override
  List<Object> get props => [];
}

class FetchUserEvent extends UserDetailEvent {
  final String userName;

  const FetchUserEvent({required this.userName});

  @override
  List<Object> get props => [userName];
}

class RegisterUserDetailsEvent extends UserDetailEvent {
  final String userName, email, bio;

  const RegisterUserDetailsEvent({
    required this.userName,
    required this.bio,
    required this.email,
  });

  @override
  List<Object> get props => [userName, bio, email];
}

class UserRecordEvent extends UserDetailEvent {
  const UserRecordEvent();

  @override
  List<Object> get props => [];
}

class GetAllUUsersEvent extends UserDetailEvent {
  const GetAllUUsersEvent();

  @override
  List<Object> get props => [];
}

class FetchUserPartnersEvent extends UserDetailEvent {
  final String email;
  const FetchUserPartnersEvent({required this.email});

  @override
  List<Object> get props => [email];
}

class UpdateUserPartnersEvent extends UserDetailEvent {
  final String partnerEmail;
  final String userEmail;
  final String partnerUpdateStatus;
  final List userPartnerUpdateList;

  const UpdateUserPartnersEvent({
    required this.partnerEmail,
    required this.userEmail,
    required this.partnerUpdateStatus,
    required this.userPartnerUpdateList,
  });

  @override
  List<Object> get props => [
        partnerEmail,
        userEmail,
        partnerUpdateStatus,
        userPartnerUpdateList,
      ];
}

class FetchRealTimeDataEvent extends UserDetailEvent {
  const FetchRealTimeDataEvent();

  @override
  List<Object> get props => [];
}

class FetchRealTimeMessageEvent extends UserDetailEvent {
  const FetchRealTimeMessageEvent();

  @override
  List<Object> get props => [];
}

class SendChatMessageEvent extends UserDetailEvent {
  final String username;
  final ChatMessageModel model;
  const SendChatMessageEvent({required this.model, required this.username});

  @override
  List<Object> get props => [model, username];
}

class RemoveOldMessageEvent extends UserDetailEvent {
  final String partnerEmail;
  const RemoveOldMessageEvent({required this.partnerEmail});

  @override
  List<Object> get props => [partnerEmail];
}

class UploadFileToFirebaseStorageEvent extends UserDetailEvent {
  final File filePath;
  final String reference;
  const UploadFileToFirebaseStorageEvent(
      {required this.filePath, required this.reference});

  @override
  List<Object> get props => [filePath, reference];
}

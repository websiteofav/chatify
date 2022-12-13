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

import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:chat_app/frontend/auth/bloc/auth_bloc.dart';
import 'package:chat_app/frontend/chat/models/chat_model.dart';
import 'package:chat_app/frontend/home/models/user_primary_details.dart';
import 'package:chat_app/frontend/user_detail/models/user_detail.dart';
import 'package:chat_app/frontend/user_detail/repository/repository.dart';
import 'package:chat_app/frontend/utils/enums.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

part 'user_detail_event.dart';
part 'user_detail_state.dart';

class UserDetailBloc extends Bloc<UserDetailEvent, UserDetailState> {
  final UserRepository repository;
  UserDetailBloc({required this.repository}) : super(UserDetailInitial()) {
    on<UserDetailEvent>((event, emit) async {
      if (event is InitialEvent) {
        emit(UserDetailInitial());
      } else if (event is FetchUserEvent) {
        emit(UserDetailLoading());
        try {
          UserDetailsResults auth =
              await repository.checkUserAlreadyExists(userName: event.userName);
          if (auth == UserDetailsResults.userNotFound) {
            emit(UserDetalsFetched());
          } else {
            emit(const UserDetailError(message: 'Username already Exists'));
          }
        } catch (e) {
          debugPrint(e.toString());

          emit(const UserDetailError(message: 'Something went wrong'));
        }
      } else if (event is RegisterUserDetailsEvent) {
        emit(UserDetailLoading());
        try {
          UserDetailsAddedResults auth = await repository.registerUserDetails(
            username: event.userName,
            bio: event.bio,
            email: event.email,
          );

          if (auth == UserDetailsAddedResults.detailAdded) {
            emit(UserDetalsAdded());
          } else {
            return emit(
                const UserDetailError(message: 'Details could not be added'));
          }
        } catch (e) {
          debugPrint(e.toString());

          emit(const UserDetailError(message: 'Something went wrong'));
        }
      } else if (event is UserRecordEvent) {
        emit(UserDetailLoading());
        try {
          UserDetailsRecordsResults records =
              await repository.searchUserRecords();

          if (records == UserDetailsRecordsResults.userNotFound) {
            emit(const UserDetailError(message: 'No user found'));
          } else if (records == UserDetailsRecordsResults.detailsNotFound) {
            emit(const UserDetailError(message: 'No records found'));
          } else {
            emit(UserDetalsExists());
          }
        } catch (e) {
          debugPrint(e.toString());

          emit(const UserDetailError(message: 'Something went wrong'));
        }
      } else if (event is GetAllUUsersEvent) {
        emit(UserDetailLoading());
        try {
          List<UserDetailsModel> users = await repository.getAllUsers();

          if (users.isEmpty) {
            emit(const GetAllUsersFailed(message: 'No users found'));
          } else {
            emit(GetAllUsers(model: users));
          }
        } catch (e) {
          debugPrint(e.toString());

          emit(const GetAllUsersFailed(message: 'No users found'));
        }
      } else if (event is FetchUserPartnersEvent) {
        emit(UserDetailLoading());
        try {
          List partners =
              await repository.currentUserPartners(email: event.email);

          if (partners.isEmpty) {
            emit(const GetUserPartnersFailed(message: 'No partners found'));
          } else {
            emit(GetUserPartners(partner: partners));
          }
        } catch (e) {
          debugPrint(e.toString());

          emit(const GetUserPartnersFailed(message: 'No partners found'));
        }
      } else if (event is UpdateUserPartnersEvent) {
        emit(UserDetailLoading());
        try {
          List partners = await repository.changePartnerStatus(
            partnerEmail: event.partnerEmail,
            partnerUpdateStatus: event.partnerUpdateStatus,
            userEmail: event.userEmail,
            userPartnerUpdateList: event.userPartnerUpdateList,
          );

          if (partners.isEmpty) {
            emit(const GetUserPartnersFailed(
                message: 'Request could not be sent'));
          } else {
            emit(GetUserPartners(partner: partners));
          }
        } catch (e) {
          debugPrint(e.toString());

          emit(const GetUserPartnersFailed(message: ''));
        }
      } else if (event is FetchRealTimeDataEvent) {
        emit(UserDetailLoading());
        try {
          Stream<QuerySnapshot<Map<String, dynamic>>> snapshot =
              await repository.fetchRealTimeDataFromFirestore();

          emit(RealTimeDateFetched(snapshot: snapshot));
        } catch (e) {
          debugPrint(e.toString());

          emit(const RealTimeDateFetchingFailed(
              message: 'User could not be fetched'));
        }
      } else if (event is FetchRealTimeMessageEvent) {
        emit(UserDetailLoading());
        try {
          Stream<DocumentSnapshot<Map<String, dynamic>>> snapshot =
              await repository.fetchRealTimeMessageFromFirestore();

          emit(RealTimeMessageFetched(snapshot: snapshot));
        } catch (e) {
          debugPrint(e.toString());

          emit(const RealTimeMessageFetchingFailed(
              message: 'User could not be fetched'));
        }
      } else if (event is SendChatMessageEvent) {
        emit(UserDetailLoading());
        try {
          //    (await repository.fetchRealTimeDataFromFirestore())
          //     .listen((event) async {
          //   // emit(RealTimeDateFetched(snapshot: event));

          //   await emit.onEach(stream, onData: (data) {
          //     emit(RealTimeDateFetched(snapshot: event));
          //   });
          // });
          bool result = await repository.sendMessageToPartner(
              event.username, event.model);

          result
              ? emit(const ChatMessageAdded())
              : emit(const ChatMessageAddedFailed(
                  message: 'Message could not be sent'));
        } catch (e) {
          emit(const ChatMessageAddedFailed(
              message: 'Message could not be sent'));
        }
      } else if (event is RemoveOldMessageEvent) {
        emit(UserDetailLoading());
        try {
          //    (await repository.fetchRealTimeDataFromFirestore())
          //     .listen((event) async {
          //   // emit(RealTimeDateFetched(snapshot: event));

          //   await emit.onEach(stream, onData: (data) {
          //     emit(RealTimeDateFetched(snapshot: event));
          //   });
          // });
          bool result = await repository.removeOldMessages(event.partnerEmail);

          result
              ? emit(const OldMessagesRemoved())
              : emit(const OldMessagesRemovedFailed(
                  message: 'Messages could not be retrieved'));
        } catch (e) {
          emit(const OldMessagesRemovedFailed(
              message: 'Messages could not be retrieved'));
        }
      } else if (event is UploadFileToFirebaseStorageEvent) {
        emit(UserDetailLoading());
        try {
          String? result = await repository.uploadMediaToFirebaseStorage(
              event.filePath, event.reference);

          result == null
              ? emit(const FileUploadedToStorageFaield(
                  message: 'Messages could not be retrieved'))
              : emit(FileUploadedToStorage(
                  downloadUrl: result, reference: event.reference));
        } catch (e) {
          emit(const FileUploadedToStorageFaield(
              message: 'Messages could not be retrieved'));
        }
      } else if (event is UploadFileToFirebaseStorageEvent) {
        emit(UserDetailLoading());
        try {
          String? result = await repository.uploadMediaToFirebaseStorage(
              event.filePath, event.reference);

          result == null
              ? emit(const FileUploadedToStorageFaield(
                  message: 'Messages could not be retrieved'))
              : emit(FileUploadedToStorage(
                  downloadUrl: result, reference: event.reference));
        } catch (e) {
          emit(const FileUploadedToStorageFaield(
              message: 'Messages could not be retrieved'));
        }
      } else if (event is UpdateProfileImageUrlEvent) {
        emit(UserDetailLoading());
        try {
          bool result =
              await repository.updateProfileImageUrl(event.downloadUrl);

          result == true
              ? emit(UpdateProfileImage())
              : emit(const UpdateProfileImageFaield(
                  message: 'Something went wrong'));
        } catch (e) {
          emit(UpdateProfileImageFaield(message: e.toString()));
        }
      } else if (event is FetchUserDataEvent) {
        emit(UserDetailLoading());
        try {
          UserDetailsModel result = await repository.getCurrentUserData(
              email: event.email, parse: event.parse);

          emit(CurrentUserDataFetched(model: result));
        } catch (e) {
          emit(CurrentUserDataFetchedFaield(message: e.toString()));
        }
      }
    });
  }
}
